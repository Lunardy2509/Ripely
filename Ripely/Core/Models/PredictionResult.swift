//
//  PredictionResult.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//
import UIKit

struct PredictionResult {
    let image: UIImage?
    let label: String
    let confidence: Double
    let timestamp: Date
    
    init(image: UIImage? = nil, label: String = "", confidence: Double = 0.0) {
        self.image = image
        self.label = label
        self.confidence = confidence
        self.timestamp = Date()
    }
}
