//
//  PropertyNetworkManager.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 04/01/21.
//

import Foundation

// MARK: - Properties APIs End Points
enum PropertyAPIEndPoint: APIEndPoint {
    case getAllParamsForProperty(_ propertyType: String)
    case getProperties(_ page: String, _ pageSize: String, _ searchQuery: String)
    case getPropertyDetails(_ userID: String, _ propertyID: String)
    case savePropertyFeatures(_ propertyID: String, _ features: String)
    case savePropertyAmenities(_ propertyID: String, _ amenities: String)
    case savePropertyDetails(_ propertyID: String, _ details: String)
    case savePropertyDescription(_ propertyID: String, _ description: String)
    case savePropertyPrice(_ propertyID: String, _ price: String, _ listedFor: String, _ defaultPriceType: String)
    case updatePropertyImages(_ images: String, _ propertyID: String)
    case deletePlans(_ plans: String, _ propertyID: String)
    case none
}

// MARK: - API URL
extension PropertyNetworkManager {
    internal var urlString: String {
        switch endPoint {
        case .getAllParamsForProperty(_): return "Property/getAllParamsForAddPropertyForPropertyType/"
        case .getProperties(_, _, _): return "Extras/getPropertiesForSearchQuery/"
        case .getPropertyDetails(_, _): return "Property/getPropertyDescription/"
        case .savePropertyFeatures(_, _): return "Property/savePropertyRooms/"
        case .savePropertyAmenities(_, _): return "Property/savePropertyAmenities/"
        case .savePropertyDetails(_, _): return "Property/savePropertyFeatures/"
        case .savePropertyDescription(_, _): return "Property/savePropertyDescription/"
        case .savePropertyPrice(_, _, _, _): return "Property/savePropertyPriceNew/"
        case .updatePropertyImages(_, _): return "Property/savePropertyPhotos/"
        case .deletePlans(_, _): return "Property/savePropertyFloorPlans/"
        case .none: return ""
        }
    }
}

// MARK: - API Method
extension PropertyNetworkManager {
    internal var method: HTTPMethod {
        return .post
    }
}

// MARK: - API Parameters
extension PropertyNetworkManager {
    internal var params: [String: Any]? {
        switch endPoint {
            case .getAllParamsForProperty(let propertyType):
                return ["propertyType": propertyType, "language": selectedLanguage]
            case .getProperties(let page, let pageSize, let searchQuery):
                return ["page": page, "pageSize": pageSize, "searchQuery": searchQuery, "userId": hashedUserID]
            case .getPropertyDetails(let userID, let propertyID):
                return ["userId": userID, "propertyId": propertyID, "language": selectedLanguage]
            case .savePropertyFeatures(let propertyID, let features):
                return ["userId": hashedUserID, "propertyId": propertyID, "rooms": features]
            case .savePropertyAmenities(let propertyID, let amenities):
                return ["userId": hashedUserID, "propertyId": propertyID, "amenities": amenities]
            case .savePropertyDetails(let propertyID, let details):
                return ["userId": hashedUserID, "propertyId": propertyID, "features": details]
            case .savePropertyDescription(let propertyID, let description):
                return ["userId": hashedUserID, "propertyId": propertyID, "description": description]
            case .savePropertyPrice(let propertyID, let price, let listedFor, let defaultPriceType):
                return ["userId": hashedUserID, "propertyId": propertyID, "price": price, "listedFor": listedFor, "defaultPriceType": defaultPriceType]
            case .updatePropertyImages(let images, let propertyID):
                return ["userId": hashedUserID, "propertyId": propertyID, "photos": images]
            case .deletePlans(let plans, let propertyID):
                return ["userId": hashedUserID, "propertyId": propertyID, "floorPlans": plans]
            default:
                return nil
        }
    }
}

// MARK: - API Header
extension PropertyNetworkManager {
    internal var header: String {
        return "text/plain"
    }
}

class PropertyNetworkManager: ConfigRequestDelegate {
    static let shared = PropertyNetworkManager()

    private var endPoint: PropertyAPIEndPoint = .none
    internal var selectedLanguage = "1"
    internal var hashedUserID = Utility.shared.getHashedUserID()

    private init() { }

    internal func getRequest(with endPoint: APIEndPoint) -> URLRequest? {
        self.endPoint = endPoint as? PropertyAPIEndPoint ?? .none

        let configRequest = ConfigRequest(endPoint)
        configRequest.delegate = self
        hashedUserID = Utility.shared.getHashedUserID()

        return configRequest.request
    }
}

// MARK: - Properties APIs
extension PropertyNetworkManager {
    func getParams(for propertyType: String, successCallBack: @escaping (_ response: AddPropertyParams?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: PropertyAPIEndPoint.getAllParamsForProperty(propertyType))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<AddPropertyParams>.self, from: resData)

                successCallBack(model.response)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }

    func getProperties(for page: String, _ pageSize: String, with searchQuery: String, successCallBack: @escaping (_ response: PropertyResponseModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: PropertyAPIEndPoint.getProperties(page, pageSize, searchQuery))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<PropertyResponseModel>.self, from: resData)

                successCallBack(model.response)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }

    func getPropertyDetails(for userID: String, and propertyID: String, successCallBack: @escaping (_ response: PropertyDetails?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: PropertyAPIEndPoint.getPropertyDetails(userID, propertyID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<PropertyDetails>.self, from: resData)

                successCallBack(model.response)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}

// MARK: - Save Property APIs
extension PropertyNetworkManager {
    func saveProperty(with dataSource: SavePropertyDataSource, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        guard let propertyID = dataSource.propertyID else { return }

        var errorText: String?
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        saveFeatures(for: propertyID, dataSource.features) { errorStr in
            defer { dispatchGroup.leave() }

            if let errorStr = errorStr {
                errorText = errorStr
            }
        }

        dispatchGroup.enter()
        saveAmenities(for: propertyID, dataSource.amenities) { errorStr in
            defer { dispatchGroup.leave() }

            if let errorStr = errorStr {
                errorText = errorStr
            }
        }

        dispatchGroup.enter()
        saveDetails(for: propertyID, dataSource.details) { errorStr in
            defer { dispatchGroup.leave() }

            if let errorStr = errorStr {
                errorText = errorStr
            }
        }

        dispatchGroup.enter()
        saveDescription(for: propertyID, dataSource.description) { errorStr in
            defer { dispatchGroup.leave() }

            if let errorStr = errorStr {
                errorText = errorStr
            }
        }

        dispatchGroup.enter()
        savePrice(for: propertyID, dataSource.price, dataSource.listedFor, dataSource.defaultPriceType) { errorStr in
            defer { dispatchGroup.leave() }

            if let errorStr = errorStr {
                errorText = errorStr
            }
        }

        dispatchGroup.notify(queue: .main) {
            guard let errorText = errorText else { successCallBack(); return }

            failureCallBack(errorText)
        }
    }

    private func saveFeatures(for propertyID: String, _ features: String?, callBack: @escaping (_ errorStr: String?) -> Void) {
        guard let features = features else { return }

        let request = getRequest(with: PropertyAPIEndPoint.savePropertyFeatures(propertyID, features))

        BaseNetworkManager.shared.fetch(request) { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let respCode = jsonDictionary["resCode"] as? Int else { return }

                callBack((respCode == 0) ? nil : jsonDictionary["resStr"] as? String)
            } catch _ {
                callBack("Invalid JSON.")
            }
        } failureCallBack: { errorStr in
            callBack(errorStr)
        }
    }

    private func saveAmenities(for propertyID: String, _ amenities: String?, callBack: @escaping (_ errorStr: String?) -> Void) {
        guard let amenities = amenities else { return }

        let request = getRequest(with: PropertyAPIEndPoint.savePropertyAmenities(propertyID, amenities))

        BaseNetworkManager.shared.fetch(request) { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let respCode = jsonDictionary["resCode"] as? Int else { return }

                callBack((respCode == 0) ? nil : jsonDictionary["resStr"] as? String)
            } catch _ {
                callBack("Invalid JSON.")
            }
        } failureCallBack: { errorStr in
            callBack(errorStr)
        }
    }

    private func saveDetails(for propertyID: String, _ details: String?, callBack: @escaping (_ errorStr: String?) -> Void) {
        guard let details = details else { return }

        let request = getRequest(with: PropertyAPIEndPoint.savePropertyDetails(propertyID, details))

        BaseNetworkManager.shared.fetch(request) { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let respCode = jsonDictionary["resCode"] as? Int else { return }

                callBack((respCode == 0) ? nil : jsonDictionary["resStr"] as? String)
            } catch _ {
                callBack("Invalid JSON.")
            }
        } failureCallBack: { errorStr in
            callBack(errorStr)
        }
    }

    private func saveDescription(for propertyID: String, _ description: String?, callBack: @escaping (_ errorStr: String?) -> Void) {
        guard let description = description else { return }

        let request = getRequest(with: PropertyAPIEndPoint.savePropertyDescription(propertyID, description))

        BaseNetworkManager.shared.fetch(request) { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let respCode = jsonDictionary["resCode"] as? Int else { return }

                callBack((respCode == 0) ? nil : jsonDictionary["resStr"] as? String)
            } catch _ {
                callBack("Invalid JSON.")
            }
        } failureCallBack: { errorStr in
            callBack(errorStr)
        }
    }

    private func savePrice(for propertyID: String, _ price: String?, _ listedFor: String?, _ defaultPriceType: String?, callBack: @escaping (_ errorStr: String?) -> Void) {
        guard let price = price, let listedFor = listedFor, let defaultPriceType = defaultPriceType else { return }

        let request = getRequest(with: PropertyAPIEndPoint.savePropertyPrice(propertyID, price, listedFor, defaultPriceType))

        BaseNetworkManager.shared.fetch(request) { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let respCode = jsonDictionary["resCode"] as? String else { return }

                callBack((respCode == "0") ? nil : jsonDictionary["resStr"] as? String)
            } catch _ {
                callBack("Invalid JSON.")
            }
        } failureCallBack: { errorStr in
            callBack(errorStr)
        }
    }
}

// MARK: - Update Property Images
extension PropertyNetworkManager {
    func updateProperty(_ images: String, for propertyID: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: PropertyAPIEndPoint.updatePropertyImages(images, propertyID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let respCode = jsonDictionary["resCode"] as? Int else { return }

                respCode == 0 ? successCallBack() : failureCallBack(jsonDictionary["resStr"] as? String)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}

// MARK: - Delete Plans
extension PropertyNetworkManager {
    func delete(_ plans: String, for propertyID: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: PropertyAPIEndPoint.deletePlans(plans, propertyID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let respCode = jsonDictionary["resCode"] as? Int else { return }

                respCode == 0 ? successCallBack() : failureCallBack(jsonDictionary["resStr"] as? String)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}
