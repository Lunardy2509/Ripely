//
//  StorageServiceProtocol.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//


import Foundation

protocol StorageServiceProtocol {
    var hasSeenOnboarding: Bool { get set }
}

class StorageService: StorageServiceProtocol, ObservableObject {
    @Published var hasSeenOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: Constants.Storage.onboardingKey)
        }
    }
    
    init() {
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: Constants.Storage.onboardingKey)
    }
}