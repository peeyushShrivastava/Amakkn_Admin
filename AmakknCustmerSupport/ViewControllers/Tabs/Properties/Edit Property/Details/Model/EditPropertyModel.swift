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
    var details: EditPropertyDetailsDataSource?
    let plans: EditPlansDataSource?
    var description: EditDescriptionDataSource?
    var price: EditPriceDataSource?

    init(_ propertyDetails: PropertyDetails?, and params: AddPropertyParams?) {
        self.images = EditImagesDataSource(propertyDetails)
        self.features = EditFeaturesDataSource(propertyDetails, and: params?.features)
        self.amenities = EditAmenitiesDataSource(propertyDetails, and: params?.amenity)
        self.details = EditPropertyDetailsDataSource(propertyDetails, and: params?.details)
        self.plans = EditPlansDataSource(propertyDetails)
        self.description = EditDescriptionDataSource(propertyDetails)
        self.price = EditPriceDataSource(propertyDetails, and: params?.price)
    }
}

struct EditImagesDataSource {
    var dataSource: [String]?

    init(_ propertyDetails: PropertyDetails?) {
        dataSource = propertyDetails?.photosNew?.components(separatedBy: ",")
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
    var frontispeice: Feature?
    var params: [Feature]?
    var dataSource: [Feature]?

    init(_ propertyDetails: PropertyDetails?, and params: [Feature]?) {
        if let index = params?.firstIndex(where: { $0.key == "7" }) {
            self.params = params
            frontispeice = params?[index]
            self.params?.remove(at: index)
        } else {
            self.params = params
        }
        dataSource = propertyDetails?.features
    }
}

struct EditPlansDataSource {
    var dataSource: [String]?

    init(_ propertyDetails: PropertyDetails?) {
        dataSource = propertyDetails?.floorPlans?.components(separatedBy: ",")
    }
}

struct EditDescriptionDataSource {
    var dataSource: String?

    init(_ propertyDetails: PropertyDetails?) {
        dataSource = propertyDetails?.description
    }
}

struct EditPriceDataSource {
    var params: [Price]?
    var salePrice: String?
    var rentPrice: [PriceRent]?
    let defaultPriceType: String?

    init(_ propertyDetails: PropertyDetails?, and params: [Price]?) {
        self.params = params
        salePrice = propertyDetails?.defaultPrice
        rentPrice = propertyDetails?.priceRent
        defaultPriceType = propertyDetails?.defaultPriceType?.key
    }
}

struct SavePropertyDataSource {
    let propertyID: String?
    var features: String?
    var amenities: String?
    var details: String?
    var description: String?
    var price: String?
    var listedFor: String?
    var defaultPriceType: String?

    init(with propertyID: String?) {
        self.propertyID = propertyID
    }

    mutating func updateFeatures(with data: [Room]?) {
        guard let data = data else { return }

        features = data.compactMap { feature -> String? in
            guard let key = feature.key, let value = feature.value else { return nil }

            return "\(key):\(value)"
        }.joined(separator: ",")
    }

    mutating func updateAmenities(with data: [Amenity]?) {
        guard let data = data else { return }

        amenities = data.compactMap { amenity -> String? in
            guard let key = amenity.key else { return nil }

            return "\(key)"
        }.joined(separator: ",")
    }

    mutating func updateDetails(with data: [Feature]?) {
        guard let data = data else { return }

        details = data.compactMap { detail -> String? in
            guard let key = detail.key, let value = detail.value else { return nil }

            return "\(key):\(value)"
        }.joined(separator: ",")
    }

    mutating func updateDescription(with data: String?) {
        guard let data = data else { return }

        description = data
    }

    mutating func updateSalePrice(with price: String?, _ listedFor: String?, _ defaultPriceType: String?) {
        guard let price = price else { return }

        self.price = price
        self.listedFor = listedFor
        self.defaultPriceType = defaultPriceType
    }

    mutating func updateRentPrice(with price: [PriceRent]?, _ listedFor: String?, _ defaultPriceType: String?) {
        guard let price = price else { return }

        self.listedFor = listedFor
        self.defaultPriceType = defaultPriceType

        self.price = price.compactMap { price -> String? in
            guard let key = price.key, let value = price.value else { return nil }

            return "\(key):\(value)"
        }.joined(separator: ",")
    }
}
