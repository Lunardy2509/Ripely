//
//  ExamplePhotos.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//
import SwiftUI

struct ExamplePhotos: View {
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
                         Token.Color.regularBlack
                             .opacity(0.4)
                             .frame(width: 150, height: 150)
                     }
                 }
                 .cornerRadius(12)
                
                // Status Icon
                Image(status == .correct ? RipelyIcon.icTick : RipelyIcon.icCross)
                    .foregroundColor(Token.Color.regularWhite)
                    .background(
                        Circle()
                            .fill(status == .correct ? .green : .red)
                    )
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
