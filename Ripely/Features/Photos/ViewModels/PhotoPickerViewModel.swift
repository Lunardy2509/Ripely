//
//  PhotoPickerViewModel.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//
import SwiftUI
import PhotosUI

final class PhotoPickerViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem?
    
    @MainActor
    func loadImage(from item: PhotosPickerItem?) async -> UIImage? {
        guard let item = item else { return nil }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                return uiImage
            }
        } catch {
            print("❌ Failed to load image: \(error)")
        }
        
        return nil
    }
}
