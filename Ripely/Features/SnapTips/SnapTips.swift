//
//  SnapTips.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//
import SwiftUI

struct SnapTips: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                Text("Scan Tips")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()

                Button(action: {
                    dismiss()
                }, label: {
                    Text("Done")
                })
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
             
             ExamplePhotos(
                image: .correctApple,
                 caption: "Correct Photo",
                 status: .correct,
                darkOverlay: false
             )

             LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                 ExamplePhotos(image: .tooNear, caption: "Too Close", status: .wrong, darkOverlay: false)
                 ExamplePhotos(image: .tooFar, caption: "Too Far", status: .wrong, darkOverlay: false)
                 ExamplePhotos(image: .tooDark, caption: "Too Dark", status: .wrong, darkOverlay: true)
                 ExamplePhotos(image: .tooMany, caption: "Many Apples Around", status: .wrong, darkOverlay: false)
             }
             
             Spacer()
         }
         .padding()
     }
}

#Preview {
    SnapTips()
}
