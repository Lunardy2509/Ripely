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
    
    // Environment properties to handle the device layout and size
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // UIDevice Checks
    private let isIpad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    private let isIPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    
    // UIScreen
    private var UIWidth: CGFloat = UIScreen.main.bounds.width
    private var UIHeight: CGFloat = UIScreen.main.bounds.height

    private var viewModel: SummaryViewModel {
        SummaryViewModel(result: result)
    }

    init(result: PredictionResult, isPresented: Binding<Bool>) {
        self.result = result
        self._isPresented = isPresented
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Scrollable content
                ScrollView {
                    VStack(spacing: 20) {
                        // Apple Image
                        if let image = result.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: UIWidth - 32,
                                    height: UIHeight - 500
                                )
                                .clipped()
                                .cornerRadius(16)
                                .padding(.horizontal, 16)
                        }

                        // Apple Status Section
                        ApplePredictionResultView(viewModel: viewModel)
                            .padding(.horizontal, 16)

                        // Info Cards Section
                        infoCardsSection.padding(.horizontal, 16)

                        // After Slicing Section
                        detailSection

                        // Tips Section
                        tipsSection
                    }
                    .padding(.bottom, 16)  // Add bottom padding to avoid button overlap
                }

                // Fixed bottom button
                VStack(spacing: 0) {
                    Divider()

                    scanAnotherButton
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(.aBackgroundPrimary)
                }
            }
            .navigationTitle("Apple Detail")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Customize the default back button
                    Button(action: {
                        isPresented = false
                    }, label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.aAccentGreen)
                            Text("Scan")
                                .foregroundColor(.aAccentGreen)
                        }
                        .padding(10)
                    })
                    .padding(.leading, -10)
                }
            }
        }
    }

    private var infoCardsSection: some View {
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

    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            HStack(alignment: .top, spacing: 8) {
                Text(viewModel.appleInfo.detail.detailTitle)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.aTextPrimary)
            }

            // Description
            Text(viewModel.appleInfo.detail.detailDescription)
                .font(.footnote)
                .foregroundColor(.aTextPrimary)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.aBackgroundSecondary)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(.aStroke)
        )
        .padding(.horizontal, 16)
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Body/Emphasized
            Text("Bonus Tip")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.aTextPrimary)

            HStack(alignment: .center, spacing: 12) {
                Image(viewModel.appleInfo.tips.tipsIcon)
                    .frame(width: 40, height: 40)

                // Caption1/Regular
                Text(viewModel.appleInfo.tips.tipsLabel)
                    .font(.caption)
                    .foregroundColor(.aTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.aBackgroundSecondary)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(.aStroke)
        )
        .padding(.horizontal, 16)
    }

    private var scanAnotherButton: some View {
        Button(action: {
            isPresented = false
        }, label: {
            Text("Scan Another")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.aButtonGreen)
                .cornerRadius(12)
        })
    }

    private func getStatusText() -> String {
        switch viewModel.ripenessState {
        case .ripe: return "Ripe"
        case .unripe: return "Unripe"
        case .overripe: return "Overripe"
        case .notApple: return "Unknown"
        case .none: return "Unknown"
        }
    }

    private func getStatusDescription() -> String {
        switch viewModel.ripenessState {
        case .ripe:
            return "Consume soon for best taste, store in the fridge if needed."
        case .unripe: return "Wait a few more days before consuming."
        case .overripe: return "This apple is best consumed immediately."
        case .notApple: return "This doesn't appear to be an apple."
        case .none: return "Unable to determine apple status."
        }
    }
}

// Supporting Views
struct AppleInfoCard: View {
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
