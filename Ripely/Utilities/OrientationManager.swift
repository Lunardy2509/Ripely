//
//  OrientationManager.swift
//  Ripely
//
//  Created by Ferdinand Lunardy on 14/08/25.
//
import SwiftUI
import Combine

final class OrientationManager: ObservableObject {
    @Published var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @Published var interfaceOrientation: UIInterfaceOrientation = .portrait
    
    private var cancellables = Set<AnyCancellable>()
    
    // Computed property for better landscape detection, especially for iPad
    var isEffectiveLandscape: Bool {
        let deviceType = UIDevice.current.userInterfaceIdiom
        
        if deviceType == .pad {
            // For iPad, prioritize interface orientation and screen dimensions
            let screenBounds = UIScreen.main.bounds
            let isScreenWiderThanTall = screenBounds.width > screenBounds.height
            let isInterfaceLandscape = interfaceOrientation.isLandscape
            
            // Also check if device is face up/down (flat) - in this case, use screen dimensions
            let isFlatOrientation = orientation == .faceUp || orientation == .faceDown || orientation == .unknown
            
            if isFlatOrientation {
                return isScreenWiderThanTall
            }
            
            return isInterfaceLandscape || isScreenWiderThanTall
        } else {
            // For iPhone, use standard device orientation
            return orientation.isLandscape
        }
    }
    
    init() {
        setupOrientationObserver()
        updateInterfaceOrientation()
    }
    
    private func setupOrientationObserver() {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                self?.orientation = UIDevice.current.orientation
                self?.updateInterfaceOrientation()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIScene.didActivateNotification)
            .sink { [weak self] _ in
                self?.updateInterfaceOrientation()
            }
            .store(in: &cancellables)
        
        // Add additional listeners for better iPad support
        if #available(iOS 13.0, *) {
            NotificationCenter.default.publisher(for: UIScene.willConnectNotification)
                .sink { [weak self] _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.updateInterfaceOrientation()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    private func updateInterfaceOrientation() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                self.interfaceOrientation = windowScene.interfaceOrientation
            }
        }
    }
}

// MARK: - Orientation Environment Key
struct OrientationKey: EnvironmentKey {
    static let defaultValue: OrientationManager = OrientationManager()
}

extension EnvironmentValues {
    var orientationManager: OrientationManager {
        get { self[OrientationKey.self] }
        set { self[OrientationKey.self] = newValue }
    }
}
