//
//  PropertyDetailsModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 25/10/20.
//

import Foundation

struct PropertyDetails: Codable {
    let userID: String?
    let propertyID: String?
    let superUserID: String?

    let isLiked: String?
    let isInFavourites: String?
    let isFeatured: String?
    let isFromWanted: String?
    let isInCompareList: String?

    let likesCount: String?
    let category: String?
    let listedFor: String?
    let status: String?
    let views: String?
    let qrCode: String?

    let propertyType: String?
    let propertyTypeName: String?

    let categoryName: String?
    let visitingHours: String?
    let visitingDays: String?

    let phone: String?
    let countryCode: String?

    let latitude: String?
    let longitude: String?
    let address: String?

    let description: String?
    let defaultPrice: String?
    let formatedPrice: String?

    let photos: String?
    let photosNew: String?
    let floorPlans: String?

    let createdDate: String?
    let updatedDate: String?

    let tracker: Tracker?
    let amenities: [Amenity]?
    let rooms: [Room]?
    let features: [Feature]?
    let salePrices: [SalesPrice]?
    let priceRent: [PriceRent]?
    let defaultPriceType: PriceType?
    let hostInfo: Host?
    
    private enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case propertyID = "propertyId"
        case superUserID = "superUserId"
        case likesCount = "numberOfLikes"
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case formatedPrice = "defaultPriceFomratted"
        case isLiked, isInFavourites, isFeatured, isFromWanted, isInCompareList
        case category, listedFor, status, views, qrCode
        case propertyType, propertyTypeName, phone, countryCode
        case categoryName, visitingHours, visitingDays
        case latitude, longitude, address, description, defaultPrice
        case photos, photosNew, floorPlans, hostInfo, priceRent
        case tracker, amenities, rooms, features, salePrices, defaultPriceType
    }
}

struct Tracker: Codable {
    let isDescriptionComplete: String?
    let isRoomsComplete: String?
    let isContactComplete: String?
    let isPriceComplete: String?
}

struct PriceType: Codable {
    let key: String?
    let name: String?
}

struct SalesPrice: Codable {
    let percentage: String?
    var price: String?
    let date: String?
    let priceID: String?

    private enum CodingKeys: String, CodingKey {
        case priceID = "id"
        case percentage, price, date
    }
}

struct PriceRent: Codable {
    let key: String?
    var value: String?
    let name: String?
}

struct Price: Codable {
    let key: String?
    let type: String?
    let name: String?
    let isDefault: String?
}

struct DetailsDataSource {
    var headerDataSource: DetailsHeaderModel?
    let description: String?
    let overviewDataSource: DetailsOverViewModel?
    let amenityDataSource: DetailsAmenityModel?
    let rentOptionDataSource: DetailsRentOptionsModel?
    let locationDataSource: DetailsLocationModel?
    let visitingHrsDataSource: DetailsVisitingHrsModel?
    let mortgageDesc = "Mortgage_Description".localized()
    let hostDataSource: DetailsHostModel?
    let reportAbuse = "Report_Abuse".localized()
    let floorPlanDataSource: DetailsFloorPlansModel?

    init(_ propertyDetails: PropertyDetails?) {
        headerDataSource = DetailsHeaderModel(propertyDetails)
        description = propertyDetails?.description
        overviewDataSource = DetailsOverViewModel(propertyDetails)
        amenityDataSource = DetailsAmenityModel(propertyDetails)
        locationDataSource = DetailsLocationModel(propertyDetails)
        visitingHrsDataSource = DetailsVisitingHrsModel(propertyDetails)
        hostDataSource = DetailsHostModel(propertyDetails?.hostInfo)
        floorPlanDataSource = DetailsFloorPlansModel(propertyDetails)
        rentOptionDataSource = DetailsRentOptionsModel(propertyDetails)
    }
}

struct DetailsHeaderModel {
    let hostUserID: String?
    var propertyID: String?
    let photos: [String]?
    let category: String?
    let address: String?

    var likes: String?
    let propertyType: String?
    let propertyTypeName: String?
    let propertyPrice: String?
    let priceType: String?
    let listedFor: String?

    let favStatus: Bool?
    let compareStatus: Bool?
    var likeStatus: Bool?

    init(_ propertyDetails: PropertyDetails?) {
        hostUserID = propertyDetails?.hostInfo?.hostUserID
        propertyID = propertyDetails?.propertyID
        category = propertyDetails?.category
        likes = propertyDetails?.likesCount
        propertyType = propertyDetails?.propertyType
        propertyTypeName = propertyDetails?.propertyTypeName
        propertyPrice = propertyDetails?.defaultPrice
        address = propertyDetails?.address

        photos = propertyDetails?.photos?.components(separatedBy: ",")
        priceType = propertyDetails?.defaultPriceType?.name
        listedFor = Utility.shared.getPropertyTypeName(for: propertyDetails?.propertyType, with: propertyDetails?.category)

        favStatus = propertyDetails?.isInFavourites == "1"
        compareStatus = propertyDetails?.isInCompareList == "1"
        likeStatus = propertyDetails?.isLiked == "1"
    }
}

struct DetailsOverViewModel {
    var dataSource = [OverviewListModel]()

    init(_ propertyDetails: PropertyDetails?) {
        let rooms = propertyDetails?.rooms?.sorted(by: { Int($0.key ?? "0") ?? 0 < Int($1.key ?? "0") ?? 0})
        let features = propertyDetails?.features?.sorted(by: { Int($0.key ?? "0") ?? 0 < Int($1.key ?? "0") ?? 0})

        rooms?.forEach({ (room) in
            if let name = room.name, let value = room.value {
                dataSource.append(OverviewListModel(name: name, value: value))
            }
        })

        features?.forEach({ (feature) in
            if let name = feature.name, let value = feature.value, let unit = feature.unit {
                let updatedUnit = unit == "--" ? "" : unit
                dataSource.append(OverviewListModel(name: name, value: "\(value) \(updatedUnit)"))
            }
        })
    }
}

struct DetailsAmenityModel {
    let dataSource: [Amenity]?

    init(_ propertyDetails: PropertyDetails?) {
        dataSource = propertyDetails?.amenities?.sorted(by: { Int($0.key ?? "0") ?? 0 < Int($1.key ?? "0") ?? 0})
    }
}

struct DetailsRentOptionsModel {
    let dataSource: [OverviewListModel]?

    init(_ propertyDetails: PropertyDetails?) {
        dataSource = propertyDetails?.priceRent?.compactMap({ OverviewListModel(name: $0.name, value: $0.value?.amkFormat) })
    }
}

struct OverviewListModel {
    let name: String?
    let value: String?
}

struct DetailsLocationModel {
    let address: String?
    let latitude: String?
    let longitde: String?

    init(_ propertyDetails: PropertyDetails?) {
        address = propertyDetails?.address
        latitude = propertyDetails?.latitude
        longitde = propertyDetails?.longitude
    }
}

struct DetailsVisitingHrsModel {
    let countryCode: String?
    let phone: String?
    let days: String?
    let timing: String?

    init(_ propertyDetails: PropertyDetails?) {
        countryCode = propertyDetails?.countryCode
        phone = propertyDetails?.phone
        days = propertyDetails?.visitingDays
        timing = propertyDetails?.visitingHours
    }
}

struct DetailsHostModel {
    let hostID: String?
    let userType: String?
    let accountType: String?

    let hostName: String?
    let hostEmail: String?
    let hostPhone: String?
    let countryCode: String?

    let hostAvatar: String?
    let companyAvatar: String?
    let companyID: String?
    let hasCompanyVerified: Bool?
    var propertyStatus: String?

    init(_ hostInfo: Host?) {
        hostID = hostInfo?.hostUserID
        userType = hostInfo?.userType
        accountType = hostInfo?.accountType

        hostName = hostInfo?.name
        hostEmail = hostInfo?.email
        hostPhone = hostInfo?.phone
        countryCode = hostInfo?.countryCode

        hostAvatar = hostInfo?.avatar
        companyAvatar = hostInfo?.companyAvatar
        hasCompanyVerified = hostInfo?.companyIsVerified == "1"
        companyID = hostInfo?.companyID
    }
}

struct DetailsFloorPlansModel {
    let dataSource: [String]?

    init(_ propertyDetails: PropertyDetails?) {
        dataSource = propertyDetails?.floorPlans?.components(separatedBy: ",")
    }
}

struct PropertyDetailsData {
    var propertyID = ""
    var propertyPrice = ""
    var propertyAge = ""
    var propertyArea = ""
    var propertyType = ""

    init(details: PropertyDetails?) {
        propertyID = details?.propertyID ?? ""
        propertyPrice = details?.defaultPrice ?? ""
        propertyType = details?.propertyType ?? ""

        propertyAge = calculateAge(from: details) ?? ""
        propertyArea = getArea(from: details) ?? ""
    }

    private func calculateAge(from details: PropertyDetails?) -> String? {
        guard let featureList = details?.features else { return nil }

        let ageStr = featureList.filter { $0.key == "6"}.first?.value
        guard let age = ageStr else { return "0" }

        let ageEn = age.map { $0.digitToEn }.joined(separator: "")

        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy"
        let date = dateFormatter.string(from: currentDate)

        guard let ageIntEn = Int(ageEn), let dateInt = Int(date) else { return nil }

        return String(dateInt - ageIntEn)
    }

    private func getArea(from details: PropertyDetails?) -> String? {
        guard let propertyType = details?.propertyType else { return nil }
        guard let featureList = details?.features else { return nil }
        switch propertyType {
        case "1":
//            residential land - land area
            return featureList.filter { $0.key == "1" }.first?.value
        case "3":
//            apartment - built area
            return featureList.filter { $0.key == "9" }.first?.value
        case "2":
//            residential building - land area
            return featureList.filter { $0.key == "3" }.first?.value
        case "4":
//            villa - land area
            return featureList.filter { $0.key == "10" }.first?.value
        case "5":
//            commercial land - land area
            return featureList.filter { $0.key == "13" }.first?.value
        case "6":
//            commercial building - land area
            return featureList.filter { $0.key == "15" }.first?.value
        default:
            return "0"
        }
    }
}

struct ComplaintResponseModel: Codable {
    let complaints: [ComplaintModel]?
}

struct ComplaintModel: Codable {
    let complaintID: String?
    let userID: String?
    let propertyID: String?
    let isResolved: String?
    let description: String?
    let createdAt: String?
    let updatedAt: String?

    let userName: String
    let userType: String?
    let countryCode: String?
    let phone: String?
    let avatar: String?
    let isVerified: String?

    private enum CodingKeys: String, CodingKey {
        case complaintID = "id"
        case userID = "userId"
        case propertyID = "propertyId"
        case isResolved, description, createdAt, updatedAt
        case userName, userType, countryCode, phone, avatar, isVerified
    }
}

extension Character {
    var digitToEn: String {
        switch self {
        case "١":
            return "1"
        case "٢":
            return "2"
        case "٣":
            return "3"
        case "٤":
            return "4"
        case "٥":
            return "5"
        case "٦":
            return "6"
        case "٧":
            return "7"
        case "٨":
            return "8"
        case "٩":
            return "9"
        case "٠":
            return "0"
        default:
            return self.description
        }
    }
}
