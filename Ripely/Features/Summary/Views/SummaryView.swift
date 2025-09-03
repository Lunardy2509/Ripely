//
//  SummaryView.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//
import SwiftUI

struct SummaryView: View {
    @Binding var isPresented: Bool
    
    @StateObject private var viewModel: SummaryViewModel
    @State private var showAppleDetail = false
    
    @Environment(\.dismiss) private var dismiss
    
    private var isIpad: Bool { UIDevice.current.isIpad }
    private var isIphone: Bool { UIDevice.current.isIphone }
    private var isLandscape: Bool { UIDevice.current.isLandscape }

    init(result: PredictionResult, isPresented: Binding<Bool>) {
        self._viewModel = StateObject(
            wrappedValue: SummaryViewModel(result: result)
        )
        self._isPresented = isPresented
    }

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let shouldUseTwoColumns = isIpad && isLandscape && geometry.size.width > 800
            
            VStack(spacing: 0) {
                headerSection
                
                if shouldUseTwoColumns {
                    // iPad Landscape: Two-column layout
                    HStack(alignment: .top, spacing: 24) {
                        // Left Column: Image + Apple Result
                        VStack(alignment: .leading, spacing: 16) {
                            if viewModel.isPredictionValid {
                                imageSection(geometry: geometry, isTwoColumn: true)
                                ApplePredictionResultView(viewModel: viewModel)
                            } else {
                                errorSection
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Right Column: Apple Detail + Finish Button
                        VStack(spacing: 16) {
                            if viewModel.isPredictionValid && viewModel.ripenessState != .notApple {
                                ScrollView {
                                    AppleDetailView(result: viewModel.result, isPresented: $isPresented)
                                }
                            }
                            
                            finishButton(isTwoColumn: true)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)
                } else {
                    // iPhone and iPad Portrait: Single column layout
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if viewModel.isPredictionValid {
                                imageSection(geometry: geometry, isTwoColumn: false)
                                ApplePredictionResultView(viewModel: viewModel)
                                    .padding(.horizontal, 16)
                                finishButton(isTwoColumn: false)
                            } else {
                                errorSection
                                finishButton(isTwoColumn: false)
                            }
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showAppleDetail) {
            if viewModel.ripenessState != .notApple {
                AppleDetailView(result: viewModel.result, isPresented: $isPresented)
            }
        }
    }

    private var headerSection: some View {
        ZStack {
            Text("Scan Results")
                .font(.title3)
                .fontWeight(.bold)
            HStack {
                Spacer()
               
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Done")
                })
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .padding(.top, 10)
    }
    
    private func getWidth(geometry: GeometryProxy, isTwoColumn: Bool) -> CGFloat {
        if isTwoColumn {
            // For iPad landscape two-column layout
            return (geometry.size.width - 88) / 2 // Half width minus padding
        } else if isIpad {
            return min(geometry.size.width - 64, 600)
        } else {
            return geometry.size.width - 32
        }
    }

    private func getHeight(geometry: GeometryProxy, isTwoColumn: Bool) -> CGFloat {
        if isTwoColumn {
            // For iPad landscape, use smaller height to fit both image and result
            return min(geometry.size.height * 0.35, 280)
        } else if isIpad {
            return min(geometry.size.height * 0.4, 400)
        } else {
            return geometry.size.height - 200
        }
    }
    
    // Safely calculate width with fallback value
    private func getValidWidth(geometry: GeometryProxy, isTwoColumn: Bool) -> CGFloat {
        let width = getWidth(geometry: geometry, isTwoColumn: isTwoColumn)
        return width.isFinite && width > 0 ? width : 100 // Default to 100 if invalid
    }

    // Safely calculate height with fallback value
    private func getValidHeight(geometry: GeometryProxy, isTwoColumn: Bool) -> CGFloat {
        let height = getHeight(geometry: geometry, isTwoColumn: isTwoColumn)
        return height.isFinite && height > 0 ? height : 200 // Default to 200 if invalid
    }
    
    private func imageSection(geometry: GeometryProxy, isTwoColumn: Bool) -> some View {
        Group {
            if let image = viewModel.result.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: getValidWidth(geometry: geometry, isTwoColumn: isTwoColumn),
                        height: getValidHeight(geometry: geometry, isTwoColumn: isTwoColumn)
                    )
                    .clipped()
                    .cornerRadius(16)
                    .frame(maxWidth: .infinity) // Center the image
            }
        }
    }

    private var errorSection: some View {
        VStack(alignment: .center, spacing: 12) {
            Image("not_an_apple")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("Apple not detected")
                .foregroundColor(.aTextPrimary)
                .fontWeight(.semibold)
                .font(.title2)
        }
        .padding()
        .frame(maxWidth: .infinity)
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
        .padding(.horizontal, 16)
    }
    
    private func finishButton(isTwoColumn: Bool) -> some View {
        Button(action: {
            if viewModel.ripenessState != .notApple {
                if isTwoColumn {
                    // In iPad landscape, button action is different since detail is already shown
                    isPresented = false
                } else {
                    showAppleDetail = true
                }
            } else {
                isPresented = false
            }
        }, label: {
            Text(viewModel.ripenessState == .notApple ? "Scan Another" : 
                 (isTwoColumn ? "Scan Another" : "More Detail"))
                .font(.headline)
                .foregroundColor(Token.Color.regularWhite)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.aButtonGreen)
                .cornerRadius(12)
        })
        .padding(.horizontal, isTwoColumn ? 0 : 16)
    }}

// MARK: - Previews with Sample Data
#Preview("Ripe Apple") {
    SummaryView(
        result: PredictionResult(
            image: createSampleImage(color: .red, emoji: "🍎"),
            label: "ripe apple",
            confidence: 0.92
        ),
        isPresented: .constant(true)
    )
}

#Preview("Unripe Apple") {
    SummaryView(
        result: PredictionResult(
            image: createSampleImage(color: .green, emoji: "🍏"),
            label: "unripe apple",
            confidence: 0.87
        ),
        isPresented: .constant(true)
    )
}

#Preview("Overripe Apple") {
    SummaryView(
        result: PredictionResult(
            image: createSampleImage(color: .brown, emoji: "🍎"),
            label: "overripe apple",
            confidence: 0.94
        ),
        isPresented: .constant(true)
    )
}

#Preview("Not Apple") {
    SummaryView(
        result: PredictionResult(
            image: createSampleImage(color: .gray, emoji: "❓"),
            label: "not apple",
            confidence: 0.78
        ),
        isPresented: .constant(true)
    )
}

#Preview("Invalid Result") {
    SummaryView(
        result: PredictionResult(
            image: nil,
            label: "unknown",
            confidence: 0.0
        ),
        isPresented: .constant(true)
    )
}

// Helper function for creating sample images
private func createSampleImage(color: UIColor, emoji: String) -> UIImage {
    let size = CGSize(width: 300, height: 300)
    let renderer = UIGraphicsImageRenderer(size: size)
    
    return renderer.image { context in
        // Background
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        
        // Emoji
        let font = UIFont.systemFont(ofSize: 120)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        
        let text = emoji
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
    }
}
