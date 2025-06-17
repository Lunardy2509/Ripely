import SwiftUI

struct SnapTips: View {
    var body: some View {
         VStack(spacing: 24) {
             // Title
             Text("Tips Ambil Foto")
                 .font(.title2)
                 .fontWeight(.bold)

             // Top Correct Photo
             ExamplePhotos(
                image: .correctApple, // Replace with your image asset name
                 caption: "Foto yang Tepat",
                 status: .correct,
                darkOverlay: false
             )

             // Grid for Wrong Photos
             LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                 ExamplePhotos(image: .tooNear, caption: "Terlalu Dekat", status: .wrong, darkOverlay: false)
                 ExamplePhotos(image: .tooFar, caption: "Terlalu Jauh", status: .wrong, darkOverlay: false)
                 ExamplePhotos(image: .tooDark, caption: "Terlalu Gelap", status: .wrong, darkOverlay: true)
                 ExamplePhotos(image: .tooMuch, caption: "Banyak Apel", status: .wrong, darkOverlay: false)
             }
         }
         .padding()
     }
}

#Preview {
    SnapTips()
}
