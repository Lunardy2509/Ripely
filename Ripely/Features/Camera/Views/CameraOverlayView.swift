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
    
    private var isIpad: Bool { UIDevice.current.isIpad }
    private var isIphone: Bool { UIDevice.current.isIphone }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark overlay with hole
                Token.Color.regularBlack.opacity(0.5)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: Constants.Camera.captureBoxSize,
                                           height: Constants.Camera.captureBoxSize)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                    )
                    .padding(.bottom, Dock.captureBoxBottomPadding)
                
                // Capture box
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: StrokeStyle(lineWidth: 3, dash: [8]))
                    .frame(width: Constants.Camera.captureBoxSize,
                           height: Constants.Camera.captureBoxSize)
                    .foregroundColor(Token.Color.regularWhite)
                    .background(
                        GeometryReader { rectGeo in
                            Color.clear
                                .onAppear {
                                    viewModel.cropRectInView = rectGeo.frame(in: .named("cameraPreview"))
                                }
                                .onChange(of: geometry.size) { _, _ in
                                    viewModel.cropRectInView = rectGeo.frame(in: .named("cameraPreview"))
                                }
                                .onChange(of: rectGeo.frame(in: .named("cameraPreview"))) { _, newValue in
                                    viewModel.cropRectInView = newValue
                                }
                        }
                    )
                    .padding(.bottom, Dock.captureBoxBottomPadding)
                
                // Instruction banner
                VStack {
                    Spacer()
                    
                    Text(viewModel.overlayText)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Token.Color.regularWhite)
                        .background(
                            Rectangle()
                                .fill(viewModel.isTooDark
                                      ? Token.Color.regularRed.opacity(0.4)
                                      : Token.Color.regularBlack.opacity(0.5))
                                .frame(height: isIpad ? 60 : 40)
                        )
                        .font(isIpad ? .body : .caption)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.isTooDark)
                        .padding(.bottom, isIpad ? 20 : 165)
                }
            }
            // ===== Controls =====
            .overlay(alignment: .trailing) {
                if isIpad {
                    RightDock(viewModel: viewModel)
                        .padding(.trailing, Dock.rightDockTrailing)
                        .padding(.vertical, Dock.rightDockVerticalInset)
                        .padding(.bottom, 150)
                }
            }
            .overlay(alignment: .topTrailing) {
                if isIphone {
                    Button {
                        viewModel.isSheetOpened.toggle()
                    } label: {
                        Image(systemName: "questionmark")
                            .foregroundColor(Token.Color.regularWhite)
                            .font(.system(size: 20).bold())
                            .background(
                                Circle()
                                    .fill(Color.aBlack.opacity(0.5))
                                    .frame(width: 40, height: 40)
                            )
                    }
                    .disabled(viewModel.isProcessing)
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
            }
            .overlay(alignment: .bottom) {
                if isIphone {
                    BottomDock(viewModel: viewModel)
                }
            }
            .navigationTitle("Scan Your Apple")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.all, edges: .bottom)
            .sheet(isPresented: $viewModel.isSheetOpened) {
                SnapTips()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.fraction(0.99)])
            }
            .sheet(isPresented: $viewModel.showCropper) {
                if let imageToCrop = viewModel.selectedUIImage {
                    CropView(image: imageToCrop) { croppedImage in
                        viewModel.isProcessing = true
                        viewModel.photoProcessingService.processImage(
                            croppedImage,
                            cropRect: CGRect(origin: .zero, size: croppedImage.size)
                        ) { result in
                            DispatchQueue.main.async {
                                viewModel.isProcessing = false
                                switch result {
                                case .success(let predictionResult):
                                    viewModel.capturedResult = predictionResult
                                    viewModel.showSummary = true
                                case .failure(let error):
                                    viewModel.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                if let errorMessage = viewModel.errorMessage { Text(errorMessage) }
            }
            .coordinateSpace(name: "cameraPreview")
        }
    }
}

// MARK: - iPad Right Dock
private struct RightDock: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Button {
                viewModel.isSheetOpened.toggle()
            } label: {
                Image(systemName: "questionmark")
                    .foregroundColor(Token.Color.regularWhite)
                    .font(.system(size: 20).bold())
                    .background(
                        Circle()
                            .fill(Color.aBlack.opacity(0.5))
                            .frame(width: 40, height: 40)
                    )
            }
            .disabled(viewModel.isProcessing)
            .padding(25)
            .padding(.trailing, 20)
            
            VStack(spacing: 50) {
                // Flash
                Button(action: viewModel.toggleFlash) {
                    Circle()
                        .fill(Token.Color.primaryGreen)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .foregroundColor(Token.Color.regularWhite)
                                .font(.system(size: 20))
                        )
                }
                .disabled(viewModel.isProcessing)
                .opacity(viewModel.isProcessing ? 0.5 : 1)
                .padding()
                
                // Shutter
                Button(action: viewModel.captureImage) {
                    ZStack {
                        Circle()
                            .stroke(viewModel.isProcessing ? Token.Color.regularGray : Token.Color.primaryGreen, lineWidth: 5)
                            .frame(width: 78, height: 78)
                        Circle()
                            .fill(viewModel.isProcessing ? Token.Color.regularGray : Token.Color.primaryGreen)
                            .frame(width: 66, height: 66)
                    }
                }
                .disabled(viewModel.isProcessing)
                .opacity(viewModel.isProcessing ? 0.7 : 1)
                .padding(.vertical, 4)
                
                // Gallery
                PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "photo.on.rectangle")
                        .foregroundColor(viewModel.isProcessing ? Token.Color.regularGray : Token.Color.primaryGreen)
                        .font(.system(size: 30))
                }
                .disabled(viewModel.isProcessing)
                .padding()
            }
            .padding()
            .padding(.trailing, 20)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Token.Color.backgroundPrimary)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
            )
        }
    }
}

// MARK: - iPhone Bottom Dock (unchanged look, consolidated)
private struct BottomDock: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        HStack {
            PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                Image(systemName: "photo.on.rectangle")
                    .foregroundColor(viewModel.isProcessing ? Token.Color.regularGray : Token.Color.primaryGreen)
                    .font(.system(size: 30))
            }
            .disabled(viewModel.isProcessing)
            
            Spacer()
            
            Button(action: viewModel.captureImage) {
                ZStack {
                    Circle()
                        .stroke(viewModel.isProcessing ? Token.Color.regularGray : Token.Color.primaryGreen, lineWidth: 5)
                        .frame(width: 75, height: 75)
                    Circle()
                        .fill(viewModel.isProcessing ? Token.Color.regularGray : Token.Color.primaryGreen)
                        .frame(width: 65, height: 65)
                }
            }
            .disabled(viewModel.isProcessing)
            .padding(.trailing, 20)
            
            Spacer()
            
            Button(action: viewModel.toggleFlash) {
                Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    .foregroundColor(Token.Color.regularWhite)
                    .font(.system(size: 25))
                    .background(
                        Circle().fill(Token.Color.primaryGreen).frame(width: 40, height: 40)
                    )
            }
            .disabled(viewModel.isProcessing)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
        .background(Token.Color.backgroundPrimary)
    }
}

#Preview {
    CameraOverlayView(viewModel: CameraViewModel())
}
