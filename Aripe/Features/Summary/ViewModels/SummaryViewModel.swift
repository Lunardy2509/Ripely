//
//  SummaryViewModel.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//


import SwiftUI

class SummaryViewModel: ObservableObject {
    @Published var result: PredictionResult
    
    init(result: PredictionResult) {
        self.result = result
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy – HH.mm"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: result.timestamp)
    }
    
    var ripenessState: AppleRipenessState? {
        AppleRipenessState.from(rawLabel: result.label)
    }
    
    var isPredictionValid: Bool {
        result.image != nil && ripenessState != nil && result.confidence > 0.0
    }
    
    var confidencePercentage: Int {
        Int(result.confidence * 100)
    }
}