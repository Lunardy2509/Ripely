//
//  MLServiceProtocol.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//


import Foundation
import Vision
import CoreML
import UIKit

protocol MLServiceProtocol {
    func predict(from image: UIImage, completion: @escaping (Result<PredictionResult, Error>) -> Void)
    func predict(from pixelBuffer: CVPixelBuffer, completion: @escaping (Result<String, Error>) -> Void)
}

class MLService: MLServiceProtocol {
    private var model: VNCoreMLModel?
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        guard let coreMLModel = try? AppleRipenessModel(configuration: MLModelConfiguration()).model,
              let visionModel = try? VNCoreMLModel(for: coreMLModel) else {
            print("❌ Failed to load CoreML model.")
            return
        }
        self.model = visionModel
    }
    
    func predict(from image: UIImage, completion: @escaping (Result<PredictionResult, Error>) -> Void) {
        guard let model = model,
              let cgImage = image.cgImage else {
            completion(.failure(MLError.modelNotLoaded))
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion(.failure(MLError.predictionFailed))
                return
            }
            
            let result = PredictionResult(
                image: image,
                label: topResult.identifier,
                confidence: Double(topResult.confidence)
            )
            completion(.success(result))
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
    
    func predict(from pixelBuffer: CVPixelBuffer, completion: @escaping (Result<String, Error>) -> Void) {
        guard let model = model else {
            completion(.failure(MLError.modelNotLoaded))
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation],
                  let bestResult = results.first else {
                completion(.failure(MLError.predictionFailed))
                return
            }
            
            let predictionText = "\(bestResult.identifier) (\(Int(bestResult.confidence * 100))%)"
            completion(.success(predictionText))
        }
        
        request.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
}

enum MLError: Error {
    case modelNotLoaded
    case predictionFailed
    case imageProcessingFailed
}
