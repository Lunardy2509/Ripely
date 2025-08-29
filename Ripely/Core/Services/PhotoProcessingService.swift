//
//  PhotoProcessingServiceProtocol.swift
//  Aripe
//
//  Created by Jerry Febriano on 17/06/25.
//
import UIKit
import PhotosUI
import _PhotosUI_SwiftUI

protocol PhotoProcessingServiceProtocol {
    func processImage(_ image: UIImage, cropRect: CGRect, completion: @escaping (Result<PredictionResult, Error>) -> Void)
    func processRawImage(_ image: UIImage, completion: @escaping (Result<PredictionResult, Error>) -> Void)
    func loadAndProcessImage(from item: PhotosPickerItem, completion: @escaping (Result<PredictionResult, Error>) -> Void)
}

final class PhotoProcessingService: PhotoProcessingServiceProtocol {
    private let mlService: MLServiceProtocol
    init(mlService: MLServiceProtocol = MLService()) {
        self.mlService = mlService
    }
    
    func cropAndFilterImage(_ image: UIImage, cropRect: CGRect, filterName: String = "CIAreaAverage") -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        // Convert UIImage to CIImage
        let ciImage = CIImage(cgImage: cgImage)
        let cropped = ciImage.cropped(to: cropRect)

        // Create and apply filter
        guard let filter = CIFilter(name: filterName) else { return nil }
        filter.setValue(cropped, forKey: kCIInputImageKey)

        let context = CIContext()
        
        // Some filters output another CIImage; others reduce to 1px (like CIAreaAverage)
        guard let outputImage = filter.outputImage,
              let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: outputCGImage)
    }
    
    func processImage(_ image: UIImage, cropRect: CGRect, completion: @escaping (Result<PredictionResult, Error>) -> Void) {
        guard let cropped = cropAndFilterImage(image, cropRect: cropRect, filterName: "CIColorControls") else {
            completion(.failure(PhotoProcessingError.invalidImageFormat))
            return
        }

        mlService.predict(from: cropped) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // Without CropRect
    func processRawImage(_ image: UIImage, completion: @escaping (Result<PredictionResult, Error>) -> Void) {
        mlService.predict(from: image) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func loadAndProcessImage(from item: PhotosPickerItem, completion: @escaping (Result<PredictionResult, Error>) -> Void) {
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    await MainActor.run {
                        completion(.failure(PhotoProcessingError.invalidImageFormat))
                    }
                    return
                }
                
                let centerCrop = CGRect(x: image.size.width * 0.3,
                                        y: image.size.height * 0.3,
                                        width: image.size.width * 0.4,
                                        height: image.size.height * 0.4)
                
                await MainActor.run {
                    self.processImage(image, cropRect: centerCrop, completion: completion)
                }

            } catch {
                await MainActor.run {
                    completion(.failure(PhotoProcessingError.loadingFailed(error)))
                }
            }
        }
    }
}

enum PhotoProcessingError: Error, LocalizedError {
    case invalidImageFormat
    case loadingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidImageFormat:
            return "Invalid image format. Please select a valid image."
        case .loadingFailed(let error):
            return "Failed to load image: \(error.localizedDescription)"
        }
    }
}
