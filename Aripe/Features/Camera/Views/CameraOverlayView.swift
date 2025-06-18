//
//  CameraOverlayView.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//

import SwiftUI
import PhotosUI

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
                    .padding(.bottom, 130)
                
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
                    .padding(.bottom, 130)
                
                // Processing overlay
                if viewModel.isProcessing {
                    processingOverlay
                }
                
                VStack {
                    //MARK: Top Bar
                    HStack() {
                        Spacer()
                        
                        //MARK: Help Button
                        Button(action: {
                            viewModel.isSheetOpened.toggle()
                        }) {
                            Image(systemName: "questionmark")
                                .foregroundColor(.aWhite)
                                .font(.system(size: 20))
                                .bold()
                                .background(
                                    Circle().fill(Color.aBlack.opacity(0.5)).frame(
                                        width: 40,
                                        height: 40
                                    )
                                )
                        }
                        .padding(25)
                    }
                    Spacer()
                    
                    Text("Place one clear apple in frame. Avoid blur and background apples.")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.aWhite)
                        .background(
                            Rectangle()
                                .fill(Color.aBlack.opacity(0.5))
                                .frame(height: 30)
                        )
                        .font(.caption)
                    
                    HStack {
                        //MARK: Gallery Button
                        PhotosPicker(
                            selection: $viewModel.selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Image(systemName: "photo.on.rectangle")
                                .foregroundColor(viewModel.isProcessing ? .gray : .aPrimaryGreen)
                                .font(.system(size: 30))
                        }
                        .disabled(viewModel.isProcessing)
                        
                        Spacer()
                        
                        //MARK: Capture Button
                        Button(action: viewModel.captureImage) {
                            ZStack {
                                Circle()
                                    .stroke(viewModel.isProcessing ? Color.gray : Color.aPrimaryGreen, lineWidth: 5)
                                    .frame(width: 75, height: 75)
                                Circle()
                                    .fill(viewModel.isProcessing ? Color.gray : Color.aPrimaryGreen)
                                    .frame(width: 65, height: 65)
                                
                                if viewModel.isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                            }
                        }
                        .disabled(viewModel.isProcessing)
                        .padding(.trailing, 20)
                        
                        Spacer()
                        
                        //MARK: Flash Button
                        Button(action: viewModel.toggleFlash) {
                            Image(
                                systemName: viewModel.isFlashOn
                                ? "bolt.fill" : "bolt.slash.fill"
                            )
                            .foregroundColor(.aWhite)
                            .font(.system(size: 25))
                            .background(
                                Circle().fill(Color.aPrimaryGreen).frame(
                                    width: 40,
                                    height: 40
                                )
                            )
                        }
                        .disabled(viewModel.isProcessing)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 40)
                    .background(.aBackgroundPrimary)
                }
            }
            .navigationTitle("Scan Your Apple")
            .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $viewModel.isSheetOpened) {
                SnapTips()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.fraction(0.99)])
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Processing...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(24)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
        }
    }
}

#Preview {
    CameraOverlayView(viewModel: CameraViewModel())
}
