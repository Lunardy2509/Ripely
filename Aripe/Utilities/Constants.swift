//
//  Constants.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//


import Foundation

struct Constants {
    struct Camera {
        static let captureBoxSize: CGFloat = 250
        static let horizontalOffset: CGFloat = -110
        static let verticalOffset: CGFloat = 0
    }
    
    struct UI {
        static let captureInstruction = "Place the Apple in Focus"
    }
    
    struct Storage {
        static let onboardingKey = "hasSeenOnboarding"
    }
    
    struct Onboarding {
        static let pages: [OnboardingPage] = [
            OnboardingPage(
                imageName: "onboard1",
                title: "Apa itu Matengin?",
                description: "Matengin membantumu mengecek tingkat kematangan apel agar kamu tahu kapan buah siap dimakan."
            ),
            OnboardingPage(
                imageName: "onboard2",
                title: "Scan Buah",
                description: "Cukup foto apelmu, dan dapatkan estimasi waktu konsumsi supaya buah nggak terbuang sia‑sia."
            ),
            OnboardingPage(
                imageName: "onboard3",
                title: "Simpan buahmu ke basket",
                description: "Kamu bisa menyimpan buah yang kamu beli ke dalam basket agar kami dapat memantau estimasi hari apelmu."
            ),
        ]
    }
}
