//
//  CameraOverlayView.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//


import SwiftUI

struct CameraOverlayView: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Overlay mask
                Color.black.opacity(0.5)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: Constants.Camera.captureBoxSize, height: Constants.Camera.captureBoxSize)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                    )
                
                // Capture box
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: StrokeStyle(lineWidth: 3, dash: [8]))
                    .frame(width: Constants.Camera.captureBoxSize, height: Constants.Camera.captureBoxSize)
                    .foregroundColor(.white)
                    .background(
                        GeometryReader { rectGeo in
                            Color.clear
                                .onAppear {
                                    viewModel.cropRectInView = rectGeo.frame(in: .named("cameraPreview"))
                                }
                                .onChange(of: rectGeo.frame(in: .named("cameraPreview"))) { _, newValue in
                                    viewModel.cropRectInView = newValue
                                }
                        }
                    )
                
                VStack {
                    // Flash button
                    HStack {
                        Button(action: viewModel.toggleFlash) {
                            Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.black.opacity(0.6)).frame(width: 40, height: 40))
                        }
                        .padding()
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Text(Constants.UI.captureInstruction)
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    // Camera controls
                    ZStack {
                        VStack(spacing: 8) {
                            Button(action: viewModel.captureImage) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 5)
                                        .frame(width: 85, height: 85)
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 75, height: 75)
                                }
                            }
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: viewModel.openGallery) {
                                Image(systemName: "photo.on.rectangle")
                                    .foregroundColor(.white)
                                    .font(.system(size: 28))
                                    .padding()
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                            }
                            .padding(.trailing, 32)
                        }
                    }
                    .padding(.bottom, 35)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}