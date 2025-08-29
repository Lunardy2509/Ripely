import SwiftUI

struct SnapTips: View {
    var body: some View {
         VStack(spacing: 24) {
             // Title
             Text("Scan Tips")
                 .font(.title2)
                 .fontWeight(.bold)

             // Top Correct Photo
             ExamplePhotos(
                image: .correctApple, // Replace with your image asset name
                 caption: "Correct Photo",
                 status: .correct,
                darkOverlay: false
             )

             // Grid for Wrong Photos
             LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                 ExamplePhotos(image: .tooNear, caption: "Too Close", status: .wrong, darkOverlay: false)
                 ExamplePhotos(image: .tooFar, caption: "Too Far", status: .wrong, darkOverlay: false)
                 ExamplePhotos(image: .tooDark, caption: "Too Dark", status: .wrong, darkOverlay: true)
                 ExamplePhotos(image: .tooMany, caption: "Many Apples Around", status: .wrong, darkOverlay: false)
             }
         }
         .padding()
     }
}

#Preview {
    SnapTips()
}
