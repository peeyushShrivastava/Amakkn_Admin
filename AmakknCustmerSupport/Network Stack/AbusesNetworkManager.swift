//
//  AbusesNetworkManager.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 24/12/20.
//

import Foundation

// MARK: - Abuses APIs End Points
enum AbusesAPIEndPoint: APIEndPoint {
    case getAbuses(_ page: String, _ pageSize: String, _ sortOrder: String)
    case getComplaints(_ propertyID: String)
    case resolveComplaints(_ complaintIDs: String)
    case none
}

// MARK: - API URL
extension AbusesNetworkManager {
    internal var urlString: String {
        switch endPoint {
            case .getAbuses(_, _, _): return "Extras/getReportedProperties/"
            case .getComplaints(_): return "Extras/getComplaintsForProperty/"
            case .resolveComplaints(_): return "Extras/resolveComplaints/"
            case .none: return ""
        }
    }
}

// MARK: - API Method
extension AbusesNetworkManager {
    internal var method: HTTPMethod {
        return .post
    }
}

// MARK: - API Parameters
extension AbusesNetworkManager {
    internal var params: [String: Any]? {
        switch endPoint {
        case .getAbuses(let page, let pageSize, let sortOrder):
            return ["page": page, "pageSize": pageSize, "userId": hashedUserID, "sortOrder": sortOrder]
            case .getComplaints(let propertyID):
                return ["propertyId": propertyID, "userId": hashedUserID]
            case .resolveComplaints(let complaintIDs):
                return ["complaintIds": complaintIDs, "userId": hashedUserID]
            default:
                return nil
        }
    }
}

// MARK: - API Header
extension AbusesNetworkManager {
    internal var header: String {
        return "text/plain"
    }
}

class AbusesNetworkManager: ConfigRequestDelegate {
    static let shared = AbusesNetworkManager()

    private var endPoint: AbusesAPIEndPoint = .none
    internal var selectedLanguage = "1"
    internal var hashedUserID = Utility.shared.getHashedUserID()

    private init() { }

    internal func getRequest(with endPoint: APIEndPoint) -> URLRequest? {
        self.endPoint = endPoint as? AbusesAPIEndPoint ?? .none

        let configRequest = ConfigRequest(endPoint)
        configRequest.delegate = self
        hashedUserID = Utility.shared.getHashedUserID()

        return configRequest.request
    }
}

// MARK: - Get Abuses API Call
extension AbusesNetworkManager {
    func getAbuses(for page: String, with pageSize: String, _ sortOrder: String, successCallBack: @escaping (_ response: AbusesModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: AbusesAPIEndPoint.getAbuses(page, pageSize, sortOrder))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<AbusesModel>.self, from: resData)

                successCallBack(model.response)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}

// MARK: - Get Complaints API Call
extension AbusesNetworkManager {
    func getComplaints(for propertyID: String, successCallBack: @escaping (_ response: ComplaintResponseModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: AbusesAPIEndPoint.getComplaints(propertyID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<ComplaintResponseModel>.self, from: resData)

                successCallBack(model.response)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}

// MARK: - Resolve Complaints API Call
extension AbusesNetworkManager {
    func resolveComplaints(for complaintIDs: String) {
        let request = getRequest(with: AbusesAPIEndPoint.resolveComplaints(complaintIDs))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let _ = try decoder.decode(ResponseModel<ComplaintResponseModel>.self, from: resData)
            } catch _ { }
        }, failureCallBack: { _ in })
    }
}
