//
//  ExamplePhotos.swift
//  Aripe
//
//  Created by Reynard Hansel on 16/06/25.
//

import SwiftUI

struct ExamplePhotos: View {
    enum PhotoStatus {
        case correct
        case wrong
    }
    
    let image: ImageResource
    let caption: String
    let status: PhotoStatus
    let darkOverlay: Bool

    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                     Image(image)
                         .resizable()
                         .scaledToFill()
                         .frame(width: 150, height: 150)
                         .clipped()
                     
                     if darkOverlay {
                         // semi-transparent black overlay matching the same corner radius
                         Color.black
                             .opacity(0.4)
                             .frame(width: 150, height: 150)
                     }
                 }
                 .cornerRadius(12)
                
                // Status Icon
                Image(systemName: status == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(status == .correct ? .green : .red)
                    .padding(8)
                    .font(.title)
            }

            Text(caption)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
    }
}

#Preview {
    ExamplePhotos(image: .correctApple, caption: "Correct Apple", status: .correct, darkOverlay: true)
}
