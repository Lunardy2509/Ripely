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
    static let PrimaryPrimaryGreen: Color = Color(
        red: 0.23,
        green: 0.5,
        blue: 0.19
    )
    static let NeutralWhite: Color = Color(red: 1, green: 0.99, blue: 0.99)
    static let NeutralLightGray: Color = Color(
        red: 0.89,
        green: 0.89,
        blue: 0.89
    )
    static let PrimaryDarkOrange: Color = Color(
        red: 0.66,
        green: 0.49,
        blue: 0.19
    )

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
        let appleDescription: String
        let consumptionAdvice: String
        let adviceColor: Color
        let backgroundColor: Color
        let showRipeningAdvice: Bool = true
        let characteristics: AppleCharacteristic
        let tips: AppleTips

        static let ripe = AppleInfo(
            imageName: "red_apple",
            title: "Apple is Likely Ripe",
            appleDescription:
                "Consume soon for best taste, store in fridge if needed.",
            consumptionAdvice: "Best eaten before 5 days",
            adviceColor: PrimaryPrimaryGreen,
            backgroundColor: Color(red: 0.38, green: 0.78, blue: 0.31).opacity(
                0.15
            ),
            characteristics: AppleCharacteristic.ripe,
            tips: AppleTips.ripe
        )

        static let unripe = AppleInfo(
            imageName: "green_apple",
            title: "Apple is Likely Unripe",
            appleDescription:
                "Firm and slightly tart, leave out to ripen or chill to keep fresh.",
            consumptionAdvice: "Ripens in 3–5 days",
            adviceColor: PrimaryPrimaryGreen,
            backgroundColor: Color(red: 0.38, green: 0.78, blue: 0.31).opacity(
                0.15
            ),
            characteristics: AppleCharacteristic.unripe,
            tips: AppleTips.unripe
        )

        static let overripe = AppleInfo(
            imageName: "brown_apple",
            title: "Apple is Likely Overripe",
            appleDescription:
                "Best eaten soon, may be too soft or sweet for some tastes.",
            consumptionAdvice: "Eat Immediately",
            adviceColor: PrimaryDarkOrange,
            backgroundColor: Color(red: 1, green: 0.8, blue: 0.2).opacity(0.24),
            characteristics: AppleCharacteristic.overripe,
            tips: AppleTips.overripe
        )

        static let notApple = AppleInfo(
            imageName: "not_apple",
            title: "Apel tidak terdeteksi",
            appleDescription: "Objek yang terdeteksi bukan merupakan buah apel.",
            consumptionAdvice: "Coba scan apel yang lain",
            adviceColor: .gray,
            backgroundColor: Color.gray.opacity(0.1),
            characteristics: AppleCharacteristic.overripe,
            tips: AppleTips.overripe
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
    
    struct AppleCharacteristic {
        let sweetIconName: String
        let sweetLevel: String
        let sweetPrimaryColor: Color
        let tempIconName: String
        let tempLevel: String
        let tempPrimaryColor: Color
        let saveIconName: String
        let saveDescription: String
        let savePrimaryColor: Color
        
        static let ripe = AppleCharacteristic(
            sweetIconName: "ripe_candy",
            sweetLevel: "Sweet",
            sweetPrimaryColor: PrimaryBrown,
            tempIconName: "thermometer",
            tempLevel: "4–20°C",
            tempPrimaryColor: PrimaryPrimaryGreen,
            saveIconName: "fridge",
            saveDescription: "Keep in fridge",
            savePrimaryColor: PrimaryPrimaryGreen
        )
        
        static let unripe = AppleCharacteristic(
            sweetIconName: "unripe_candy",
            sweetLevel: "Tart",
            sweetPrimaryColor: PrimaryDarkOrange,
            tempIconName: "thermometer",
            tempLevel: "4–20°C",
            tempPrimaryColor: PrimaryPrimaryGreen,
            saveIconName: "no_sunlight",
            saveDescription: "Away from sunlight",
            savePrimaryColor: PrimaryDarkOrange
        )
        
        static let overripe = AppleCharacteristic(
            sweetIconName: "ripe_candy",
            sweetLevel: "Sweet",
            sweetPrimaryColor: PrimaryBrown,
            tempIconName: "thermometer",
            tempLevel: "4–20°C",
            tempPrimaryColor: PrimaryPrimaryGreen,
            saveIconName: "fridge",
            saveDescription: "Keep in fridge",
            savePrimaryColor: PrimaryPrimaryGreen
        )
    }
    
    struct AppleTips {
        let tipsIcon: String
        let tipsLabel: String
        
        static let ripe = AppleTips(
            tipsIcon: "ripe_tips",
            tipsLabel: "Store apples in the fridge to slow ripening and keep them crisp."
        )
        
        static let unripe = AppleTips(
            tipsIcon: "unripe_tips",
            tipsLabel: "Utilize a paper bag to speed up the ripening rate if you want to eat it quickly."
        )
        
        static let overripe = AppleTips(
            tipsIcon: "overripe_tips",
            tipsLabel: "Avoid placing ripe apples near other fruits or vegetables, as it speeds up their ripening."
        )
    }
}
