//
//  MainView 2.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            CameraView(viewModel: viewModel)
                .coordinateSpace(name: "cameraPreview")
            
            CameraOverlayView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showSummary, onDismiss: {
            viewModel.resetCapture()
        }) {
            if let result = viewModel.capturedResult {
                SummaryView(result: result, isPresented: $viewModel.showSummary)
                    .presentationDetents([.fraction(0.85)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
