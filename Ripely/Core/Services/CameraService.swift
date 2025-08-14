//
//  CameraServiceDelegate.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//

import AVFoundation
import UIKit
import Vision

protocol CameraServiceDelegate: AnyObject {
    func cameraService(_ service: CameraService, didOutput prediction: String)
    func cameraService(_ service: CameraService, didCaptureImage image: UIImage)
    func cameraService(_ service: CameraService, didFailWithError error: Error)
    func cameraService(_ service: CameraService, didUpdateBrightness isTooDark: Bool)
}

class CameraService: NSObject, ObservableObject {
    weak var delegate: CameraServiceDelegate?
    
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var lastSampleBuffer: CMSampleBuffer?
    private let mlService: MLServiceProtocol
    private var videoConnection: AVCaptureConnection?
    private var currentView: UIView?
    private var orientationManager: OrientationManager?
    
    // Simplified brightness detection
    private var brightnessThreshold: Float = 0.25
    private var lastBrightnessCheck: TimeInterval = 0
    private let brightnessCheckInterval: TimeInterval = 0.5
    
    init(mlService: MLServiceProtocol = MLService()) {
        self.mlService = mlService
        super.init()
        
        if #available(iOS 14.0, *) {
            orientationManager = OrientationManager()
        }
        
        setupOrientationObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupOrientationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        // Use modern scene-based notifications for interface orientation changes
        if #available(iOS 13.0, *) {
            // Listen for window scene changes which is more reliable than status bar changes
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(sceneDidChange),
                name: UIScene.didActivateNotification,
                object: nil
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(sceneDidChange),
                name: UIScene.willDeactivateNotification,
                object: nil
            )
        }
    }
    
    @objc private func sceneDidChange() {
        // Use a small delay to ensure the scene transition is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateVideoOrientation()
            self.updatePreviewLayerFrame()
        }
    }
    
    @objc private func orientationDidChange() {
        // For iPad, we need to be more responsive to orientation changes
        // Use a shorter delay for better user experience
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.updateVideoOrientation()
            self.updatePreviewLayerFrame()
        }
    }
    
    func setupCamera(in view: UIView) {
        self.currentView = view
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            delegate?.cameraService(self, didFailWithError: CameraError.setupFailed)
            return
        }
        
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        // Store the video connection for orientation updates
        videoConnection = output.connection(with: .video)
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        
        DispatchQueue.main.async {
            view.layer.insertSublayer(preview, at: 0)
        }
        
        self.previewLayer = preview
        
        // Set initial orientation immediately after setup
        DispatchQueue.main.async {
            self.updateVideoOrientation()
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
            
            // Update orientation again after session starts for iPad compatibility
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.updateVideoOrientation()
            }
        }
    }
    
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = (device.torchMode == .on) ? .off : .on
            device.unlockForConfiguration()
        } catch {
            delegate?.cameraService(self, didFailWithError: error)
        }
    }
    
    func updatePreviewLayerFrame(with bounds: CGRect) {
        DispatchQueue.main.async {
            self.previewLayer?.frame = bounds
        }
    }
    
    func captureImage(cropRect: CGRect) {
        guard let buffer = lastSampleBuffer,
              let imageBuffer = CMSampleBufferGetImageBuffer(buffer),
              let previewLayer = previewLayer else {
            delegate?.cameraService(self, didFailWithError: CameraError.captureError)
            return
        }
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            delegate?.cameraService(self, didFailWithError: CameraError.imageProcessingFailed)
            return
        }
        
        // Get the actual preview layer bounds and frame
        let previewLayerBounds = previewLayer.bounds
        let videoGravity = previewLayer.videoGravity
        
        // Calculate the visible rect in the preview layer based on video gravity
        let visibleRect = calculateVisibleRect(
            imageSize: ciImage.extent.size,
            previewSize: previewLayerBounds.size,
            videoGravity: videoGravity
        )
        
        // Convert crop rect from preview layer coordinates to image coordinates
        var normalizedCropRect = CGRect(
            x: cropRect.origin.x / previewLayerBounds.width,
            y: cropRect.origin.y / previewLayerBounds.height,
            width: cropRect.size.width / previewLayerBounds.width,
            height: cropRect.size.height / previewLayerBounds.height
        )
        
        // Apply device-specific offset adjustments for iPhone
        if UIDevice.current.userInterfaceIdiom == .phone {
            // Move the crop area slightly upward for iPhone to capture the whole apple
            let verticalOffset: CGFloat = -0.135
            normalizedCropRect.origin.y += verticalOffset
            
            // Ensure the crop rect doesn't go out of bounds
            normalizedCropRect.origin.y = max(0, normalizedCropRect.origin.y)
            if normalizedCropRect.origin.y + normalizedCropRect.height > 1.0 {
                normalizedCropRect.origin.y = 1.0 - normalizedCropRect.height
            }
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            // Move the crop area slightly upward for iPhone to capture the whole apple
            let verticalOffset: CGFloat = -0.055
            normalizedCropRect.origin.y += verticalOffset
            
            // Ensure the crop rect doesn't go out of bounds
            normalizedCropRect.origin.y = max(0, normalizedCropRect.origin.y)
            if normalizedCropRect.origin.y + normalizedCropRect.height > 1.0 {
                normalizedCropRect.origin.y = 1.0 - normalizedCropRect.height
            }
        }
        
        // Map to the visible portion of the image
        let imageCropRect = CGRect(
            x: visibleRect.origin.x + (normalizedCropRect.origin.x * visibleRect.width),
            y: visibleRect.origin.y + (normalizedCropRect.origin.y * visibleRect.height),
            width: normalizedCropRect.width * visibleRect.width,
            height: normalizedCropRect.height * visibleRect.height
        )
        
        // Ensure the crop rect is within image bounds
        let finalCropRect = imageCropRect.intersection(ciImage.extent)
        
        guard !finalCropRect.isEmpty,
              let croppedCG = cgImage.cropping(to: finalCropRect) else {
            delegate?.cameraService(self, didFailWithError: CameraError.croppingFailed)
            return
        }
        
        let croppedImage = UIImage(cgImage: croppedCG, scale: 1.0, orientation: getCurrentImageOrientation())
        
        DispatchQueue.main.async {
            self.delegate?.cameraService(self, didCaptureImage: croppedImage)
        }
    }
    
    // MARK: - Orientation Handling
    private func calculateVisibleRect(imageSize: CGSize, previewSize: CGSize, videoGravity: AVLayerVideoGravity) -> CGRect {
        // Calculate how the image is displayed in the preview layer based on video gravity
        let imageAspectRatio = imageSize.width / imageSize.height
        let previewAspectRatio = previewSize.width / previewSize.height
        
        switch videoGravity {
        case .resizeAspectFill:
            if imageAspectRatio > previewAspectRatio {
                // Image is wider than preview, so height fills and width is cropped
                let visibleWidth = imageSize.height * previewAspectRatio
                let cropX = (imageSize.width - visibleWidth) / 2
                return CGRect(x: cropX, y: 0, width: visibleWidth, height: imageSize.height)
            } else {
                // Image is taller than preview, so width fills and height is cropped
                let visibleHeight = imageSize.width / previewAspectRatio
                let cropY = (imageSize.height - visibleHeight) / 2
                return CGRect(x: 0, y: cropY, width: imageSize.width, height: visibleHeight)
            }
        case .resizeAspect:
            if imageAspectRatio > previewAspectRatio {
                // Image is wider, so width fills and height is letterboxed
                let visibleHeight = imageSize.width / previewAspectRatio
                let offsetY = (imageSize.height - visibleHeight) / 2
                return CGRect(x: 0, y: offsetY, width: imageSize.width, height: visibleHeight)
            } else {
                // Image is taller, so height fills and width is pillarboxed
                let visibleWidth = imageSize.height * previewAspectRatio
                let offsetX = (imageSize.width - visibleWidth) / 2
                return CGRect(x: offsetX, y: 0, width: visibleWidth, height: imageSize.height)
            }
        default:
            // For .resize and other cases, assume full image is visible
            return CGRect(origin: .zero, size: imageSize)
        }
    }
    
    private func updateVideoOrientation() {
        guard let videoConnection = videoConnection,
              let previewLayer = previewLayer else { return }
        
        // Get the correct interface orientation from window scene
        let interfaceOrientation = getCurrentInterfaceOrientation()
        
        // Use the more reliable AVCaptureVideoOrientation enum for proper iPad support
        let videoOrientation = getVideoOrientation(for: interfaceOrientation)
        
        // Set video connection orientation using the legacy but more reliable API
        if videoConnection.isVideoOrientationSupported {
            videoConnection.videoOrientation = videoOrientation
        }
        
        // Set preview layer orientation
        if let connection = previewLayer.connection,
           connection.isVideoOrientationSupported {
            connection.videoOrientation = videoOrientation
        }
    }
    
    private func updatePreviewLayerFrame() {
        guard let previewLayer = previewLayer,
              let currentView = currentView else { return }
        
        DispatchQueue.main.async {
            previewLayer.frame = currentView.bounds
        }
    }
    
    private func getCurrentInterfaceOrientation() -> UIInterfaceOrientation {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.interfaceOrientation
        }
        return .portrait
    }
    
    private func getVideoOrientation(for interfaceOrientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        // This matches the native iOS Camera app behavior on iPad
        switch interfaceOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .portrait
        }
    }
    
    private func getVideoRotationAngle() -> CGFloat {
        let interfaceOrientation = getCurrentInterfaceOrientation()
        
        // Match native Camera app rotation behavior for iPad
        switch interfaceOrientation {
        case .portrait:
            return 0.0
        case .portraitUpsideDown:
            return 180.0
        case .landscapeLeft:
            return 270.0
        case .landscapeRight:
            return 90.0
        default:
            return 0.0
        }
    }
    
    private func getCurrentImageOrientation() -> UIImage.Orientation {
        let interfaceOrientation = getCurrentInterfaceOrientation()
        
        // This ensures captured images appear in the same orientation as the live preview
        // Updated to match exactly what the user sees in the preview
        switch interfaceOrientation {
        case .portrait:
            return .up
        case .portraitUpsideDown:
            return .down
        case .landscapeLeft:
            return .up
        case .landscapeRight:
            return .up
        default:
            return .up
        }
    }
    
    private func getCurrentImageRotationAngle() -> CGFloat {
        let interfaceOrientation = getCurrentInterfaceOrientation()
        
        // Match the video rotation angles for consistency
        switch interfaceOrientation {
        case .portrait:
            return 90.0
        case .portraitUpsideDown:
            return 270.0
        case .landscapeLeft:
            return 0.0
        case .landscapeRight:
            return 180.0
        default:
            return 90.0
        }
    }
    
    // MARK: - Simplified Brightness Analysis
    private func analyzeBrightness(from pixelBuffer: CVPixelBuffer) -> Float {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // Sample from center region
        let centerRect = CGRect(
            x: ciImage.extent.width * 0.3,
            y: ciImage.extent.height * 0.3,
            width: ciImage.extent.width * 0.4,
            height: ciImage.extent.height * 0.4
        )
        
        let croppedImage = ciImage.cropped(to: centerRect)
        
        // Use CIAreaAverage filter for quick brightness calculation
        let filter = CIFilter(name: "CIAreaAverage")!
        filter.setValue(croppedImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgRect: croppedImage.extent), forKey: kCIInputExtentKey)
        
        guard let outputImage = filter.outputImage else { return 0.5 }
        
        let context = CIContext()
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        // Calculate luminance from RGB
        let r = Float(bitmap[0]) / 255.0
        let g = Float(bitmap[1]) / 255.0
        let b = Float(bitmap[2]) / 255.0
        
        return 0.299 * r + 0.587 * g + 0.114 * b
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.lastSampleBuffer = sampleBuffer
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Check brightness periodically
        let currentTime = CACurrentMediaTime()
        if currentTime - lastBrightnessCheck >= brightnessCheckInterval {
            lastBrightnessCheck = currentTime
            
            let brightness = analyzeBrightness(from: pixelBuffer)
            let isTooDark = brightness < brightnessThreshold
            
            DispatchQueue.main.async {
                self.delegate?.cameraService(self, didUpdateBrightness: isTooDark)
            }
        }
        
        // Continue with ML prediction
        mlService.predict(from: pixelBuffer) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let prediction):
                DispatchQueue.main.async {
                    self.delegate?.cameraService(self, didOutput: prediction)
                }
            case .failure:
                break // Ignore live prediction errors
            }
        }
    }
}

enum CameraError: Error {
    case setupFailed
    case captureError
    case imageProcessingFailed
    case croppingFailed
}
