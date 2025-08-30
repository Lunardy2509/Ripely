//
//  CropView.swift
//  Aripe
//
//  Created by Ferdinand Lunardy on 18/06/25.
//
import SwiftUI
import TOCropViewController

struct CropView: UIViewControllerRepresentable {
    let image: UIImage
    var onCropped: (UIImage) -> Void

    func makeUIViewController(context: Context) -> TOCropViewController {
        let cropVC = TOCropViewController(image: image)
        cropVC.delegate = context.coordinator
        return cropVC
    }

    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, TOCropViewControllerDelegate {
        let parent: CropView

        init(_ parent: CropView) {
            self.parent = parent
        }

        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
            parent.onCropped(image)
            cropViewController.dismiss(animated: true)
        }

        func cropViewControllerDidCancel(_ cropViewController: TOCropViewController) {
            cropViewController.dismiss(animated: true)
        }
    }
}
