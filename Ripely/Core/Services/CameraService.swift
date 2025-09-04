//
//  CameraServiceDelegate.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//
import AVFoundation
import UIKit
import Vision

final class CameraService: NSObject, ObservableObject {
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
    
    // UI Device Currently At
    private let isIpad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    private let isIphone: Bool = UIDevice.current.userInterfaceIdiom == .phone

    init(mlService: MLServiceProtocol = MLService()) {
        self.mlService = mlService
        super.init()

        orientationManager = OrientationManager()
        setupOrientationObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupOrientationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneDidChange), name: UIScene.didActivateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneDidChange), name: UIScene.willDeactivateNotification, object: nil)
    }

    @objc private func sceneDidChange() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateVideoOrientation()
            if let currentView = self.currentView {
                self.updatePreviewLayerFrame(with: currentView.bounds)
            }
        }
    }

    @objc private func orientationDidChange() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.updateVideoOrientation()
            if let currentView = self.currentView {
                self.updatePreviewLayerFrame(with: currentView.bounds)
            }
        }
    }

    func setupCamera(in view: UIView) {
        self.currentView = view
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            delegate?.cameraService(self, didFailWithError: CameraError.setupFailed)
            return
        }

        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        videoConnection = output.connection(with: .video)
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds

        DispatchQueue.main.async {
            view.layer.insertSublayer(preview, at: 0)
        }

        self.previewLayer = preview

        DispatchQueue.main.async {
            self.updateVideoOrientation()
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.updateVideoOrientation()
            }
        }
    }

    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
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

        let previewLayerBounds = previewLayer.bounds
        let videoGravity = previewLayer.videoGravity
        let visibleRect = calculateVisibleRect(imageSize: ciImage.extent.size, previewSize: previewLayerBounds.size, videoGravity: videoGravity)

        let normalizedCropRect = normalizeCropRect(cropRect, previewLayerBounds: previewLayerBounds)
        let imageCropRect = CGRect(x: visibleRect.origin.x + (normalizedCropRect.origin.x * visibleRect.width),
                                   y: visibleRect.origin.y + (normalizedCropRect.origin.y * visibleRect.height),
                                   width: normalizedCropRect.width * visibleRect.width,
                                   height: normalizedCropRect.height * visibleRect.height)

        let finalCropRect = imageCropRect.intersection(ciImage.extent)

        guard !finalCropRect.isEmpty, let croppedCG = cgImage.cropping(to: finalCropRect) else {
            delegate?.cameraService(self, didFailWithError: CameraError.croppingFailed)
            return
        }

        let croppedImage = UIImage(cgImage: croppedCG, scale: 1.0, orientation: getCurrentImageOrientation())

        DispatchQueue.main.async {
            self.delegate?.cameraService(self, didCaptureImage: croppedImage)
        }
    }
}

private extension CameraService {
    func normalizeCropRect(_ cropRect: CGRect, previewLayerBounds: CGRect) -> CGRect {
        var normalizedCropRect = CGRect(x: cropRect.origin.x / previewLayerBounds.width,
                                        y: cropRect.origin.y / previewLayerBounds.height,
                                        width: cropRect.size.width / previewLayerBounds.width,
                                        height: cropRect.size.height / previewLayerBounds.height)

        let verticalOffset: CGFloat = -0.005
        normalizedCropRect.origin.y += verticalOffset
        normalizedCropRect.origin.y = max(0, normalizedCropRect.origin.y)
        if normalizedCropRect.origin.y + normalizedCropRect.height > 1.0 {
            normalizedCropRect.origin.y = 1.0 - normalizedCropRect.height
        }

        return normalizedCropRect
    }

    func calculateVisibleRect(imageSize: CGSize, previewSize: CGSize, videoGravity: AVLayerVideoGravity) -> CGRect {
        let imageAspectRatio = imageSize.width / imageSize.height
        let previewAspectRatio = previewSize.width / previewSize.height
        
        switch videoGravity {
        case .resizeAspectFill:
            if imageAspectRatio > previewAspectRatio {
                let visibleWidth = imageSize.height * previewAspectRatio
                let cropX = (imageSize.width - visibleWidth) / 2
                return CGRect(x: cropX, y: 0, width: visibleWidth, height: imageSize.height)
            } else {
                let visibleHeight = imageSize.width / previewAspectRatio
                let cropY = (imageSize.height - visibleHeight) / 2
                return CGRect(x: 0, y: cropY, width: imageSize.width, height: visibleHeight)
            }
            
        case .resizeAspect:
            if imageAspectRatio > previewAspectRatio {
                let visibleHeight = imageSize.width / previewAspectRatio
                let offsetY = (imageSize.height - visibleHeight) / 2
                return CGRect(x: 0, y: offsetY, width: imageSize.width, height: visibleHeight)
            } else {
                let visibleWidth = imageSize.height * previewAspectRatio
                let offsetX = (imageSize.width - visibleWidth) / 2
                return CGRect(x: offsetX, y: 0, width: visibleWidth, height: imageSize.height)
            }
            
        default:
            return CGRect(origin: .zero, size: imageSize)
        }
    }

    func updateVideoOrientation() {
        guard let videoConnection = videoConnection, let previewLayer = previewLayer else { return }

        let rotationAngle: CGFloat

        if isIpad {
            rotationAngle = getiPadVideoRotationAngle()
        } else if isIphone {
            rotationAngle = getVideoRotationAngle()
        } else {
            rotationAngle = getVideoRotationAngle()
        }
        
        videoConnection.videoRotationAngle = rotationAngle
        previewLayer.connection?.videoRotationAngle = rotationAngle
    }

    func getCurrentInterfaceOrientation() -> UIInterfaceOrientation {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.interfaceOrientation
        }
        return .portrait
    }
    
    func getVideoRotationAngle() -> CGFloat {
        switch getCurrentInterfaceOrientation() {
        case .portrait: return 90.0
        case .portraitUpsideDown: return 270.0
        case .landscapeLeft: return 0.0
        case .landscapeRight: return 180.0
        default: return 90.0
        }
    }
    
    func getiPadVideoRotationAngle() -> CGFloat {
        switch getCurrentInterfaceOrientation() {
        case .portrait: return 90.0
        case .portraitUpsideDown: return 270.0
        case .landscapeLeft: return 180.0
        case .landscapeRight: return 0.0
        default: return 90.0
        }
    }

    func getCurrentImageOrientation() -> UIImage.Orientation {
        switch getCurrentInterfaceOrientation() {
        case .portrait: return .up
        case .portraitUpsideDown: return .down
        case .landscapeLeft: return .up
        case .landscapeRight: return .up
        default: return .up
        }
    }
    
    func analyzeBrightness(from pixelBuffer: CVPixelBuffer) -> Float {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let centerRect = CGRect(x: ciImage.extent.width * 0.3, y: ciImage.extent.height * 0.3, width: ciImage.extent.width * 0.4, height: ciImage.extent.height * 0.4)
        let croppedImage = ciImage.cropped(to: centerRect)

        let filter = CIFilter(name: "CIAreaAverage")
        filter?.setValue(croppedImage, forKey: kCIInputImageKey)
        filter?.setValue(CIVector(cgRect: croppedImage.extent), forKey: kCIInputExtentKey)

        guard let outputImage = filter?.outputImage else { return 0.5 }

        let context = CIContext()
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        let red = Float(bitmap[0]) / 255.0
        let green = Float(bitmap[1]) / 255.0
        let blue = Float(bitmap[2]) / 255.0

        return 0.299 * red + 0.587 * green + 0.114 * blue
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.lastSampleBuffer = sampleBuffer
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let currentTime = CACurrentMediaTime()
        if currentTime - lastBrightnessCheck >= brightnessCheckInterval {
            lastBrightnessCheck = currentTime
            
            let brightness = analyzeBrightness(from: pixelBuffer)
            let isTooDark = brightness < brightnessThreshold
            
            DispatchQueue.main.async {
                self.delegate?.cameraService(self, didUpdateBrightness: isTooDark)
            }
        }
        
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
