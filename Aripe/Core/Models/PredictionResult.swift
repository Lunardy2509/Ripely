//
//  PredictionResult.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//

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

enum AppleRipenessState: String, CaseIterable {
    case unripe = "unripe apple"
    case ripe = "ripe apple"
    case overripe = "overripe apple"
    case notApple = "not apple"
    
    var displayInfo: (title: String, description: String, color: String) {
        switch self {
        case .unripe:
            return ("Belum Matang", "Apel masih keras dan belum manis", "orange")
        case .ripe:
            return ("Matang", "Siap dikonsumsi, rasa manis", "green")
        case .overripe:
            return ("Terlalu Matang", "Apel mungkin terlalu lunak", "brown")
        case .notApple:
            return ("Tidak Dikenal", "Tidak bisa mendeteksi kondisi apel", "gray")
        }
    }
    
    static func from(rawLabel: String) -> AppleRipenessState? {
        let lowercased = rawLabel.lowercased()
        return AppleRipenessState.allCases.first { lowercased.hasPrefix($0.rawValue) }
    }
}
