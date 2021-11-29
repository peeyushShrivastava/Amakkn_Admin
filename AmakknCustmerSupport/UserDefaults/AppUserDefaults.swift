//
//  AppUserDefaults.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 16/12/20.
//

import Foundation

struct DefaultsStrings {
    static let pushFCMToken = "FCMToken"
    static let loginUser = "LoginUser"
    static let appDomain = "AppDomains"
    static let chatBadgeCount = "ChatBadgeCount"
    static let ticketBadgeCount = "TicketBadgeCount"
    static let forcedLogout = "ForcedLogout"
}

class AppUserDefaults {
    static let manager = AppUserDefaults()

    private let defaults = UserDefaults.standard

    private init() { }

    func resetDefaults() {
        save(user: nil)
    }
}

// MARK: - PushToken
extension AppUserDefaults {
    var pushFCMToken: String {
        get {
            return defaults.value(forKey: DefaultsStrings.pushFCMToken) as? String ?? ""
        }
        set {
            defaults.setValue(newValue, forKey: DefaultsStrings.pushFCMToken)
            defaults.synchronize()
        }
    }
}

// MARK: - Badge Count
extension AppUserDefaults {
    var chatBadgeCount: String? {
        get {
            return defaults.value(forKey: DefaultsStrings.chatBadgeCount) as? String
        }
        set {
            defaults.setValue(newValue, forKey: DefaultsStrings.chatBadgeCount)
            defaults.synchronize()
        }
    }

    var ticketBadgeCount: String? {
        get {
            return defaults.value(forKey: DefaultsStrings.ticketBadgeCount) as? String
        }
        set {
            defaults.setValue(newValue, forKey: DefaultsStrings.ticketBadgeCount)
            defaults.synchronize()
        }
    }
}

// MARK: - Forced Log-out
extension AppUserDefaults {
    var forcedLogout: Bool {
        get {
            return defaults.value(forKey: DefaultsStrings.forcedLogout) as? Bool ?? false
        }
        set {
            defaults.setValue(newValue, forKey: DefaultsStrings.forcedLogout)
            defaults.synchronize()
        }
    }
}

// MARK: - Users
extension AppUserDefaults {
    func save(user: User?) {
        do {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(user)

            defaults.setValue(userData, forKey: DefaultsStrings.loginUser)
            defaults.synchronize()
        } catch { }
    }

    func getUser() -> User? {
        do {
            if let userData = defaults.value(forKey: DefaultsStrings.loginUser) as? Data {
                let decoder = JSONDecoder()

                return try decoder.decode(User.self, from: userData)
            }
        } catch { }

        return nil
    }
}

// MARK: - Domains
extension AppUserDefaults {
    func save(domains: [AppDomain]?) {
        do {
            let encoder = JSONEncoder()
            let domainsData = try encoder.encode(domains)

            defaults.setValue(domainsData, forKey: DefaultsStrings.appDomain)
            defaults.synchronize()
        } catch { }
    }

    func getDomains() -> [AppDomain]? {
        do {
            if let domainData = defaults.value(forKey: DefaultsStrings.appDomain) as? Data {
                let decoder = JSONDecoder()

                return try decoder.decode([AppDomain].self, from: domainData)
            }
        } catch { }

        return nil
    }
}
