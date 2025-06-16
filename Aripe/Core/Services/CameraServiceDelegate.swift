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
    func cameraService(_ service: CameraService, didCaptureImage result: PredictionResult)
    func cameraService(_ service: CameraService, didFailWithError error: Error)
}

class CameraService: NSObject, ObservableObject {
    weak var delegate: CameraServiceDelegate?
    
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var lastSampleBuffer: CMSampleBuffer?
    private let mlService: MLServiceProtocol
    
    init(mlService: MLServiceProtocol = MLService()) {
        self.mlService = mlService
        super.init()
    }
    
    func setupCamera(in view: UIView) {
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
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = UIScreen.main.bounds
        
        DispatchQueue.main.async {
            view.layer.insertSublayer(preview, at: 0)
        }
        
        self.previewLayer = preview
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
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
        
        // Convert crop rect and create cropped image
        let metadataRect = previewLayer.metadataOutputRectConverted(fromLayerRect: cropRect)
        var adjustedCropRect = CGRect(
            x: metadataRect.origin.x * ciImage.extent.width,
            y: (1 - metadataRect.origin.y - metadataRect.height) * ciImage.extent.height,
            width: metadataRect.size.width * ciImage.extent.width,
            height: metadataRect.size.height * ciImage.extent.height
        )
        
        // Apply offset
        adjustedCropRect = adjustedCropRect.offsetBy(dx: Constants.Camera.horizontalOffset, dy: Constants.Camera.verticalOffset)
        adjustedCropRect = adjustedCropRect.intersection(ciImage.extent)
        
        guard let croppedCG = cgImage.cropping(to: adjustedCropRect) else {
            delegate?.cameraService(self, didFailWithError: CameraError.croppingFailed)
            return
        }
        
        let croppedImage = UIImage(cgImage: croppedCG, scale: 1.0, orientation: .right)
        
        mlService.predict(from: croppedImage) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let predictionResult):
                    self.delegate?.cameraService(self, didCaptureImage: predictionResult)
                case .failure(let error):
                    self.delegate?.cameraService(self, didFailWithError: error)
                }
            }
        }
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.lastSampleBuffer = sampleBuffer
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
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