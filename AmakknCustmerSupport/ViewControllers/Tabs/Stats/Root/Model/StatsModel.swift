//
//  StatsModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/10/21.
//

import Foundation

struct StatsModel: Codable {
    let usersAdded: String?

    let propertiesAddedAndroid: String?
    let propertiesAddedIos: String?
    let propertiesAddedWeb: String?

    let propertiesPublishedAndroid: String?
    let propertiesPublishedIos: String?
    let propertiesPublishedWeb: String?

    let propertyNos: PropertyNos?
    let publishedPropertyStats: PublishedProperty?
    let userStatModel: UserStatModel?

    private enum CodingKeys: String, CodingKey {
        case usersAdded = "Users Added"

        case propertiesAddedAndroid = "Properties Added - Android"
        case propertiesAddedIos = "Properties Added - iOS"
        case propertiesAddedWeb = "Properties Added - Web"

        case propertiesPublishedAndroid = "Properties Published - Android"
        case propertiesPublishedIos = "Properties Published - iOS"
        case propertiesPublishedWeb = "Properties Published - Web"

        case propertyNos = "Property Numbers"
        case publishedPropertyStats = "Published Property Stats"
        case userStatModel = "User Stats"
    }
}

struct PropertyNos: Codable {
    let propertiesPublished: String?
    let propertiesIncomplete: String?
    let propertiesDeleted: String?
    let propertiesSoldOut: String?

    private enum CodingKeys: String, CodingKey {
        case propertiesPublished = "Properties Published"
        case propertiesIncomplete = "Properties Incomplete"
        case propertiesDeleted = "Properties Deleted"
        case propertiesSoldOut = "Properties Sold Out"
    }
}

struct PublishedProperty: Codable {
    let residentialLands: String?
    let residentialBuildings: String?
    let residentialApartments: String?
    let residentialVillas: String?

    let commercialLands: String?
    let commercialBuldings: String?
    let commercialWarehouses: String?
    let commercialShowrooms: String?
    let commercialOffices: String?

    private enum CodingKeys: String, CodingKey {
        case residentialLands = "Residential Lands"
        case residentialBuildings = "Residential Buildings"
        case residentialApartments = "Residential Apartments"
        case residentialVillas = "Residential Villas"

        case commercialLands = "Commercial Lands"
        case commercialBuldings = "Commercial Buldings"
        case commercialWarehouses = "Commercial Warehouses"
        case commercialShowrooms = "Commercial Showrooms"
        case commercialOffices = "Commercial Offices"
    }
}

struct UserStatModel: Codable {
    let individualNormalUsers: String?
    let individualOwners: String?
    let individualBrokers: String?
    let corporateMarketingCompanies: String?
    let corporateDevelopmentCompanies: String?
    let agents: String?

    private enum CodingKeys: String, CodingKey {
        case individualNormalUsers = "Individual Normal Users"
        case individualOwners = "Individual Owners"
        case individualBrokers = "Individual Brokers"
        case corporateMarketingCompanies = "Corporate - Marketing Companies"
        case corporateDevelopmentCompanies = "Corporate - Development Companies"
        case agents = "Agents"
    }
}

struct StatsDetailsDataSource {
    let userStats: UserStats?
    let publishedPropertyStats: PublishedPropertyStats?
    let propertyNos: PropertyNosStats?
    let otherStats: OtherStats?

    init(_ statsDetails: StatsModel?) {
        userStats = UserStats(statsDetails?.userStatModel)
        publishedPropertyStats = PublishedPropertyStats(statsDetails?.publishedPropertyStats)
        propertyNos = PropertyNosStats(statsDetails?.propertyNos)
        otherStats = OtherStats(statsDetails)
    }
}

struct UserStats {
    var data = [StatsDataTypeModel]()

    init(_ usersDetails: UserStatModel?) {
        data.append(StatsDataTypeModel(key: "Corporate - Development Companies", value: usersDetails?.corporateDevelopmentCompanies ?? "--"))
        data.append(StatsDataTypeModel(key: "Corporate - Marketing Companies", value: usersDetails?.corporateMarketingCompanies ?? "--"))
        data.append(StatsDataTypeModel(key: "Individual Normal Users", value: usersDetails?.individualNormalUsers ?? "--"))
        data.append(StatsDataTypeModel(key: "Individual Brokers", value: usersDetails?.individualBrokers ?? "--"))
        data.append(StatsDataTypeModel(key: "Individual Owners", value: usersDetails?.individualOwners ?? "--"))
        data.append(StatsDataTypeModel(key: "Agents", value: usersDetails?.agents ?? "--"))
    }
}

struct PublishedPropertyStats {
    var data = [StatsDataTypeModel]()

    init(_ propertyDetails: PublishedProperty?) {
        data.append(StatsDataTypeModel(key: "Commercial Buildings", value: propertyDetails?.commercialBuldings ?? "--"))
        data.append(StatsDataTypeModel(key: "Commercial Lands", value: propertyDetails?.commercialLands ?? "--"))
        data.append(StatsDataTypeModel(key: "Commercial Offices", value: propertyDetails?.commercialOffices ?? "--"))
        data.append(StatsDataTypeModel(key: "Commercial Showrooms", value: propertyDetails?.commercialShowrooms ?? "--"))
        data.append(StatsDataTypeModel(key: "Commercial Warehouses", value: propertyDetails?.commercialWarehouses ?? "--"))

        data.append(StatsDataTypeModel(key: "Residential Apartments", value: propertyDetails?.residentialApartments ?? "--"))
        data.append(StatsDataTypeModel(key: "Residential Buildings", value: propertyDetails?.residentialBuildings ?? "--"))
        data.append(StatsDataTypeModel(key: "Residential Lands", value: propertyDetails?.residentialLands ?? "--"))
        data.append(StatsDataTypeModel(key: "Residential Villas", value: propertyDetails?.residentialVillas ?? "--"))
    }
}

struct PropertyNosStats {
    var data = [StatsDataTypeModel]()

    init(_ propertyDetails: PropertyNos?) {
        data.append(StatsDataTypeModel(key: "Properties Deleted", value: propertyDetails?.propertiesDeleted ?? "--"))
        data.append(StatsDataTypeModel(key: "Properties Published", value: propertyDetails?.propertiesPublished ?? "--"))
        data.append(StatsDataTypeModel(key: "Properties Incomplete/Unpublished", value: propertyDetails?.propertiesIncomplete ?? "--"))
        data.append(StatsDataTypeModel(key: "Properties Sold out", value: propertyDetails?.propertiesSoldOut ?? "--"))
    }
}

struct OtherStats {
    var data = [StatsDataTypeModel]()

    init(_ statsDetails: StatsModel?) {
        data.append(StatsDataTypeModel(key: "Properties Added - Android", value: statsDetails?.propertiesAddedAndroid ?? "--"))
        data.append(StatsDataTypeModel(key: "Properties Added - iOS", value: statsDetails?.propertiesAddedIos ?? "--"))
        data.append(StatsDataTypeModel(key: "Properties Added - Web", value: statsDetails?.propertiesAddedWeb ?? "--"))
        data.append(StatsDataTypeModel(key: "Properties Publised - Android", value: statsDetails?.propertiesPublishedAndroid ?? "--"))
        data.append(StatsDataTypeModel(key: "Properties Publised - iOS", value: statsDetails?.propertiesPublishedIos ?? "--"))
        data.append(StatsDataTypeModel(key: "Properties Publised - Web", value: statsDetails?.propertiesPublishedWeb ?? "--"))
        data.append(StatsDataTypeModel(key: "Users Added", value: statsDetails?.usersAdded ?? "--"))
    }
}

struct StatsDataTypeModel {
    let key: String?
    let value: String
}

struct StatsDetailsModel {
    var isExpanded = true
    var detailsTitle: String?
    let detailsData: [StatsDataTypeModel]?

    init(with detailsTitle: String?, for detailsData: [StatsDataTypeModel]?) {
        self.detailsTitle = detailsTitle
        self.detailsData = detailsData
    }
}
