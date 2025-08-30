//
//  PhotoPickerView.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//
import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PhotoPickerViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                imagePreview
                photoPickerButton
                Spacer()
            }
            .padding()
            .navigationTitle("Select Photo")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if selectedImage != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .onChange(of: viewModel.selectedItem) { _, newItem in
                Task {
                    selectedImage = await viewModel.loadImage(from: newItem)
                }
            }
        }
    }
    
    private var imagePreview: some View {
        Group {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Token.Color.regularGray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(Token.Color.regularGray)
                            Text("No image selected")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                    )
            }
        }
    }
    
    private var photoPickerButton: some View {
        PhotosPicker(
            selection: $viewModel.selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label("Choose from Library", systemImage: "photo.on.rectangle")
                .font(.headline)
                .foregroundColor(Token.Color.regularWhite)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
    }
}
