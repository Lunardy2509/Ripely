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
    static let NeutralBlack: Color = Color.aBlack
    static let PrimaryRed: Color = Color.aRed
    static let PrimaryBrown: Color = Color.aBrown
    static let PrimaryGreen: Color = Color.aPrimaryGreen
    static let NeutralWhite: Color = Color.aWhite
    static let NeutralLightGray: Color = Color.aLightGray
    static let PrimaryDarkOrange: Color = Color.aOrange
    static let BGPrimaryGreen: Color = Color.aBackgroundGreen
    static let BGPrimaryOrange: Color = Color.aBackgroundOrange
    struct Camera {
        static let captureBoxSize: CGFloat = 250
        static let horizontalOffset: CGFloat = -175
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
        let detail: AppleDetail
        let tips: AppleTips

        static let ripe = AppleInfo(
            imageName: "red_apple",
            title: "Apple is Likely Ripe",
            appleDescription:
                "Consume soon for best taste, store in fridge if needed.",
            consumptionAdvice: "Best eaten before 5 days",
            adviceColor: PrimaryGreen,
            backgroundColor: BGPrimaryGreen,
            characteristics: AppleCharacteristic.ripe,
            detail: AppleDetail.ripe,
            tips: AppleTips.ripe
        )

        static let unripe = AppleInfo(
            imageName: "green_apple",
            title: "Apple is Likely Unripe",
            appleDescription:
                "Firm and slightly tart, leave out to ripen or chill to keep fresh.",
            consumptionAdvice: "Ripens in 3–5 days",
            adviceColor: PrimaryGreen,
            backgroundColor: BGPrimaryGreen,
            characteristics: AppleCharacteristic.unripe,
            detail: AppleDetail.unripe,
            tips: AppleTips.unripe
        )

        static let overripe = AppleInfo(
            imageName: "brown_apple",
            title: "Apple is Likely Overripe",
            appleDescription:
                "Best eaten soon, may be too soft or sweet for some tastes.",
            consumptionAdvice: "Eat Immediately",
            adviceColor: PrimaryDarkOrange,
            backgroundColor: BGPrimaryOrange,
            characteristics: AppleCharacteristic.overripe,
            detail: AppleDetail.overripe,
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
            detail: AppleDetail.overripe,
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
        let oneIconName: ImageResource
        let oneDescription: String
        let onePrimaryColor: Color
        let twoIconName: ImageResource
        let twoDescription: String
        let twoPrimaryColor: Color
        let threeIconName: ImageResource
        let threeDescription: AnyView
        let threePrimaryColor: Color
        
        static let ripe = AppleCharacteristic(
            oneIconName: .ripeCandy,
            oneDescription: "Sweet & Crisp",
            onePrimaryColor: PrimaryGreen,
            twoIconName: .fridge,
            twoDescription: "Chill in fridge",
            twoPrimaryColor: PrimaryGreen,
            threeIconName: .noSunlight,
            threeDescription: AnyView(Text("Avoid sunlight")),
            threePrimaryColor: PrimaryDarkOrange
        )
        
        static let unripe = AppleCharacteristic(
            oneIconName: .unripeLemon,
            oneDescription: "Sour & Firm",
            onePrimaryColor: PrimaryGreen,
            twoIconName: .fridge,
            twoDescription: "Chill in fridge",
            twoPrimaryColor: PrimaryGreen,
            threeIconName: .thermometer,
            threeDescription: AnyView(VStack {
                Text("Room Temp:")
                Text("18–25°C").fontWeight(.semibold)
            }),
            threePrimaryColor: PrimaryGreen
        )
        
        static let overripe = AppleCharacteristic(
            oneIconName: .overripeSugar,
            oneDescription: "Sweet & Soft",
            onePrimaryColor: PrimaryGreen,
            twoIconName: .noChill,
            twoDescription: "Do not chill",
            twoPrimaryColor: PrimaryDarkOrange,
            threeIconName: .overripeBaking,
            threeDescription: AnyView(Text("For Baking")),
            threePrimaryColor: PrimaryGreen
        )
    }
    
    struct AppleDetail {
        let detailTitle: String
        let detailDescription: String
        
        static let ripe = AppleDetail(
            detailTitle: "After slicing the apple",
            detailDescription: 
                """
                • Store in a sealed container inside the fridge.
                • Soak in lemon water or salt water to slow down the oxidation rate for a while.
                """
        )

        static let unripe = AppleDetail(
            detailTitle: "Signs It’s Ready to Eat",
            detailDescription:
                """
                • Slightly softer when pressed
                • Sweet, fruity smell
                • Yellower or redder color and less waxy surface
                """
        )
        
        static let overripe = AppleDetail(
            detailTitle: "Best Ways to Use It",
            detailDescription:
                """
                • Use it for baking (muffins, pies, crisps)
                • Mix into oatmeal or porridge
                • Turn into applesauce
                """
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
            tipsLabel: "Use a paper bag to speed up the ripening rate if you want to eat it quickly."
        )
        
        static let overripe = AppleTips(
            tipsIcon: "overripe_tips",
            tipsLabel: "Cut away any bruised spots on the apple before cooking or eating."
        )
    }
}
