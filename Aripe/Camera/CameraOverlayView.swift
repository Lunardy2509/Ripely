import PhotosUI
import SwiftUI

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
                                    cropRectInView = rectGeo.frame(
                                        in: .named("cameraPreview")
                                    )
                                }
                                .onChange(
                                    of: rectGeo.frame(
                                        in: .named("cameraPreview")
                                    )
                                ) { _, newValue in
                                    cropRectInView = newValue
                                }
                        }
                    )

                VStack {
                    //MARK: Top Bar
                    HStack {
                        
                    }
                    Spacer()

                    Text("Place the Apple in Focus")
                        .foregroundColor(.white)
                        .font(.headline)

                    HStack {
                        //                        HStack {
                        //MARK: Gallery Button
                        Button(action: onOpenGallery) {
                            Image(systemName: "photo.on.rectangle")
                                .foregroundColor(.aPrimaryGreen)
                                .font(.system(size: 30))
//                                .background(
//                                    Circle().fill(Color.black.opacity(0.6))
//                                )
                        }
                        //                        }
                        
                        Spacer()

                        //MARK: Capture Button
                        Button(action: onCapture) {
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
                        Button(action: {
                            isFlashOn.toggle()
                            onToggleFlash()
                        }) {
                            Image(
                                systemName: isFlashOn
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
                    .padding(.vertical, 35)
                    .background(.aWhite)
//                    .padding(.bottom, 35)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

#Preview {
    CameraOverlayView(
        onCapture: {
            print("Capture button pressed")
        },
        onToggleFlash: {
            print("Flash toggled")
        },
        onOpenGallery: {
            print("Gallery opened")
        },
        cropRectInView: .constant(CGRect.zero)
    )
}
