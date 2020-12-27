//
//  AppExtensions.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 14/10/20.
//

import Foundation
import UIKit

// MARK: - Formatter Extension
extension Formatter {
    static let currency = NumberFormatter(style: .currency)

    static let currencyUS: NumberFormatter = {
        let formatter = NumberFormatter(style: .currency)

        formatter.locale = Locale(identifier: "en_US")
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 0

        return formatter
    }()
}

// MARK: - NumberFormatter Extension
extension NumberFormatter {
    convenience init(style: Style) {
        self.init()

        numberStyle = style
    }
}

// MARK: - NSNumber Extension
extension NSNumber {
    var currency: String {
        return Formatter.currency.string(for: self) ?? ""
    }

    var currencyUS: String {
        return Formatter.currencyUS.string(for: self) ?? ""
    }
}

// MARK: - String Extension for Price format
extension String {
    var amkFormat: String {
        guard let priceDouble = Double(self) else { return self }

        let priceNumber = NSNumber(value: priceDouble)
        let priceFormat = Utility.shared.selectedLanguage == .english ? ("\(Utility.shared.currencySymbol) \(String(priceNumber.currencyUS))") : ("\(String(priceNumber.currencyUS)) \(Utility.shared.currencySymbol)")

        return priceFormat
    }

    var trimWhitespaces: String {
        return components(separatedBy: .whitespaces).joined()
    }

    var firstLowerCased: String {
        return prefix(1).lowercased() + dropFirst()
    }
}

// MARK: - UIView Extension
extension UIView {
    func corner(_ radii: CGFloat, for corners: CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = radii
        layer.maskedCorners = corners
    }
}
