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
    func processImage(_ image: UIImage, completion: @escaping (Result<PredictionResult, Error>) -> Void)
    func loadAndProcessImage(from item: PhotosPickerItem, completion: @escaping (Result<PredictionResult, Error>) -> Void)
}

class PhotoProcessingService: PhotoProcessingServiceProtocol {
    private let mlService: MLServiceProtocol
    
    init(mlService: MLServiceProtocol = MLService()) {
        self.mlService = mlService
    }
    
    func processImage(_ image: UIImage, completion: @escaping (Result<PredictionResult, Error>) -> Void) {
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
                
                await MainActor.run {
                    self.processImage(image, completion: completion)
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
