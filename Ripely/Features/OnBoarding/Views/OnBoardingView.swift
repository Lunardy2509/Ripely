//
//  OnBoardingView.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//
import SwiftUI

struct OnBoardingView: View {
    // Action when Start Scanning tapped
    var onFinished: (() -> Void)?

    var body: some View {
        VStack {
            // Top spacing
            Spacer().frame(height: 40)

            // Top Icon
            Image(.appLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            // Title
            Text("What is Ripely?")
                .font(.title)
                .fontWeight(.bold)

            // Info cards
            VStack(spacing: 18) {
                InfoCard(
                    iconName: .illust1,
                    title:
                        "Ripely can help you identify the ripeness level of apples using your phone camera."
                )
                InfoCard(
                    iconName: .illust2,
                    title:
                        "Get tips on how to store your apple based on its ripeness level and external conditions."
                )
                InfoCard(
                    iconName: .illust3,
                    title:
                        "Your result will vary depending on your lighting, phone camera, and apple variation."
                )
            }
            .padding(.top, 24)
            .padding(.horizontal, 20)

            Spacer()  // push button to bottom

            // Start Scanning button
            Button(action: {
                onFinished?()
            }, label: {
                Text("Start Scanning")
                    .font(.headline)
                    .foregroundColor(Token.Color.regularWhite)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Token.Color.primaryGreen)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
            })
            .padding(.bottom, 35)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Token.Color.backgroundPrimary)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - InfoCard

struct InfoCard: View {
    let iconName: ImageResource
    let title: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .background(Token.Color.regularCream)

            Text(title)
                .font(.footnote)
                .lineSpacing(7)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 8)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Token.Color.backgroundSecondary)
        .cornerRadius(16)
        .shadow(color: Token.Color.regularBlack.opacity(0.1), radius: 8, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Token.Color.stroke)
        )
    }
}

#Preview {
    OnBoardingView()
}
