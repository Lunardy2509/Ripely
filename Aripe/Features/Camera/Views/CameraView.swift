//
//  CameraView.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//


import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    @ObservedObject var viewModel: CameraViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        viewModel.setupCamera(in: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
