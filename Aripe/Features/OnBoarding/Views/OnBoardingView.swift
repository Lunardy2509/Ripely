//
//  OnBoardingView.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//


import SwiftUI

struct OnBoardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    var onFinished: (() -> Void)?
    
    var body: some View {
        VStack {
            TabView(selection: $viewModel.currentPage) {
                ForEach(Array(viewModel.pages.enumerated()), id: \.1.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            finishButton
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var finishButton: some View {
        Button(action: {
            if viewModel.isLastPage {
                viewModel.finishOnboarding()
                onFinished?()
            }
        }) {
            Text("Selesai")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.aPrimaryGreen)
                .cornerRadius(12)
        }
        .opacity(viewModel.isLastPage ? 1 : 0)
        .disabled(!viewModel.isLastPage)
        .padding(.horizontal, 30)
        .padding(.top, 16)
        .padding(.bottom, 40)
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            imageContainer
            titleSection
            descriptionSection
        }
    }
    
    private var imageContainer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 254/255, green: 242/255, blue: 221/255))
                .frame(
                    width: UIScreen.main.bounds.width * 0.8,
                    height: UIScreen.main.bounds.height * 0.4
                )
            
            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(
                    width: UIScreen.main.bounds.width * 0.6,
                    height: 250
                )
        }
    }
    
    private var titleSection: some View {
        Text(page.title)
            .font(.title2)
            .bold()
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
    }
    
    private var descriptionSection: some View {
        Text(page.description)
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
    }
}

#Preview {
    OnBoardingView()
}