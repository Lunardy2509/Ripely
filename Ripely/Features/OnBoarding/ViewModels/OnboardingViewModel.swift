//
//  OnboardingViewModel.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    
    private var storageService: StorageServiceProtocol
    
    let pages = Constants.Onboarding.pages
    
    init(storageService: StorageServiceProtocol = StorageService()) {
        self.storageService = storageService
    }
    
    func finishOnboarding() {
        storageService.hasSeenOnboarding = true
    }
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
}
