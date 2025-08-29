//
//  OrientationManager.swift
//  Ripely
//
//  Created by GitHub Copilot on 14/08/25.
//

import SwiftUI
import Combine

final class OrientationManager: ObservableObject {
    @Published var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @Published var interfaceOrientation: UIInterfaceOrientation = .portrait
    
    private var cancellables = Set<AnyCancellable>()
    
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
