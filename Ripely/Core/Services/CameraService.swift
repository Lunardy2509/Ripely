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
    private var brightnessThreshold: Float = 0.15 // Lowered threshold for better detection
    private var lastBrightnessCheck: TimeInterval = 0
    private let brightnessCheckInterval: TimeInterval = 0.5
    
    // LiDAR depth analysis
    private var depthDataOutput: AVCaptureDepthDataOutput?
    private var isLiDARAvailable: Bool = false
    private var lastDepthData: AVDepthData?
    private var lastDepthCheck: TimeInterval = 0
    private let depthCheckInterval: TimeInterval = 0.5
    
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
        
        // Setup LiDAR if available
        setupLiDARIfAvailable()

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
    
    func isLiDARSupported() -> Bool {
        return isLiDARAvailable
    }
    
    func getCurrentDepthData() -> AVDepthData? {
        return lastDepthData
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
    
    func getAdaptiveBrightnessThreshold(foregroundBrightness: Float, backgroundBrightness: Float) -> Float {
        let brightnessDifference = abs(foregroundBrightness - backgroundBrightness)
        
        // If there's a large difference between foreground and background (like black background),
        // use a lower threshold focused on the subject
        if brightnessDifference > 0.15 {
            return 0.1 // Lower threshold for high contrast scenarios
        } else {
            return 0.15 // Standard threshold
        }
    }
    
    // MARK: - LiDAR Helper Functions
    
    private struct CoordinateMapping {
        let imageWidth: Int
        let imageHeight: Int
        let depthWidth: Int
        let depthHeight: Int
        let scaleX: Float
        let scaleY: Float
        let centerX: Int
        let centerY: Int
        let centerWidth: Int
        let centerHeight: Int
    }
    
    private struct PixelBuffers {
        let imageBaseAddress: UnsafeMutableRawPointer
        let depthBaseAddress: UnsafeMutableRawPointer
        let imageBytesPerRow: Int
        let depthBytesPerRow: Int
    }
    
    private struct BrightnessResults {
        let totalBrightness: Float
        let validPixels: Int
        let foregroundBrightness: Float
        let foregroundPixels: Int
    }
    
    private func setupBrightnessAnalysisCoordinates(ciImage: CIImage, depthMap: CVPixelBuffer) -> CoordinateMapping? {
        let imageWidth = Int(ciImage.extent.width)
        let imageHeight = Int(ciImage.extent.height)
        let depthWidth = CVPixelBufferGetWidth(depthMap)
        let depthHeight = CVPixelBufferGetHeight(depthMap)
        
        let scaleX = Float(depthWidth) / Float(imageWidth)
        let scaleY = Float(depthHeight) / Float(imageHeight)
        
        let centerX = Int(Float(imageWidth) * 0.3)
        let centerY = Int(Float(imageHeight) * 0.3)
        let centerWidth = Int(Float(imageWidth) * 0.4)
        let centerHeight = Int(Float(imageHeight) * 0.4)
        
        return CoordinateMapping(imageWidth: imageWidth, imageHeight: imageHeight,
                               depthWidth: depthWidth, depthHeight: depthHeight,
                               scaleX: scaleX, scaleY: scaleY,
                               centerX: centerX, centerY: centerY,
                               centerWidth: centerWidth, centerHeight: centerHeight)
    }
    
    private func lockPixelBuffers(pixelBuffer: CVPixelBuffer, depthMap: CVPixelBuffer) -> PixelBuffers? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        
        guard let imageBaseAddress = CVPixelBufferGetBaseAddress(pixelBuffer),
              let depthBaseAddress = CVPixelBufferGetBaseAddress(depthMap) else {
            return nil
        }
        
        let imageBytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let depthBytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)
        
        return PixelBuffers(imageBaseAddress: imageBaseAddress, depthBaseAddress: depthBaseAddress,
                          imageBytesPerRow: imageBytesPerRow, depthBytesPerRow: depthBytesPerRow)
    }
    
    private func findSubjectDepthRange(coordinateMapping: CoordinateMapping, pixelBuffers: PixelBuffers) -> ClosedRange<Float> {
        var depthHistogram: [Int: Int] = [:]
        
        for coordinateY in coordinateMapping.centerY..<(coordinateMapping.centerY + coordinateMapping.centerHeight) {
            guard coordinateY < coordinateMapping.imageHeight else { break }
            
            for coordinateX in coordinateMapping.centerX..<(coordinateMapping.centerX + coordinateMapping.centerWidth) {
                guard coordinateX < coordinateMapping.imageWidth else { break }
                
                let depthX = Int(Float(coordinateX) * coordinateMapping.scaleX)
                let depthY = Int(Float(coordinateY) * coordinateMapping.scaleY)
                
                guard depthX < coordinateMapping.depthWidth && depthY < coordinateMapping.depthHeight else { continue }
                
                let depthOffset = depthY * pixelBuffers.depthBytesPerRow + depthX * MemoryLayout<Float32>.size
                let depthPointer = pixelBuffers.depthBaseAddress.advanced(by: depthOffset).assumingMemoryBound(to: Float32.self)
                let depthValue = depthPointer.pointee
                
                if depthValue > 0.1 && depthValue < 10.0 {
                    let depthBin = Int(depthValue * 10)
                    depthHistogram[depthBin, default: 0] += 1
                }
            }
        }
        
        let subjectDepthBin = depthHistogram.max(by: { $0.value < $1.value })?.key ?? 0
        return (Float(subjectDepthBin) / 10.0 - 0.1)...(Float(subjectDepthBin) / 10.0 + 0.1)
    }
    
    private func analyzeBrightnessAtDepth(coordinateMapping: CoordinateMapping, 
                                        pixelBuffers: PixelBuffers, 
                                        subjectDepthRange: ClosedRange<Float>) -> BrightnessResults {
        var totalBrightness: Float = 0.0
        var validPixels = 0
        var foregroundBrightness: Float = 0.0
        var foregroundPixels = 0
        
        for coordinateY in coordinateMapping.centerY..<(coordinateMapping.centerY + coordinateMapping.centerHeight) {
            guard coordinateY < coordinateMapping.imageHeight else { break }
            
            for coordinateX in coordinateMapping.centerX..<(coordinateMapping.centerX + coordinateMapping.centerWidth) {
                guard coordinateX < coordinateMapping.imageWidth else { break }
                
                let depthX = Int(Float(coordinateX) * coordinateMapping.scaleX)
                let depthY = Int(Float(coordinateY) * coordinateMapping.scaleY)
                
                guard depthX < coordinateMapping.depthWidth && depthY < coordinateMapping.depthHeight else { continue }
                
                let depthOffset = depthY * pixelBuffers.depthBytesPerRow + depthX * MemoryLayout<Float32>.size
                let depthPointer = pixelBuffers.depthBaseAddress.advanced(by: depthOffset).assumingMemoryBound(to: Float32.self)
                let depthValue = depthPointer.pointee
                
                let imageOffset = coordinateY * pixelBuffers.imageBytesPerRow + coordinateX * 4
                let imagePointer = pixelBuffers.imageBaseAddress.advanced(by: imageOffset)
                let blue = Float(imagePointer.load(as: UInt8.self)) / 255.0
                let green = Float(imagePointer.advanced(by: 1).load(as: UInt8.self)) / 255.0
                let red = Float(imagePointer.advanced(by: 2).load(as: UInt8.self)) / 255.0
                
                let brightness = 0.299 * red + 0.587 * green + 0.114 * blue
                totalBrightness += brightness
                validPixels += 1
                
                if subjectDepthRange.contains(depthValue) {
                    foregroundBrightness += brightness
                    foregroundPixels += 1
                }
            }
        }
        
        return BrightnessResults(totalBrightness: totalBrightness, validPixels: validPixels,
                               foregroundBrightness: foregroundBrightness, foregroundPixels: foregroundPixels)
    }
    
    private func calculateFinalBrightness(from results: BrightnessResults) -> Float {
        guard results.validPixels > 0 else { return 0.5 }
        
        let averageBrightness = results.totalBrightness / Float(results.validPixels)
        
        if results.foregroundPixels > results.validPixels / 4 {
            let averageForegroundBrightness = results.foregroundBrightness / Float(results.foregroundPixels)
            let brightnessDifference = averageForegroundBrightness - averageBrightness
            
            if brightnessDifference > 0.1 {
                let result = 0.85 * averageForegroundBrightness + 0.15 * averageBrightness
                print("LiDAR Brightness Analysis - Foreground: \(averageForegroundBrightness), Overall: \(averageBrightness), Final: \(result)")
                return result
            } else {
                let result = 0.7 * averageForegroundBrightness + 0.3 * averageBrightness
                print("LiDAR Brightness Analysis - Standard - Foreground: \(averageForegroundBrightness), Overall: \(averageBrightness), Final: \(result)")
                return result
            }
        } else {
            print("LiDAR Brightness Analysis - Not enough foreground pixels, using overall: \(averageBrightness)")
            return averageBrightness
        }
    }
    
    func analyzeBrightnessWithDepth(from pixelBuffer: CVPixelBuffer, depthData: AVDepthData) -> Float {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let depthMap = depthData.depthDataMap
        
        guard let coordinateMapping = setupBrightnessAnalysisCoordinates(ciImage: ciImage, depthMap: depthMap),
              let pixelBuffers = lockPixelBuffers(pixelBuffer: pixelBuffer, depthMap: depthMap) else {
            return analyzeBrightness(from: pixelBuffer)
        }
        
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
            CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
        }
        
        let subjectDepthRange = findSubjectDepthRange(coordinateMapping: coordinateMapping, pixelBuffers: pixelBuffers)
        let brightnessResults = analyzeBrightnessAtDepth(coordinateMapping: coordinateMapping, 
                                                       pixelBuffers: pixelBuffers, 
                                                       subjectDepthRange: subjectDepthRange)
        
        return calculateFinalBrightness(from: brightnessResults)
    }
    
    func setupLiDARIfAvailable() {
        // Look up the LiDAR camera
        guard let device = AVCaptureDevice.default(.builtInLiDARDepthCamera, for: .video, position: .back) else {
            print("LiDAR device unavailable")
            isLiDARAvailable = false
            return
        }
        
        do {
            let depthInput = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(depthInput) {
                session.addInput(depthInput)
                
                let depthOutput = AVCaptureDepthDataOutput()
                depthOutput.isFilteringEnabled = false
                depthOutput.setDelegate(self, callbackQueue: DispatchQueue(label: "depthQueue"))
                
                if session.canAddOutput(depthOutput) {
                    session.addOutput(depthOutput)
                    self.depthDataOutput = depthOutput
                    isLiDARAvailable = true
                    print("LiDAR setup successful")
                } else {
                    print("Cannot add depth output")
                    isLiDARAvailable = false
                }
            } else {
                print("Cannot add depth input")
                isLiDARAvailable = false
            }
        } catch {
            print("LiDAR setup failed: \(error)")
            isLiDARAvailable = false
        }
    }
    
    func analyzeLiDARDepth(from depthData: AVDepthData) -> (averageDepth: Float, depthVariance: Float) {
        let depthMap = depthData.depthDataMap
        
        // Get the dimensions of the depth map
        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap) else {
            return (0.0, 0.0)
        }
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)
        
        // Define center region (30% to 70% of the image)
        let centerX = Int(Float(width) * 0.3)
        let centerY = Int(Float(height) * 0.3)
        let centerWidth = Int(Float(width) * 0.4)
        let centerHeight = Int(Float(height) * 0.4)
        
        var depthValues: [Float] = []
        var totalDepth: Float = 0.0
        var validPixels = 0
        
        // Sample depth values from the center region
        for coorY in centerY..<(centerY + centerHeight) {
            guard coorY < height else { break }
            
            for coorX in centerX..<(centerX + centerWidth) {
                guard coorX < width else { break }
                
                let pixelOffset = coorY * bytesPerRow + coorX * MemoryLayout<Float32>.size
                let depthPointer = baseAddress.advanced(by: pixelOffset).assumingMemoryBound(to: Float32.self)
                let depthValue = depthPointer.pointee
                
                // Filter out invalid depth values (usually 0 or very large numbers)
                if depthValue > 0.1 && depthValue < 10.0 {
                    depthValues.append(depthValue)
                    totalDepth += depthValue
                    validPixels += 1
                }
            }
        }
        
        guard validPixels > 0 else {
            return (0.0, 0.0)
        }
        
        let averageDepth = totalDepth / Float(validPixels)
        
        // Calculate variance to measure depth consistency
        var variance: Float = 0.0
        for depth in depthValues {
            let diff = depth - averageDepth
            variance += diff * diff
        }
        variance /= Float(validPixels)
        
        return (averageDepth, variance)
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.lastSampleBuffer = sampleBuffer
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let currentTime = CACurrentMediaTime()
        if currentTime - lastBrightnessCheck >= brightnessCheckInterval {
            lastBrightnessCheck = currentTime
            
            let brightness: Float
            let isTooDark: Bool
            
            // Use LiDAR-enhanced brightness analysis if available
            if isLiDARAvailable, let depthData = lastDepthData {
                brightness = analyzeBrightnessWithDepth(from: pixelBuffer, depthData: depthData)
                
                // For LiDAR analysis, we also need to check if we can get foreground vs background brightness
                let standardBrightness = analyzeBrightness(from: pixelBuffer)
                let adaptiveThreshold = getAdaptiveBrightnessThreshold(foregroundBrightness: brightness, backgroundBrightness: standardBrightness)
                
                isTooDark = brightness < adaptiveThreshold
                print("Using LiDAR-enhanced brightness: \(brightness), Standard: \(standardBrightness), Adaptive threshold: \(adaptiveThreshold)")
            } else {
                brightness = analyzeBrightness(from: pixelBuffer)
                isTooDark = brightness < brightnessThreshold
                print("Using standard brightness analysis: \(brightness)")
            }
            
            print("Brightness threshold: \(brightnessThreshold), Is too dark: \(isTooDark)")
            
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

extension CameraService: AVCaptureDepthDataOutputDelegate {
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection) {
        self.lastDepthData = depthData
        
        let currentTime = CACurrentMediaTime()
        if currentTime - lastDepthCheck >= depthCheckInterval {
            lastDepthCheck = currentTime
            
            let depthAnalysis = analyzeLiDARDepth(from: depthData)
            
            // You can add delegate methods to handle depth data if needed
            // For now, this stores the depth data for potential future use
            print("Average depth: \(depthAnalysis.averageDepth)m, Variance: \(depthAnalysis.depthVariance)")
        }
    }
    
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, 
                         didDrop depthData: AVDepthData, 
                         timestamp: CMTime, 
                         connection: AVCaptureConnection, 
                         reason: AVCaptureOutput.DataDroppedReason) {
        print("Depth data dropped: \(reason)")
    }
}
