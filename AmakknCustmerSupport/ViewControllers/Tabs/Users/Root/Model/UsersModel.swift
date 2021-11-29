//
//  UsersModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import Foundation

struct UsersReponseModel: Codable {
    let userArray: [UserStatsModel]?
    let totalCount: Int?
}

struct UserStatsModel: Codable {
    let userID: String?
    let userName: String?
    let userEmail: String?
    let userAvatar: String?
    let userPhone: String?
    let countryCode: String?

    let badgeCount: String?
    let language: String?
    let userType: String?
    let accountType: String?
    let pushToken: String?
    let chatToken: String?
    let status: String?
    let isUserVerified: String?

    let createdAt: String?
    let updatedAt: String?

    let isPushEnabledForLastSearch: String?
    let isPushEnabledForInbox: String?
    let lastSearchedLatitude: String?
    let lastSearchedLongitude: String?

    let publishedPropertyIds: String?
    let incompOrUnpubPropertyIds: String?
    let soldOutPropertyIds: String?
    let publishedPropertyCount: Int?
    let incompOrUnpubPropertyCount: Int?
    let soldOutPropertyCount: Int?
    let lastAddedProperty: String?

    let devices: String?
    let appVersions: String?
    let osVersions: String?
    let platforms: String?
    let lastOpened: String?

    let companyName: String?
    let companyType: String?
    let companyID: Int?
    let commercialRecordNumber: String?
    let companyWebsiteURL: String?
    let companyDesc: String?
    let companyAddress: String?
    let companyLatitude: String?
    let companyLongitude: String?
    let isCompanyVerified: Int?
    let isFeatured: Int?
    let companyAvatar: String?
    let agentCount: Int?

    private enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userName = "name"
        case userEmail = "email"
        case userAvatar = "avatar"
        case userPhone = "phone"
        case companyID = "companyId"
        case companyDesc = "about"
        case companyAddress = "address"
        case companyLatitude = "latitude"
        case companyLongitude = "longitude"
        case countryCode, badgeCount, language, userType, accountType, pushToken, chatToken, status
        case createdAt, updatedAt, isPushEnabledForLastSearch, isPushEnabledForInbox, lastSearchedLatitude, lastSearchedLongitude
        case publishedPropertyIds, incompOrUnpubPropertyIds, soldOutPropertyIds, publishedPropertyCount, incompOrUnpubPropertyCount, soldOutPropertyCount, lastAddedProperty
        case devices, appVersions, platforms, lastOpened, isUserVerified, osVersions
        case companyName, companyType, commercialRecordNumber, companyWebsiteURL, isCompanyVerified, isFeatured, companyAvatar, agentCount
    }
}

struct FilteredUsersReponseModel: Codable {
    let userArray: [SearchedUserModel]?
    let totalCount: Int?
}

struct SearchedUsersReponseModel: Codable {
    let users: [SearchedUserModel]?
    let totalCount: String?
}

struct SearchedUserModel: Codable {
    let userID: String?
    let userId: String?
    let userName: String?
    let userAvatar: String?
    let userPhone: String?
    let countryCode: String?

    var userType: String?
    let accountType: String?
    let createdAt: String?
    let isVerified: String?
    let isUserVerified: String?

    private enum CodingKeys: String, CodingKey {
        case userID = "id"
        case userName = "name"
        case userAvatar = "avatar"
        case userPhone = "phone"
        case countryCode, createdAt, isVerified, userId
        case userType, accountType, isUserVerified
    }
}
