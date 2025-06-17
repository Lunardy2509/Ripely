//
//  AripeApp.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//


import SwiftUI

@main
struct AripeApp: App {
    @StateObject private var storageService = StorageService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storageService)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var storageService: StorageService
    
    var body: some View {
        Group {
            if storageService.hasSeenOnboarding {
                NavigationStack {
                    MainView()
                }
            } else {
                OnBoardingView(onFinished: {
                    storageService.hasSeenOnboarding = true
                })
            }
//            OnBoardingView()
        }
    }
}
