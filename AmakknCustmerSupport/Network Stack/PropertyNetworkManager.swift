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
    case none
}

// MARK: - API URL
extension PropertyNetworkManager {
    internal var urlString: String {
        switch endPoint {
        case .getAllParamsForProperty(_): return "Property/getAllParamsForAddPropertyForPropertyType/"
        case .getProperties(_, _, _): return "Extras/getPropertiesForSearchQuery/"
        case .getPropertyDetails(_, _): return "Property/getPropertyDescription/"
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

// MARK: - Properties API
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
