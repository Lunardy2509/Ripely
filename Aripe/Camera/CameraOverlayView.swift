import SwiftUI
import PhotosUI

struct CameraOverlayView: View {
    var onCapture: () -> Void
    var onToggleFlash: () -> Void
    var onOpenGallery: () -> Void
    
    @Binding var cropRectInView: CGRect
    @State private var isFlashOn = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.5)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: 250, height: 250)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                    )

                // 🔴 Add GeometryReader to track the exact rect of the capture box
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: StrokeStyle(lineWidth: 3, dash: [8]))
                    .frame(width: 250, height: 250)
                    .foregroundColor(.white)
                    .background(
                        GeometryReader { rectGeo in
                            Color.clear
                                .onAppear {
                                    cropRectInView = rectGeo.frame(in: .named("cameraPreview"))
                                }
                                .onChange(of: rectGeo.frame(in: .named("cameraPreview"))) { _, newValue in
                                    cropRectInView = newValue
                                }
                        }
                    )

                VStack {
                    HStack {
                        Button(action: {
                            isFlashOn.toggle()
                            onToggleFlash()
                        }) {
                            Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.black.opacity(0.6)).frame(width: 40, height: 40))
                        }
                        .padding()
                        Spacer()
                    }
                    Spacer()

                    Text("Place the Apple in Focus")
                        .foregroundColor(.white)
                        .font(.headline)

                    ZStack {
                        VStack(spacing: 8) {
                            Button(action: onCapture) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 5)
                                        .frame(width: 85, height: 85)
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 75, height: 75)
                                }
                            }
                        }

                        HStack {
                            Spacer()
                            Button(action: onOpenGallery) {
                                Image(systemName: "photo.on.rectangle")
                                    .foregroundColor(.white)
                                    .font(.system(size: 28))
                                    .padding()
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                            }
                            .padding(.trailing, 32)
                        }
                    }
                    .padding(.bottom, 35)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
