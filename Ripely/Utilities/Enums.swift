//
//  Enums+Ext.swift
//  Ripely
//
//  Created by Ferdinand Lunardy on 30/08/25.
//
import Foundation

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

enum CameraError: Error {
    case setupFailed
    case captureError
    case imageProcessingFailed
    case croppingFailed
    case predictionFailed
}

enum MLError: Error {
    case modelNotLoaded
    case predictionFailed
    case imageProcessingFailed
}

enum PhotoStatus {
    case correct
    case wrong
}
