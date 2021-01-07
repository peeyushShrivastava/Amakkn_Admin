//
//  EditPropertyModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 04/01/21.
//

import Foundation

struct AddPropertyParams: Codable {
    let amenity: [Amenity]?
    let features: [Room]?
    let details: [Feature]?
    let price: [Price]?

    private enum CodingKeys: String, CodingKey {
        case features = "room"
        case details = "feature"
        case amenity, price
    }
}

struct EditDetailsDataSource {
    let images: EditImagesDataSource?
    var features: EditFeaturesDataSource?
    var amenities: EditAmenitiesDataSource?
    let details: EditPropertyDetailsDataSource?
    let plans: EditPlansDataSource?
    let description: EditDescriptionDataSource?
    let price: EditPriceDataSource?

    init(_ propertyDetails: PropertyDetails?, and params: AddPropertyParams?) {
        self.images = EditImagesDataSource(propertyDetails)
        self.features = EditFeaturesDataSource(propertyDetails, and: params?.features)
        self.amenities = EditAmenitiesDataSource(propertyDetails, and: params?.amenity)
        self.details = EditPropertyDetailsDataSource(propertyDetails, and: params?.details)
        self.plans = EditPlansDataSource(dataSource: [""])
        self.description = EditDescriptionDataSource(propertyDetails)
        self.price = EditPriceDataSource(propertyDetails, and: params?.price)
    }
}

struct EditImagesDataSource {
    var dataSource: [String]?

    init(_ propertyDetails: PropertyDetails?) {
        dataSource = propertyDetails?.photos?.components(separatedBy: ",")
    }
}

struct EditFeaturesDataSource {
    let params: [Room]?
    var dataSource: [Room]?

    init(_ propertyDetails: PropertyDetails?, and params: [Room]?) {
        self.params = params
        dataSource = propertyDetails?.rooms
    }
}

struct EditAmenitiesDataSource {
    let params: [Amenity]?
    var dataSource: [Amenity]?

    init(_ propertyDetails: PropertyDetails?, and params: [Amenity]?) {
        self.params = params
        dataSource = propertyDetails?.amenities
    }
}

struct EditPropertyDetailsDataSource {
    var params: [Feature]?
    var dataSource: [Feature]?

    init(_ propertyDetails: PropertyDetails?, and params: [Feature]?) {
        self.params = params
        dataSource = propertyDetails?.features
    }
}

struct EditPlansDataSource {
    var dataSource = [String]()
}

struct EditDescriptionDataSource {
    var dataSource: String?

    init(_ propertyDetails: PropertyDetails?) {
        dataSource = propertyDetails?.description
    }
}

struct EditPriceDataSource {
    var params: [Price]?
    var salePrice: [SalesPrice]?
    var rentPrice: [PriceRent]?

    init(_ propertyDetails: PropertyDetails?, and params: [Price]?) {
        self.params = params
        salePrice = propertyDetails?.salePrices
        rentPrice = propertyDetails?.priceRent
    }
}
