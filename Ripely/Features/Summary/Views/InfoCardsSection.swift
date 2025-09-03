//
//  InfoCardsSection.swift
//  Ripely
//
//  Created by GitHub Copilot on 03/09/25.
//
import SwiftUI

struct InfoCardsSection: View {
    let viewModel: SummaryViewModel
    
    // UIDevice Check
    private var isIpad: Bool { UIDevice.current.isIpad }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .center) {
                    viewModel.appleInfo.characteristics.firstIcon
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: isIpad ? 150 : 50,
                            height: isIpad ? 150 : 50
                        )
                        .padding()
                    
                    Spacer()
                    
                    Text(viewModel.appleInfo.characteristics.oneDescription)
                        .font(.caption2)
                        .foregroundColor(
                            viewModel.appleInfo.characteristics.onePrimaryColor
                        )
                }
                .padding(16)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .aspectRatio(1, contentMode: .fit)
                .background(
                    viewModel.appleInfo.characteristics.onePrimaryColor.opacity(
                        0.1
                    )
                )
                .cornerRadius(16)

                VStack(alignment: .center) {
                    viewModel.appleInfo.characteristics.secondIcon
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: isIpad ? 150 : 50,
                            height: isIpad ? 150 : 50
                        )
                        .padding()
                    
                    Spacer()
                    
                    Text(viewModel.appleInfo.characteristics.twoDescription)
                        .font(.caption2)
                        .foregroundColor(
                            viewModel.appleInfo.characteristics.twoPrimaryColor
                        )
                }
                .padding(16)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .background(
                    viewModel.appleInfo.characteristics.twoPrimaryColor.opacity(
                        0.1
                    )
                )
                .cornerRadius(16)

                VStack(alignment: .center) {
                    viewModel.appleInfo.characteristics.thirdIcon
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: isIpad ? 150 : 50,
                            height: isIpad ? 150 : 50
                        )
                        .padding()
                    
                    Spacer()
                    
                    viewModel.appleInfo.characteristics.threeDescription
                        .font(.caption2)
                        .foregroundColor(
                            viewModel.appleInfo.characteristics
                                .threePrimaryColor
                        )
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .top)
                }
                .padding(16)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .background(
                    viewModel.appleInfo.characteristics.threePrimaryColor
                        .opacity(0.1)
                )
                .cornerRadius(16)
            }
        }
    }
}

#Preview {
    InfoCardsSection(
        viewModel: SummaryViewModel(result: PredictionResult(
            image: UIImage(named: "apple"),
            label: "ripe apple",
            confidence: 0.92
        ))
    )
}
