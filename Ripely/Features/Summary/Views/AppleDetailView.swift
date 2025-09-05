//
//  AppleDetailVie    // Cached device type checks (computed once)
    private var isIpad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var isIphone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    
    // Layout helper - improved landscape detection for iPad
    private var isLandscape: Bool { 
        orientationManager.isEffectiveLandscape
    }
    private var isTwoColumn: Bool { isIpad && isLandscape }
    
    // Cache UIScreen dimensions to avoid repeated calls
    private var UIWidth: CGFloat { UIScreen.main.bounds.width }
    private var UIHeight: CGFloat { UIScreen.main.bounds.height }/  Aripe
//
//  Created by Jerry Febriano on 17/06/25.
//
import SwiftUI

struct AppleDetailView: View {
    let result: PredictionResult
    @Binding var isPresented: Bool
    @State private var navigateToDetail = false
    
    // Cache the view model to prevent recreation on each render
    @StateObject private var summaryViewModel: SummaryViewModel
    
    // Environment properties to handle the device layout and size
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var orientationManager: OrientationManager
    
    // Cached device type checks (computed once)
    private var isIpad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var isIphone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    
    // Layout helper - improved landscape detection for iPad
    private var isLandscape: Bool { 
        orientationManager.isEffectiveLandscape
    }
    private var isTwoColumn: Bool { isIpad && isLandscape }
    
    // Cache UIScreen dimensions to avoid repeated calls
    private var UIWidth: CGFloat { UIScreen.main.bounds.width }
    private var UIHeight: CGFloat { UIScreen.main.bounds.height }

    init(result: PredictionResult, isPresented: Binding<Bool>) {
        self.result = result
        self._isPresented = isPresented
        // Initialize the cached view model with the result
        self._summaryViewModel = StateObject(wrappedValue: SummaryViewModel(result: result))
    }
    
    var body: some View {
        if isIpad {
            // iPad: Full screen sheet presentation with Done button
            VStack(spacing: 0) {
                // Custom navigation bar for sheet presentation
                ZStack {
                    Text("Scan Results")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Token.Color.textPrimary)
                    HStack {
                        Spacer()
                        
                        Button("Done") {
                            isPresented = false
                        }
                        .foregroundColor(Token.Color.accentGreen)
                        .fontWeight(.medium)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .padding(.top, 8) // Add extra top padding for full screen presentation
                .background(Token.Color.backgroundPrimary)
                
                Divider()
                
                if isTwoColumn {
                    // Two-column layout for iPad landscape
                    TwoColumnLayoutView(result: result, viewModel: summaryViewModel, isPresented: $isPresented)
                } else {
                    // Single column layout for iPad portrait
                    ScrollView {
                        VStack(spacing: 20) {
                            // Apple Image
                            if let image = result.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(
                                        width: UIWidth - 32,
                                        height: UIHeight - 500
                                    )
                                    .clipped()
                                    .cornerRadius(16)
                                    .padding(.horizontal, 16)
                            }

                            // Apple Status Section
                            ApplePredictionResultView(viewModel: summaryViewModel)
                                .padding(.horizontal, 16)

                            // Info Cards Section
                            InfoCardsSection(viewModel: summaryViewModel).padding(.horizontal, 16)

                            // After Slicing Section
                            DetailSection(viewModel: summaryViewModel)

                            // Tips Section
                            TipsSection(viewModel: summaryViewModel)
                        }
                        .padding(.bottom, 16)
                    }

                    // Fixed bottom button
                    VStack(spacing: 0) {
                        Divider()

                        ScanAnotherButton(isPresented: $isPresented)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Token.Color.backgroundPrimary)
                    }
                }
            }
            .background(Token.Color.backgroundPrimary)
            .ignoresSafeArea(edges: .bottom) // Allow content to extend to bottom edge for full screen feel
        } else {
            // iPhone: Navigation view with back button
            NavigationView {
                VStack(spacing: 0) {
                    // Scrollable content
                    ScrollView {
                        VStack(spacing: 20) {
                            // Apple Image
                            if let image = result.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(
                                        width: UIWidth - 32,
                                        height: UIHeight - 500
                                    )
                                    .clipped()
                                    .cornerRadius(16)
                                    .padding(.horizontal, 16)
                            }

                            // Apple Status Section
                            ApplePredictionResultView(viewModel: summaryViewModel)
                                .padding(.horizontal, 16)

                            // Info Cards Section
                            InfoCardsSection(viewModel: summaryViewModel).padding(.horizontal, 16)

                            // After Slicing Section
                            DetailSection(viewModel: summaryViewModel)

                            // Tips Section
                            TipsSection(viewModel: summaryViewModel)
                        }
                        .padding(.bottom, 16)  // Add bottom padding to avoid button overlap
                    }

                    // Fixed bottom button
                    VStack(spacing: 0) {
                        Divider()

                        ScanAnotherButton(isPresented: $isPresented)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Token.Color.backgroundPrimary)
                    }
                }
                .navigationTitle("Apple Detail")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(false)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        // Customize the default back button
                        Button(action: {
                            isPresented = false
                        }, label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(Token.Color.accentGreen)
                                Text("Scan")
                                    .foregroundColor(Token.Color.accentGreen)
                            }
                            .padding(10)
                        })
                        .padding(.leading, -10)
                    }
                }
            }
        }
    }

    private func getStatusText() -> String {
        switch summaryViewModel.ripenessState {
        case .ripe: return "Ripe"
        case .unripe: return "Unripe"
        case .overripe: return "Overripe"
        case .notApple: return "Unknown"
        case .none: return "Unknown"
        }
    }

    private func getStatusDescription() -> String {
        switch summaryViewModel.ripenessState {
        case .ripe:
            return "Consume soon for best taste, store in the fridge if needed."
        case .unripe: return "Wait a few more days before consuming."
        case .overripe: return "This apple is best consumed immediately."
        case .notApple: return "This doesn't appear to be an apple."
        case .none: return "Unable to determine apple status."
        }
    }
}

#Preview {
    AppleDetailView(
        result: PredictionResult(
            image: UIImage(named: "apple"),
            label: "ripe apple",
            confidence: 0.92
        ),
        isPresented: .constant(true)
    )
    .environmentObject(OrientationManager())
}
