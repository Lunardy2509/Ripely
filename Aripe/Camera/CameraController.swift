import Foundation
import UIKit

class CameraController: ObservableObject {
    var coordinator: CameraView.Coordinator?
    
    func toggleTorch() {
        coordinator?.toggleTorch()
    }
    
    func captureImage(cropRectInView: CGRect, completion: @escaping (UIImage?, String, Double) -> Void) {
        coordinator?.captureStillImage(cropRectInView: cropRectInView, completion: completion)
    }
}

class PredictionResult: ObservableObject {
    @Published var image: UIImage?
    @Published var label: String = ""
    @Published var confidence: Double = 0.0
}

func extractCleanLabel(from rawLabel: String) -> String {
    let knownLabels = ["unripe apple", "ripe apple", "rotten apple", "not apple"]
    let lowercased = rawLabel.lowercased()
    
    for label in knownLabels {
        if lowercased.hasPrefix(label) {
            return label
        }
    }
    return rawLabel
}
