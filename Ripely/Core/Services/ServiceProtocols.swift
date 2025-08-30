//
//  CameraServiceProtocol.swift
//  Ripely
//
//  Created by Ferdinand Lunardy on 30/08/25.
//
import SwiftUI
import PhotosUI

protocol CameraServiceDelegate: AnyObject {
    func cameraService(_ service: CameraService, didOutput prediction: String)
    func cameraService(_ service: CameraService, didCaptureImage image: UIImage)
    func cameraService(_ service: CameraService, didFailWithError error: Error)
    func cameraService(_ service: CameraService, didUpdateBrightness isTooDark: Bool)
}

protocol MLServiceProtocol {
    func predict(from image: UIImage, completion: @escaping (Result<PredictionResult, Error>) -> Void)
    func predict(from pixelBuffer: CVPixelBuffer, completion: @escaping (Result<String, Error>) -> Void)
}

protocol PhotoProcessingServiceProtocol {
    func processImage(_ image: UIImage, cropRect: CGRect, completion: @escaping (Result<PredictionResult, Error>) -> Void)
    func processRawImage(_ image: UIImage, completion: @escaping (Result<PredictionResult, Error>) -> Void)
    func loadAndProcessImage(from item: PhotosPickerItem, completion: @escaping (Result<PredictionResult, Error>) -> Void)
}

protocol StorageServiceProtocol {
    var hasSeenOnboarding: Bool { get set }
}
