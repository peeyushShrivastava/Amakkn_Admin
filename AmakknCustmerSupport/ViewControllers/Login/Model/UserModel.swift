//
//  UserModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 16/12/20.
//

import Foundation

struct UserResponse: Codable {
    let user: User?
}

struct User: Codable {
    let userID: String?
    let userName: String?
    let email: String?
    let avatar: String?

    let phone: String?
    let countryCode: String?

    let createdAt: String?
    let updatedAt: String?

    let userType: String?
    let accountType: String?

    private enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userName = "name"
        case email = "email"
        case phone, countryCode, avatar, createdAt, updatedAt
        case userType, accountType
    }
}

struct AppDomainResponse: Codable {
    let currencySymbol: String?
    let countryShortCode: String?
    let baseURL: String?
    let baseURLNew: String?
    let bannerImage: String?
    let countryCodes: [AppDomain]?
}

struct AppDomain: Codable {
    let countryName:  String?
    let countryShortCode: String?
    let countryCode: String?
}
