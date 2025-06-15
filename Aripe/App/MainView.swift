import SwiftUI

struct MainView: View {
    @StateObject private var cameraController = CameraController()
    @StateObject private var result = PredictionResult()

    @State private var selectedImage: UIImage?
    @State private var showPhotoPicker = false
    @State private var navigateToSummary = false
    @State private var livePrediction = ""
    @State private var cropRectInView: CGRect = .zero
    
    var body: some View {
        ZStack {
            CameraView(prediction: $livePrediction, controller: cameraController)
                .coordinateSpace(name: "cameraPreview")

            CameraOverlayView(
                onCapture: {
                    cameraController.captureImage(cropRectInView: cropRectInView) { image, label, confidence in
                        guard result.image == nil else {
                            print("Prediction already exists.")
                            return
                        }
                        result.image = image
                        result.label = extractCleanLabel(from: livePrediction)
                        result.confidence = confidence
                                                
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            navigateToSummary = true
                        }
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
//        .navigationTitle("Scan")
//        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $navigateToSummary, onDismiss: {
            result.image = nil
            result.label = ""
            result.confidence = 0.0
        }) {
            SummaryView(
                result: result,
                navigateToSummary: $navigateToSummary
            )
            .presentationDetents([.fraction(0.80), .fraction(0.99)])
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPickerView(selectedImage: $selectedImage)
        }
    }
}
