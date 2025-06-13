import SwiftUI

struct MainView: View {
    @StateObject private var cameraController = CameraController()
    @State private var predictionText: String = "Waiting for prediction..."
    @State private var selectedImage: UIImage?
    @State private var capturedImage: UIImage?
    @State private var capturedPredictionLabel: String = ""
    @State private var capturedConfidence: Double = 0.0
    @State private var showPhotoPicker = false
    @State private var navigateToSummary = false
    @State private var cropRectInView: CGRect = .zero

    var body: some View {
        ZStack {
            CameraView(prediction: $predictionText, controller: cameraController)

            CameraOverlayView(
                onCapture: {
                    cameraController.captureImage(cropRectInView: cropRectInView) { image, label, confidence in
                        capturedImage = image
                        capturedPredictionLabel = label
                        capturedConfidence = confidence
                        navigateToSummary = true
                    }
                },
                onToggleFlash: {
                    cameraController.toggleTorch()
                },
                onOpenGallery: {
                    showPhotoPicker = true
                },
                cropRectInView: $cropRectInView
            )
        }
        .navigationTitle("Scan")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToSummary) {
            SummaryView(
                image: capturedImage,
                predictionLabel: capturedPredictionLabel,
                confidence: capturedConfidence
            )
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(selectedImage: $selectedImage)
        }
    }
}
