//
//  RipelyIcon.swift
//  Ripely
//
//  Created by Ferdinand Lunardy on 29/08/25.
//
import Foundation
import SwiftUI

enum RipelyIcon {
    // Tick and Cross Icon
    static let icCross = "icCross"
    static let icTick = "icTick"
    
    // Ripeness State
    static var overripeAppleIcon: Image { Image("brown_apple") }
    static var ripeAppleIcon: Image { Image("red_apple") }
    static var unripeAppleIcon: Image { Image("green_apple") }
    static var notAppleIcon: Image { Image("not_an_apple") }
    
    // Detail Icons
    static var fridgeIcon: Image { Image("fridge") }
    static var noChillIcon: Image { Image("no_chill") }
    static var noSunIcon: Image { Image("no_sunlight") }
    static var overripeBakingIcon: Image { Image("overripe_baking") }
    static var overripeSugarIcon: Image { Image("overripe_sugar") }
    static var ripeCandyIcon: Image { Image("ripe_candy") }
    static var thermometerIcon: Image { Image("thermometer") }
    static var unripeLemonIcon: Image { Image("unripe_lemon") }
    
    // Detail Tips
    static var overripeTipsIcon: Image { Image("overripe_tips") }
    static var ripeTipsIcon: Image { Image("ripe_tips") }
    static var unripeTipsIcon: Image { Image("unripe_tips") }
    
    // Onboarding
    static var appLogo: Image { Image("AppLogo") }
    static var firstIlustIcon: Image { Image("Illust1") }
    static var secondIlustIcon: Image { Image("Illust2") }
    static var thirdIlustIcon: Image { Image("Illust3") }
    
    // Snap Tips
    static var correctAppleIcon: Image { Image("Correct Apple") }
    static var tooDarkIcon: Image { Image("Too Dark") }
    static var tooFarIcon: Image { Image("Too Far") }
    static var tooManyIcon: Image { Image("Too Many") }
    static var tooNearIcon: Image { Image("Too Near") }
}
