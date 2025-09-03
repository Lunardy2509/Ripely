//
//  MainView.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//
import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = CameraViewModel()
    @StateObject private var orientationManager = OrientationManager()
    
    private var isIpad: Bool { UIDevice.current.isIpad }
    
    var body: some View {
        ZStack {
            Group {
                if isIpad {
                    CameraView(viewModel: viewModel)
                        .coordinateSpace(name: "cameraPreview")
                        .ignoresSafeArea(.all, edges: .bottom)
                } else {
                    CameraView(viewModel: viewModel)
                        .coordinateSpace(name: "cameraPreview")
                }
            }
            
            CameraOverlayView(viewModel: viewModel)
        }
        .environmentObject(orientationManager)
        .sheet(isPresented: $viewModel.showSummary, onDismiss: {
            viewModel.resetCapture()
        }, content: {
            if let result = viewModel.capturedResult {
                if isIpad {
                    // iPad: Show AppleDetailView as sheet with different detents for portrait/landscape
                    let isLandscape = orientationManager.orientation.isLandscape
                    let detentHeight: CGFloat = isLandscape ? 0.8 : 0.99
                    
                    AppleDetailView(result: result, isPresented: $viewModel.showSummary)
                        .presentationDetents([.fraction(detentHeight)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(20)
                        .background(Token.Color.backgroundPrimary)
                } else {
                    // iPhone: Keep original SummaryView behavior
                    let ripenessState = AppleRipenessState.from(rawLabel: result.label)
                    let detentHeight: CGFloat = (ripenessState == .notApple) ? 0.40 : 0.85
                    
                    SummaryView(result: result, isPresented: $viewModel.showSummary)
                        .presentationDetents([.fraction(detentHeight)])
                        .presentationDragIndicator(.visible)
                        .background(Token.Color.backgroundPrimary)
                }
            }
        })
    }
}

#Preview {
    MainView()
}
