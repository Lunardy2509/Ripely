//
//  CameraViewModel 2.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//


import SwiftUI
import Combine

class CameraViewModel: ObservableObject {
    @Published var livePrediction = ""
    @Published var isFlashOn = false
    @Published var cropRectInView: CGRect = .zero
    @Published var capturedResult: PredictionResult?
    @Published var showSummary = false
    @Published var showPhotoPicker = false
    @Published var selectedImage: UIImage?
    @Published var errorMessage: String?
    @Published var isSheetOpened = false
    
    private let cameraService: CameraService
    private var cancellables = Set<AnyCancellable>()
    
    init(cameraService: CameraService = CameraService()) {
        self.cameraService = cameraService
        self.cameraService.delegate = self
    }
    
    func setupCamera(in view: UIView) {
        cameraService.setupCamera(in: view)
    }
    
    func captureImage() {
        guard capturedResult == nil else {
            print("Prediction already exists.")
            return
        }
        cameraService.captureImage(cropRect: cropRectInView)
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
        cameraService.toggleTorch()
    }
    
    func openGallery() {
        showPhotoPicker = true
    }
    
    func resetCapture() {
        capturedResult = nil
        showSummary = false
    }
}

extension CameraViewModel: CameraServiceDelegate {
    func cameraService(_ service: CameraService, didOutput prediction: String) {
        livePrediction = prediction
    }
    
    func cameraService(_ service: CameraService, didCaptureImage result: PredictionResult) {
        capturedResult = result
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.showSummary = true
        }
    }
    
    func cameraService(_ service: CameraService, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }
}
