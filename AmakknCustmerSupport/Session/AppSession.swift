//
//  AppSession.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 13/10/20.
//

import Foundation

enum UserType: String {
    case normal = "1"
    case owner = "2"
    case broker = "3"
    case company = "4"
    case agent = "5"
    case admin = "6"
}

enum AccountType: String {
    case individual = "1"
    case corporate = "2"
}

enum AccountTypeStr: String {
    case individual = "Individual"
    case corporate = "Corporate"
}

enum UserTypeStr: String {
    case normal = "Normal"
    case owner = "Owner"
    case broker = "Broker"
    case company = "Company"
    case agent = "Agent"
    case admin = "Admin"
}

class AppSession {
    static let manager = AppSession()

    private init() { self.user = AppUserDefaults.manager.getUser() }

    private var user: User?
    private var networkSession: URLSession?
}

// MARK: - Public Methods
extension AppSession {
    var validSession: Bool {
        return user != nil
    }

    var userID: String? {
        return user?.userID
    }

    var userName: String? {
        return user?.userName
    }

    var userAvatar: String? {
        return user?.avatar
    }

    var userCreatedDate: Date? {
        guard let createdDate = user?.createdAt else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return formatter.date(from: createdDate)
    }

    func updateUser() {
        self.user = AppUserDefaults.manager.getUser()
    }

    func resetAppSession() {
        user = nil
        AppUserDefaults.manager.resetDefaults()
    }

    func update(_ urlSession: URLSession?) {
        networkSession = urlSession
    }

    func cancelURLSession() {
        networkSession?.invalidateAndCancel()
    }
}
