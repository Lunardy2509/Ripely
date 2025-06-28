//
//  Extensions.swift
//  Aripe
//
//  Created by Jerry Febriano on 16/06/25.
//

import SwiftUI
import UIKit

// MARK: - Color Extensions
extension Color {
    init(_ colorName: String) {
        if let uiColor = UIColor(named: colorName) {
            self.init(uiColor)
        } else {
            self = .clear
        }
    }
}

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - UIImage Extensions
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}

// MARK: - Date Extensions
extension Date {
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
