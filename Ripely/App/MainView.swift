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
                
                let ripenessState = AppleRipenessState.from(rawLabel: result.label)
                let detentHeight: CGFloat = (ripenessState == .notApple) ? 0.40 : 0.85
                
                SummaryView(result: result, isPresented: $viewModel.showSummary)
                    .presentationDetents([.fraction(detentHeight)])
                    .presentationDragIndicator(.visible)
                    .background(.aBackgroundPrimary)
            }
        }
    }
}
