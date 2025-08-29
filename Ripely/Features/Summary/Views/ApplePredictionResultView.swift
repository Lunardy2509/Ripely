//
//  ApplePredictionResultView.swift
//  Aripe
//
//  Created by Jerry Febriano on 17/06/25.
//

import SwiftUI

struct ApplePredictionResultView: View {
    let viewModel: SummaryViewModel
    
    var body: some View {
        let appleInfo = viewModel.appleInfo

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 16) {
                // Dynamic apple image based on state
                appleInfo.imageName
                    .resizable()
                    .scaledToFit()
                    .frame(width: 98, height: 98)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        // Dynamic title
                        Text(appleInfo.title)
                            .font(.headline)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .topLeading
                            )

                        // Dynamic characteristics
                        Text(appleInfo.appleDescription)
                            .font(.footnote)
                            .foregroundColor(.aTextSecondary)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .topLeading
                            )
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(0)

                    // Dynamic consumption advice
                    HStack(alignment: .center, spacing: 10) {
                        Text(appleInfo.consumptionAdvice)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(appleInfo.adviceColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 28,
                        maxHeight: 28,
                        alignment: .center
                    )
                    .background(appleInfo.backgroundColor)
                    .cornerRadius(24)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.aBackgroundSecondary)
        .cornerRadius(16)
        .shadow(
            color: Constants.MiscellaneousFloatingTabPillShadow,
            radius: 5,
            x: 0,
            y: 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.aStroke)
        )
    }
}

#Preview {
    let result = PredictionResult(
        image: .correctApple,
        label: "Correct Apple",
        confidence: 99.5,
    )
    
    ApplePredictionResultView(viewModel: SummaryViewModel(result: result))
}
