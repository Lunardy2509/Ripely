//
//  CameraView.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//
import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    @ObservedObject var viewModel: CameraViewModel
    
    func makeUIView(context: Context) -> CameraHostView {
        let hostView = CameraHostView()
        hostView.backgroundColor = .black
        hostView.cameraService = viewModel.cameraService
        viewModel.setupCamera(in: hostView)
        return hostView
    }
    
    func updateUIView(_ uiView: CameraHostView, context: Context) {
        // Handle any updates if needed
        uiView.cameraService = viewModel.cameraService
    }
}

final class CameraHostView: UIView {
    weak var cameraService: CameraService?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update preview layer frame when view bounds change
        if let previewLayer = layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = bounds
        }
        
        // Also notify camera service about the frame change
        cameraService?.updatePreviewLayerFrame(with: bounds)
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        // Re-setup orientation when moving to new window (important for iPad multitasking)
        if newWindow != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let previewLayer = self.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
                    previewLayer.frame = self.bounds
                }
                self.cameraService?.updatePreviewLayerFrame(with: self.bounds)
            }
        }
    }
}
