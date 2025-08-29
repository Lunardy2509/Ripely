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

    init(result: PredictionResult, isPresented: Binding<Bool>) {
        self._viewModel = StateObject(
            wrappedValue: SummaryViewModel(result: result)
        )
        self._isPresented = isPresented
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.isPredictionValid {
                        imageSection
                        ApplePredictionResultView(viewModel: viewModel)
                            .padding(.horizontal, 16)
                        finishButton
                    } else {
                        errorSection
                        finishButton
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, 32)
            }
        }
        .fullScreenCover(isPresented: $showAppleDetail) {
            if viewModel.ripenessState != .notApple {
                AppleDetailView(result: viewModel.result, isPresented: $isPresented)
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Text("Scan Result")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 16, height: 16)
            })
        }
        .padding()
    }

    private var imageSection: some View {
        Group {
            if let image = viewModel.result.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: UIScreen.main.bounds.width - 32,
                        height: UIScreen.main.bounds.width - 32
                    )
                    .clipped()
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
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
    
    private var finishButton: some View {
        Button(action: {
            if viewModel.ripenessState != .notApple {
                showAppleDetail = true
            } else {
                isPresented = false
            }
        }, label: {
            Text(viewModel.ripenessState == .notApple ? "Scan Another" : "More Detail")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.aButtonGreen)
                .cornerRadius(12)
        })
        .padding(.horizontal, 16)
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
