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
    
    init(result: PredictionResult, isPresented: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: SummaryViewModel(result: result))
        self._isPresented = isPresented
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.isPredictionValid {
                        imageSection
                        predictionSection
                        resultSection
                    } else {
                        errorSection
                    }
                }
                .padding(.bottom, 32)
            }
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
        .padding([.top, .horizontal])
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
        VStack(alignment: .leading) {
            Text(viewModel.result.label)
                .font(.title2)
                .fontWeight(.bold)
            Text(viewModel.formattedDate)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .padding(.horizontal)
    }
    
    private var resultSection: some View {
        Group {
            if let state = viewModel.ripenessState {
                let info = state.displayInfo
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 12) {
                        Text("\(viewModel.confidencePercentage)%")
                            .font(.title)
                            .bold()
                            .foregroundColor(Color(info.color))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(info.title)
                                .font(.headline)
                                .foregroundColor(Color(info.color))
                            Text(info.description)
                                .lineLimit(1)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(info.color).opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    private var errorSection: some View {
        VStack(alignment: .center, spacing: 12) {
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
}