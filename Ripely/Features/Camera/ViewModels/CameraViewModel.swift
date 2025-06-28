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
    @Published var errorMessage: String?
    @Published var isSheetOpened = false
    @Published var selectedPhotoItem: PhotosPickerItem? = nil
    @Published var isProcessing = false
    @Published var isTooDark = false
    @Published var showCropper = false
    @Published var selectedUIImage: UIImage? = nil

    
    private let cameraService: CameraService
    let photoProcessingService: PhotoProcessingServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        cameraService: CameraService = CameraService(),
        photoProcessingService: PhotoProcessingServiceProtocol = PhotoProcessingService()
    ) {
        self.cameraService = cameraService
        self.photoProcessingService = photoProcessingService
        self.cameraService.delegate = self
        
        setupPhotoItemObserver()
    }
    
    // MARK: - Camera Functions
    func setupCamera(in view: UIView) {
        cameraService.setupCamera(in: view)
    }
    
    func captureImage() {
        guard capturedResult == nil, !isProcessing else {
            print("Capture already in progress or result exists.")
            return
        }
        
        isProcessing = true
        cameraService.captureImage(cropRect: cropRectInView)
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
        cameraService.toggleTorch()
    }
    
    // MARK: - Photo Processing Functions
    private func setupPhotoItemObserver() {
        $selectedPhotoItem
            .compactMap { $0 }
            .sink { [weak self] item in
                self?.processPhotoItem(item)
            }
            .store(in: &cancellables)
    }
    
    private func processPhotoItem(_ item: PhotosPickerItem) {
        guard !isProcessing else { return }

        isProcessing = true
        errorMessage = nil

        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    await MainActor.run {
                        self.isProcessing = false
                        self.errorMessage = "Invalid image format."
                    }
                    return
                }

                await MainActor.run {
                    self.selectedUIImage = image
                    self.showCropper = true
                }
            } catch {
                await MainActor.run {
                    self.isProcessing = false
                    self.errorMessage = "Failed to load image: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Result Handling
    private func handlePredictionSuccess(_ result: PredictionResult) {
        capturedResult = result
        showSummary = true
    }
    
    private func handlePredictionError(_ error: Error) {
        errorMessage = error.localizedDescription
        // Reset photo item to allow retry
        selectedPhotoItem = nil
    }
    
    func resetCapture() {
        capturedResult = nil
        showSummary = false
        selectedPhotoItem = nil
        isProcessing = false
        errorMessage = nil
    }
    
    // MARK: - Overlay Text
    var overlayText: String {
        return isTooDark ?
            "Too dark, use flash or change locations." :
            "Place one clear apple in frame. Avoid blur and background apples."
    }
}

// MARK: - CameraServiceDelegate
extension CameraViewModel: CameraServiceDelegate {
    func cameraService(_ service: CameraService, didOutput prediction: String) {
        livePrediction = prediction
    }
    
    func cameraService(_ service: CameraService, didCaptureImage image: UIImage) {
        photoProcessingService.processRawImage(image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessing = false

                switch result {
                case .success(let predictionResult):
                    self?.handlePredictionSuccess(predictionResult)
                case .failure(let error):
                    self?.handlePredictionError(error)
                }
            }
        }
    }
    
    func cameraService(_ service: CameraService, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isProcessing = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    func cameraService(_ service: CameraService, didUpdateBrightness isTooDark: Bool) {
        self.isTooDark = isTooDark
    }
}
