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
                    
                    Text("Place the Apple in Focus")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.aWhite)
                        .background(
                            Rectangle()
                                .fill(Color.aPrimaryGreen.opacity(0.5))
                                .frame(height: 45)
                        )
                        .font(.headline)
                    
                    HStack {
                        //MARK: Gallery Button
                        Button(action: viewModel.openGallery) {
                            Image(systemName: "photo.on.rectangle")
                                .foregroundColor(.aPrimaryGreen)
                                .font(.system(size: 30))
                        }
                        
                        Spacer()
                        
                        //MARK: Capture Button
                        Button(action: viewModel.captureImage) {
                            ZStack {
                                Circle()
                                    .stroke(Color.aPrimaryGreen, lineWidth: 5)
                                    .frame(width: 75, height: 75)
                                Circle()
                                    .fill(Color.aPrimaryGreen)
                                    .frame(width: 65, height: 65)
                            }
                        }
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
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 40)
                    .background(.aWhite)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $viewModel.isSheetOpened) {
                SnapTips()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.fraction(0.99)])
            }
        }
    }
}
