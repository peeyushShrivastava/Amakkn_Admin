//
//  PropertiesModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import Foundation

struct FilteredPropertyResponseModel: Codable {
    let propertyArray: [PropertyCardsModel]?
    let totalCount: Int?
}

struct PropertyResponseModel: Codable {
    let properties: [PropertyCardsModel]?
    let totalCount: String?
}

struct PropertyCardsModel: Codable {
    let userID: String?
    let propertyID: String?

    var status: String?
    let defaultPrice: String?
    let defaultPriceType: PriceType?
    let listedFor: String?

    let photos: String?
    let address: String?
    let category: String?
    var complaintCount: String?

    let propertyType: String?
    let createdAt: String?

    private enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case propertyID = "propertyId"
        case listedFor, defaultPrice, address, complaintCount, defaultPriceType
        case propertyType, category, status, photos, createdAt
    }
}

struct Amenity: Codable {
    let key: String?
    let name: String?
}

struct Room: Codable {
    let key: String?
    var value: String?
    let name: String?
}

struct Feature: Codable {
    let key: String?
    var value: String?
    let name: String?
    let unit: String?
}

struct Host: Codable {
    let hostUserID: String?
    let userType: String?
    let accountType: String?

    let name: String?
    let email: String?
    let phone: String?
    let countryCode: String?
    let avatar: String?

    let managerName: String?
    let companyID: String?
    let companyName: String?
    let companyAvatar: String?
    let companyCommercialRecordNumber: String?
    let companyIsVerified: String?
    let companyWebsiteURL: String?

    let latitude: String?
    let longitude: String?
    let address: String?

    private enum CodingKeys: String, CodingKey {
        case hostUserID = "id"
        case companyID = "companyId"
        case userType, accountType
        case name, email, phone, countryCode, avatar
        case managerName, companyName, companyAvatar
        case companyCommercialRecordNumber, companyIsVerified, companyWebsiteURL
        case latitude, longitude, address
    }
}
