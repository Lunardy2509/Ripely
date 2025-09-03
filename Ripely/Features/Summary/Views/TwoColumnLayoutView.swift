//
//  TwoColumnLayoutView.swift
//  Ripely
//
//  Created by GitHub Copilot on 03/09/25.
//
import SwiftUI

struct TwoColumnLayoutView: View {
    let result: PredictionResult
    let viewModel: SummaryViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Left column: Apple Image
            VStack {
                if let image = result.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .cornerRadius(16)
                        .padding(12)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            .padding(.leading, 8)
            
            // Right column: All details in scrollable view
            ScrollView {
                VStack(spacing: 20) {
                    // Apple Status Section
                    ApplePredictionResultView(viewModel: viewModel)
                    
                    // Info Cards Section - Adjusted for landscape
                    LandscapeInfoCardsSection(viewModel: viewModel)
                    
                    // After Slicing Section
                    LandscapeDetailSection(viewModel: viewModel)
                    
                    // Tips Section
                    LandscapeTipsSection(viewModel: viewModel)
                    
                    // Scan Another Button
                    ScanAnotherButton(isPresented: $isPresented)
                        .padding(.top, 8)
                }
                .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity)
            .padding(.trailing, 8)
        }
        .padding(.top, 16)
    }
}

// MARK: - Landscape Info Cards Section
struct LandscapeInfoCardsSection: View {
    let viewModel: SummaryViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .center, spacing: 8) {
                viewModel.appleInfo.characteristics.firstIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                
                Text(viewModel.appleInfo.characteristics.oneDescription)
                    .font(.caption2)
                    .foregroundColor(viewModel.appleInfo.characteristics.onePrimaryColor)
                    .multilineTextAlignment(.center)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(viewModel.appleInfo.characteristics.onePrimaryColor.opacity(0.1))
            .cornerRadius(12)
            
            VStack(alignment: .center, spacing: 8) {
                viewModel.appleInfo.characteristics.secondIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                
                Text(viewModel.appleInfo.characteristics.twoDescription)
                    .font(.caption2)
                    .foregroundColor(viewModel.appleInfo.characteristics.twoPrimaryColor)
                    .multilineTextAlignment(.center)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(viewModel.appleInfo.characteristics.twoPrimaryColor.opacity(0.1))
            .cornerRadius(12)
            
            VStack(alignment: .center, spacing: 8) {
                viewModel.appleInfo.characteristics.thirdIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                
                viewModel.appleInfo.characteristics.threeDescription
                    .font(.caption2)
                    .foregroundColor(viewModel.appleInfo.characteristics.threePrimaryColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(viewModel.appleInfo.characteristics.threePrimaryColor.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Landscape-specific components without horizontal padding
struct LandscapeDetailSection: View {
    let viewModel: SummaryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.appleInfo.detail.detailTitle)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Token.Color.textPrimary)
            
            Text(viewModel.appleInfo.detail.detailDescription)
                .font(.footnote)
                .foregroundColor(Token.Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .topLeading)
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
    }
}

struct LandscapeTipsSection: View {
    let viewModel: SummaryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bonus Tip")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Token.Color.textPrimary)
            
            HStack(alignment: .center, spacing: 12) {
                Image(viewModel.appleInfo.tips.tipsIcon)
                    .frame(width: 40, height: 40)
                
                Text(viewModel.appleInfo.tips.tipsLabel)
                    .font(.caption)
                    .foregroundColor(Token.Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
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
    }
}

#Preview {
    TwoColumnLayoutView(
        result: PredictionResult(
            image: UIImage(named: "apple"),
            label: "ripe apple",
            confidence: 0.92
        ),
        viewModel: SummaryViewModel(result: PredictionResult(
            image: UIImage(named: "apple"),
            label: "ripe apple",
            confidence: 0.92
        )),
        isPresented: .constant(true)
    )
}
