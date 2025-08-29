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
    case overripe = "rotten apple"
    case notApple = "not apple"
    
    struct DisplayInfo {
        var title: String
        var description: String
        var color: String
    }

    var displayInfo: DisplayInfo {
        switch self {
        case .unripe:
            return DisplayInfo(title: "Belum Matang", description: "Apel masih keras dan belum manis", color: "orange")
        case .ripe:
            return DisplayInfo(title: "Matang", description: "Siap dikonsumsi, rasa manis", color: "green")
        case .overripe:
            return DisplayInfo(title: "Terlalu Matang", description: "Apel mungkin terlalu lunak", color: "brown")
        case .notApple:
            return DisplayInfo(title: "Tidak Dikenal", description: "Tidak bisa mendeteksi kondisi apel", color: "gray")
        }
    }
    
    static func from(rawLabel: String) -> AppleRipenessState? {
        let lowercased = rawLabel.lowercased()
        return AppleRipenessState.allCases.first { lowercased.hasPrefix($0.rawValue) }
    }
}
