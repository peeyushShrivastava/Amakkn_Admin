//
//  PropertiesModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import Foundation

struct PropertyResponseModel: Codable {
    let propertyArray: [PropertyCardsModel]?
    let totalCount: Int?
}

struct PropertyCardsModel: Codable {
    let userID: String?
    let propertyID: String?
    let superUserID: String?

    var isInFavourites: String?
    let isFeatured: String?
    var isInCompareList: String?

    let defaultPrice: String?
    let formatedPrice: String?
    let listedFor: String?

    let photos: String?
    let photosNew: String?
    let address: String?
    let category: String?

    let propertyType: String?
    let propertyTypeName: String?
    let crmPeopleCount: String?

    let rooms: [Room]?
    let hostInfo: Host?
    let features: [Feature]?
    let amenities: [Amenity]?

    private enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case propertyID = "propertyId"
        case superUserID = "superUserId"
        case formatedPrice = "defaultPriceFomratted"
        case crmPeopleCount = "uniqueCount"
        case isInFavourites, isFeatured, isInCompareList, listedFor
        case defaultPrice, photos, photosNew, address
        case propertyType, propertyTypeName, category
        case rooms, hostInfo, features, amenities
    }
}

struct Amenity: Codable {
    let key: String?
    let name: String?
}

struct Room: Codable {
    let key: String?
    let value: String?
    let name: String?
}

struct Feature: Codable {
    let key: String?
    let value: String?
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
