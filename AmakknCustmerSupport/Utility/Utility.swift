//
//  Utility.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 14/10/20.
//

import Localize_Swift
import Foundation
import SwiftHash
import Firebase
import UIKit

// MARK: - Langage Type Enum
enum LanguageType: String {
    case english = "1"
    case arabic = "0"
}

// MARK: - Langage Type Str Enum
enum LanguageTypeStr: String {
    case english = "English"
    case arabic = "Arabic"
}

class Utility {
    static let shared = Utility()

    private init() { }

    private var selectedTabItem = 0

    var selectedLanguage: LanguageType {
        return .english
    }

    var currencySymbol: String {
        return "SAR "
    }

    var hasNotch: Bool {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }

    var appPlatform: String {
        return "ios"
    }

    var deviceIdentifier: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}

// MARK: - Hashed IDs
extension Utility {
    func getHashedID(for data: [String: String]) -> String? {
        guard let firstValue = data.keys.first, let secondValue = data.values.first else { return nil }

        return MD5(firstValue + secondValue).lowercased()
    }

    func getHashedUserID() -> String {
        guard let userID = AppSession.manager.userID, let createdAt = AppSession.manager.userCreatedDate else { return "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let deviceLang = NSLocale.preferredLanguages[0]
        let enUSPOSIXLocale = Locale(identifier: deviceLang)

        formatter.locale = enUSPOSIXLocale
        formatter.locale = Locale(identifier: "en_US")

        let createdDateStr = formatter.string(from: createdAt)
        return MD5(createdDateStr + userID).lowercased()
    }

    func getHashedUserID(for userID: String?, createdAt: String?) -> String {
        guard let userID = userID, let createdAt = createdAt else { return "" }

        return MD5(createdAt + userID).lowercased()
    }
}

// MARK: - Date Conversion
extension Utility {
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return formatter.string(from: Date())
    }

    func milliSecsToDate(from timeStamp: String) -> Date {
        guard let timeInterval = Double(timeStamp) else { return Date() }

        return Date(timeIntervalSince1970: timeInterval/1000)
    }

    func currentDateInMilliSecs() -> Int {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970

        return Int(since1970 * 1000)
    }

    func dateStrInMilliSecs(dateStr: String?) -> String? {
        guard let dateStr = dateStr else { return "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let date = formatter.date(from: dateStr) else { return "" }
        let since1970 = date.timeIntervalSince1970

        return "\(Int64(since1970) * 1000)"
    }

    func isFormat24Hrs() -> Bool {
        let locale = NSLocale.current
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale)!
        if dateFormat.range(of: "a") != nil {
            return false
        } else {
            return true
        }
    }

    func convertDates(for timeStr: String?) -> String? {
        guard let time = timeStr else { return timeStr }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let date = dateFormatter.date(from: time) else { return time }

        if Calendar.current.isDateInToday(date) {
            dateFormatter.dateFormat = "hh:mm aa"
            let dateStr = "\("Chat_Today".localized()), \(dateFormatter.string(from: date))"

            return dateStr
        } else if Calendar.current.isDateInYesterday(date) {
            dateFormatter.dateFormat = "hh:mm aa"
            let dateStr = "\("Chat_yesterday".localized()), \(dateFormatter.string(from: date))"

            return dateStr
        } else if dateFallsInCurrentWeek(date: date) {
            dateFormatter.dateFormat = "EEEE, hh:mm aa"

            return dateFormatter.string(from: date)
        } else if dateFallsInCurrentYear(date: date) {
            dateFormatter.dateFormat = "dd MMM, hh:mm aa"

            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "dd MMM yyyy"

            return dateFormatter.string(from: date)
        }
    }

    func convertDates(with timeStamp: String?) -> String? {
        guard let timeStamp = timeStamp else { return nil }

        let dateFormatter = DateFormatter()

        let date = Utility.shared.milliSecsToDate(from: timeStamp)

        dateFormatter.dateFormat = Utility.shared.isFormat24Hrs() ? "HH:mm" : "h:mm a"
        let timeStr = dateFormatter.string(from: date)

        if Calendar.current.isDateInToday(date) {
            return "\("Chat_Today".localized()) \(timeStr)"
        } else if Calendar.current.isDateInYesterday(date) {
            return "\("Chat_yesterday".localized()) \(timeStr)"
        } else if dateFallsInCurrentWeek(date: date) {
            dateFormatter.dateFormat = "EEEE"
            return "\(dateFormatter.string(from: date)) \(timeStr)"
        } else if dateFallsInCurrentYear(date: date) {
            dateFormatter.dateFormat = "EEE, dd MMM"
            return "\(dateFormatter.string(from: date)) \(timeStr)"
        } else {
            dateFormatter.dateFormat = "dd MMM yyyy"
            return "\(dateFormatter.string(from: date)) \(timeStr)"
        }
    }

    private func dateFallsInCurrentWeek(date: Date) -> Bool {
        let currentWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: Date())
        let datesWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: date)

        return (currentWeek == datesWeek)
    }

    private func dateFallsInCurrentYear(date: Date) -> Bool {
        let currentYear = Calendar.current.component(Calendar.Component.year, from: Date())
        let datesYear = Calendar.current.component(Calendar.Component.year, from: date)

        return (currentYear == datesYear)
    }
}

// MARK: - Set Badge Count
extension Utility {
    func updateChat(badgeCount: String?) {
        guard let window =  UIApplication.shared.windows.first else { return }
        guard let tabBarController = window.rootViewController as? MainTabBarController else { return }

        tabBarController.tabBar.items?[4].badgeValue = (badgeCount == "0" || badgeCount == "") ? nil : badgeCount
    }

    func updateTicket(badgeCount: String?) {
        guard let window =  UIApplication.shared.windows.first else { return }
        guard let tabBarController = window.rootViewController as? MainTabBarController else { return }

        tabBarController.tabBar.items?[0].badgeValue = (badgeCount == "0" || badgeCount == "") ? nil : badgeCount
    }

    func updateToken(callback: @escaping () -> Void) {
        Messaging.messaging().token { token, error in
          if let token = token {
            AppUserDefaults.manager.pushFCMToken = token

            callback()
          }
        }
    }
}

// MARK: - Property Type
extension Utility {
    func getPropertyTypeName(for typeID: String?, with category: String?) -> String? {
        guard let typeIDStr = typeID, let type = PropertyType(rawValue: typeIDStr) else { return nil }
        guard let categoryStr = category, let categoryType = PropertyCategory(rawValue: categoryStr) else { return nil }

        let propertyCategory = (categoryType == .sale) ? "Sale" : "Rent"

        switch type {
            case .residentialLand: return "Residential Land for \(propertyCategory)"
            case .residentialBuilding: return "Residential Building for \(propertyCategory)"
            case .apartment: return "Apartment for \(propertyCategory)"
            case .villa: return "Villa for \(propertyCategory)"
            case .commercialLand: return "Commercial Land for \(propertyCategory)"
            case .commercialBuilding: return "Commercial Building for \(propertyCategory)"
            case .warehouse: return "Warehouse for \(propertyCategory)"
            case .showroom: return "Showroom for \(propertyCategory)"
            case .office: return "Office for \(propertyCategory)"
        }
    }
}

// MARK: - Selected Tab
extension Utility {
    func getSelectedTab() -> Int {
        return selectedTabItem
    }

    func updateSelectedTab(with tag: Int?) {
        selectedTabItem = tag ?? 0
    }
}
