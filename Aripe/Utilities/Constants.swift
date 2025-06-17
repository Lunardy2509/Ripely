//
//  Constants.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//

import Foundation
import SwiftUI

struct Constants {
    static let MiscellaneousFloatingTabPillShadow: Color = .black.opacity(0.08)
    static let NeutralBlack: Color = Color(red: 0.18, green: 0.18, blue: 0.18)
    static let PrimaryRed: Color = Color(red: 0.87, green: 0.18, blue: 0.27)
    static let PrimaryBrown: Color = Color(red: 0.57, green: 0.19, blue: 0.03)
    static let PrimaryPrimaryGreen: Color = Color(red: 0.23, green: 0.5, blue: 0.19)
    static let NeutralWhite: Color = Color(red: 1, green: 0.99, blue: 0.99)
    static let NeutralLightGray: Color = Color(red: 0.89, green: 0.89, blue: 0.89)

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
                description:
                    "Matengin membantumu mengecek tingkat kematangan apel agar kamu tahu kapan buah siap dimakan."
            ),
            OnboardingPage(
                imageName: "onboard2",
                title: "Scan Buah",
                description:
                    "Cukup foto apelmu, dan dapatkan estimasi waktu konsumsi supaya buah nggak terbuang sia‑sia."
            ),
            OnboardingPage(
                imageName: "onboard3",
                title: "Simpan buahmu ke basket",
                description:
                    "Kamu bisa menyimpan buah yang kamu beli ke dalam basket agar kami dapat memantau estimasi hari apelmu."
            ),
        ]
    }

    // MARK: - Apple Information
    struct AppleInfo {
        let imageName: String
        let title: String
        let characteristics: String
        let consumptionAdvice: String
        let adviceColor: Color
        let backgroundColor: Color

        static let ripe = AppleInfo(
            imageName: "red_apple",
            title: "Apel ini terlihat matang",
            characteristics:
                "Ciri-ciri: warna merah cerah, kulit mengkilap, tekstur keras namun tidak terlalu keras.",
            consumptionAdvice: "Baik dimakan sebelum 5 hari",
            adviceColor: .green,
            backgroundColor: Color.green.opacity(0.2)
        )

        static let unripe = AppleInfo(
            imageName: "green_apple",
            title: "Apel ini masih mentah",
            characteristics:
                "Ciri-ciri: Keras dan sedikit asam, biarkan di luar atau dinginkan agar tetap segar.",
            consumptionAdvice: "Matang dalam 3-5 hari",
            adviceColor: .orange,
            backgroundColor: Color.orange.opacity(0.2)
        )

        static let overripe = AppleInfo(
            imageName: "brown_apple",
            title: "Apel ini terlalu matang",
            characteristics:
                "Sebaiknya segera dimakan, mungkin terlalu lunak atau manis untuk beberapa selera.",
            consumptionAdvice: "Gunakan Segera",
            adviceColor: Constants.PrimaryBrown,
            backgroundColor: Color.yellow.opacity(0.3)
        )

        static let notApple = AppleInfo(
            imageName: "not_apple",
            title: "Apel tidak terdeteksi",
            characteristics: "Objek yang terdeteksi bukan merupakan buah apel.",
            consumptionAdvice: "Coba scan apel yang lain",
            adviceColor: .gray,
            backgroundColor: Color.gray.opacity(0.1)
        )

        static func info(for state: AppleRipenessState) -> AppleInfo {
            switch state {
            case .ripe: return .ripe
            case .unripe: return .unripe
            case .overripe: return .overripe
            case .notApple: return .notApple
            }
        }
    }
}
