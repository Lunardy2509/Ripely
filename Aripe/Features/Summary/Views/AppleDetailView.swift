//
//  AppleDetailView.swift
//  Aripe
//
//  Created by Jerry Febriano on 17/06/25.
//

import SwiftUI

struct AppleDetailView: View {
    let result: PredictionResult
    @Binding var isPresented: Bool
    @State private var navigateToDetail = false

    private var viewModel: SummaryViewModel {
        SummaryViewModel(result: result)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Apple Image
                    if let image = result.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(16)
                            .padding(.horizontal, 16)
                    }

                    // Apple Status Section
                    appleStatusSection.padding(.horizontal, 16)

                    // Info Cards Section
                    infoCardsSection

                    // After Slicing Section
                    afterSlicingSection

                    // Tips Section
                    tipsSection

                    // Scan Another Button
                    scanAnotherButton
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Apple Detail")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
            .background(Color.white)
        }
    }

    private var appleStatusSection: some View {
        let appleInfo = viewModel.appleInfo

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 16) {
                // Dynamic apple image based on state
                Image(appleInfo.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 98, height: 98)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        // Dynamic title
                        Text(appleInfo.title)
                            .font(.headline)
                            .foregroundColor(Constants.NeutralBlack)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .topLeading
                            )

                        // Dynamic characteristics
                        Text(appleInfo.characteristics)
                            .font(.footnote)
                            .foregroundColor(Color.gray)
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
                    .frame(height: 28, alignment: .center)
                    .background(appleInfo.backgroundColor)
                    .cornerRadius(24)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(
            color: Constants.MiscellaneousFloatingTabPillShadow,
            radius: 5,
            x: 0,
            y: 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.95, green: 0.95, blue: 0.95), lineWidth: 1)
        )
    }

    private var infoCardsSection: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .center) {
                // Space Between
                Image("ripe_candy")
                Spacer()
                // Alternating Views and Spacers
                // Caption2/Regular
                Text("Sweet")
                    .font(.caption2)
                    .foregroundColor(Constants.PrimaryBrown)
            }
            .padding(16)
            .frame(width: 113.33334, height: 117, alignment: .center)
            .background(Color(red: 0.57, green: 0.19, blue: 0.03).opacity(0.1))
            .cornerRadius(16)

            VStack(alignment: .center) {
                // Space Between
                Image("thermometer")
                Spacer()
                // Alternating Views and Spacers
                VStack(alignment: .leading, spacing: 4) {  // Caption2/Emphasized
                    Text("Ideal Temp:")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.PrimaryPrimaryGreen)
                        .frame(maxWidth: .infinity, alignment: .top)

                    // Caption2/Regular
                    Text("4–20°C")
                        .font(.caption2)
                        .foregroundColor(
                            Constants.PrimaryPrimaryGreen
                        )
                        .frame(maxWidth: .infinity, alignment: .top)
                }
                .padding(0)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .frame(width: 113.33334, height: 117, alignment: .center)
            .background(Color(red: 0.23, green: 0.5, blue: 0.19).opacity(0.1))
            .cornerRadius(16)

            VStack(alignment: .center) {
                // Space Between
                Image("fridge")
                Spacer()
                // Alternating Views and Spacers
                // Caption2/Regular
                Text("Keep in fridge")
                    .font(.caption2)
                    .foregroundColor(Constants.PrimaryPrimaryGreen)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
            .padding(16)
            .frame(width: 113.33334, height: 117, alignment: .center)
            .background(Color(red: 0.23, green: 0.5, blue: 0.19).opacity(0.1))
            .cornerRadius(16)
        }
    }

    private var afterSlicingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Body/Emphasized with bullet
            HStack(alignment: .top, spacing: 8) {
                Text("After slicing the apple,")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.NeutralBlack)
            }
            
            // First bullet point
            VStack(spacing:0) {
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 4, height: 4)
                        .padding(.top, 4)
                    
                    Text("Store in a sealed container inside the fridge.")
                        .font(.footnote)
                        .foregroundColor(Constants.NeutralBlack)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            
            // Second bullet point
            HStack(alignment: .top, spacing: 8) {
                Circle()
                    .fill(Color.black)
                    .frame(width: 4, height: 4)
                    .padding(.top, 4)
                
                Text("Soak in lemon water or salt water to slow down the oxidation rate for a while.")
                    .font(.footnote)
                    .foregroundColor(Constants.NeutralBlack)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Constants.NeutralWhite)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Constants.NeutralLightGray, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Body/Emphasized
            Text("Tips")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(Constants.NeutralBlack)

            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        Image("banana")
                            .frame(width: 40, height: 40)
                        Image("avocado")
                            .frame(width: 40, height: 40)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding(0)
                    
                    
                    // Caption1/Regular
                    Text(
                        "Avoid placing apples beside bananas or avocados. The ripened apple would oxidize faster."
                    )
                    .font(.caption)
                    .foregroundColor(Constants.NeutralBlack)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .padding(0)
                .frame(maxWidth: .infinity, alignment: .topLeading)

                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 1, height: 112)
                    .background(Constants.NeutralLightGray)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 10) {
                        Image("paper_bag")
                            .frame(width: 26.66667, height: 30)
                        Image(systemName: "x.circle.fill")
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 5)

                    // Caption1/Regular
                    Text(
                        "Utilize a paper bag to speed up the ripening rate if you want to eat it quickly."
                    )
                    .font(.caption)
                    .foregroundColor(Constants.NeutralBlack)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .padding(0)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Constants.NeutralWhite)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Constants.NeutralLightGray, lineWidth: 1)
        )
        .padding(.horizontal, 16)

    }

    private var scanAnotherButton: some View {
        Button(action: {
            isPresented = false
        }) {
            Text("Scan Another")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.aPrimaryGreen)
                .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private func getStatusText() -> String {
        switch viewModel.ripenessState {
        case .ripe: return "Ripe"
        case .unripe: return "Unripe"
        case .rotten: return "Rotten"
        case .notApple: return "Unknown"
        case .none: return "Unknown"
        }
    }

    private func getStatusDescription() -> String {
        switch viewModel.ripenessState {
        case .ripe:
            return "Consume soon for best taste, store in the fridge if needed."
        case .unripe: return "Wait a few more days before consuming."
        case .rotten: return "This apple is no longer safe to consume."
        case .notApple: return "This doesn't appear to be an apple."
        case .none: return "Unable to determine apple status."
        }
    }
}

// Supporting Views
struct InfoCard: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconColor: Color
    let backgroundColor: Color

    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        iconColor: Color,
        backgroundColor: Color
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }

            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.subheadline)
                .foregroundColor(.primary)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct TipCard: View {
    let icon: String
    let iconColor: Color
    let text: String
    let isWarning: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }

                if isWarning {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 20, height: 20)

                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                            .foregroundColor(.red)
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 20, height: 20)

                        Image(systemName: "checkmark")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                    }
                }

                Spacer()
            }

            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    AppleDetailView(
        result: PredictionResult(
            image: UIImage(named: "apple"),
            label: "ripe apple",
            confidence: 0.92
        ),
        isPresented: .constant(true)
    )
}
