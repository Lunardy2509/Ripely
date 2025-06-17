import PhotosUI
import SwiftUI

struct CameraOverlayView: View {
    var onCapture: () -> Void
    var onToggleFlash: () -> Void
    var onOpenGallery: () -> Void

    @Binding var cropRectInView: CGRect
    @State private var isFlashOn = false
    @State private var isSheetOpened = false

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
                    HStack() {
                        Spacer()
                        
                        //MARK: Help Button
                        Button(action: {
                            isSheetOpened.toggle()
                        }) {
                            Image(systemName: "questionmark")
                                .foregroundColor(.aWhite)
                                .font(.system(size: 20))
                                .bold()
                                .background(
                                    Circle().fill(Color.aBlack.opacity(0.5)).frame(
                                        width: 40,
                                        height: 40
                                    )
                                )
                        }
                        .padding(25)
                    }
                    Spacer()

                    Text("Place the Apple in Focus")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.aWhite)
                        .background(
                            Rectangle()
                                .fill(Color.aPrimaryGreen.opacity(0.5))
                                .frame(height: 45)
                        )
//                        .background(.aAccentGreen)
//                        .frame(height: 0)
                        .font(.headline)

                    HStack {
                        //MARK: Gallery Button
                        Button(action: onOpenGallery) {
                            Image(systemName: "photo.on.rectangle")
                                .foregroundColor(.aPrimaryGreen)
                                .font(.system(size: 30))
                        }

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
                    .padding(.vertical, 40)
                    .background(.aWhite)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $isSheetOpened) {
                SnapTips()
                    .presentationDragIndicator(.visible)
            }
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
