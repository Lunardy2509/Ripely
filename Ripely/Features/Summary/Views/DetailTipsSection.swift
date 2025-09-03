//
//  DetailTipsSection.swift
//  Ripely
//
//  Created by GitHub Copilot on 03/09/25.
//
import SwiftUI

struct DetailSection: View {
    let viewModel: SummaryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            HStack(alignment: .top, spacing: 8) {
                Text(viewModel.appleInfo.detail.detailTitle)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Token.Color.textPrimary)
            }

            // Description
            Text(viewModel.appleInfo.detail.detailDescription)
                .font(.footnote)
                .foregroundColor(Token.Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Token.Color.backgroundSecondary)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Token.Color.stroke)
        )
        .padding(.horizontal, 16)
    }
}

struct TipsSection: View {
    let viewModel: SummaryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Body/Emphasized
            Text("Bonus Tip")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Token.Color.textPrimary)

            HStack(alignment: .center, spacing: 12) {
                Image(viewModel.appleInfo.tips.tipsIcon)
                    .frame(width: 40, height: 40)

                // Caption1/Regular
                Text(viewModel.appleInfo.tips.tipsLabel)
                    .font(.caption)
                    .foregroundColor(Token.Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Token.Color.backgroundSecondary)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Token.Color.stroke)
        )
        .padding(.horizontal, 16)
    }
}

struct ScanAnotherButton: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        Button(action: {
            isPresented = false
        }, label: {
            Text("Scan Another")
                .font(.headline)
                .foregroundColor(Token.Color.regularWhite)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Token.Color.buttonGreen)
                .cornerRadius(12)
        })
    }
}

#Preview {
    VStack(spacing: 20) {
        DetailSection(
            viewModel: SummaryViewModel(result: PredictionResult(
                image: UIImage(named: "apple"),
                label: "ripe apple",
                confidence: 0.92
            ))
        )
        
        TipsSection(
            viewModel: SummaryViewModel(result: PredictionResult(
                image: UIImage(named: "apple"),
                label: "ripe apple",
                confidence: 0.92
            ))
        )
        
        ScanAnotherButton(isPresented: .constant(true))
            .padding(.horizontal, 16)
    }
}
