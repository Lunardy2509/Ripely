//
//  SummaryView.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//

import SwiftUI

struct SummaryView: View {
    @StateObject private var viewModel: SummaryViewModel
    @Binding var isPresented: Bool
    @State private var showAppleDetail = false

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
                        predictionSection.padding(.horizontal, 16)
                        finishButton
                    } else {
                        errorSection
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .fullScreenCover(isPresented: $showAppleDetail) {
            AppleDetailView(result: viewModel.result, isPresented: $isPresented)
        }
    }

    private var headerSection: some View {
        HStack {
            Text("Hasil Scan")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray)
            }
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

    private var predictionSection: some View {
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

    private var errorSection: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Foto tidak terdeteksi")
                .foregroundColor(.gray)
                .fontWeight(.semibold)
                .font(.title2)
            Text("Silakan coba scan ulang dengan pencahayaan yang lebih baik.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var finishButton: some View {
        Button(action: {
            showAppleDetail = true
        }) {
            Text("Selesai")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isPredictionValid ? .aPrimaryGreen : .gray)
                .cornerRadius(12)
        }
        .disabled(!viewModel.isPredictionValid)
        .padding(.horizontal, 16)
    }
}

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

#Preview("Rotten Apple") {
    SummaryView(
        result: PredictionResult(
            image: createSampleImage(color: .brown, emoji: "🍎"),
            label: "rotten apple",
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
