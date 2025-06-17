//
//  CameraViewModel 2.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//


import SwiftUI
import PhotosUI
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
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    
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
    
    func resetCapture() {
        capturedResult = nil
        showSummary = false
    }
    
    func loadImageFromPicker() async {
        guard let item = selectedPhotoItem else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                await MainActor.run {
                    self.selectedImage = uiImage
                    self.capturedResult = PredictionResult(image: uiImage, label: "From Gallery", confidence: 1.0)
                    self.showSummary = true
                }
            } else {
                await MainActor.run {
                    self.errorMessage = "Invalid image format."
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load image: \(error.localizedDescription)"
            }
        }
    }
}

extension CameraViewModel: CameraServiceDelegate {
    func cameraService(_ service: CameraService, didOutput prediction: String) {
        livePrediction = prediction
    }
    
    func cameraService(_ service: CameraService, didCaptureImage result: PredictionResult) {
        DispatchQueue.main.async {
            self.capturedResult = result
            self.showSummary = true
        }
    }
    
    func cameraService(_ service: CameraService, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
    }
}


