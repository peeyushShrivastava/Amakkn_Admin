//
//  MoreNetworkManager.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 31/12/20.
//

import Foundation

// MARK: - Abuses APIs End Points
enum MoreAPIEndPoint: APIEndPoint {
    case getFeedbacks(_ page: String, _ pageSize: String)
    case none
}

// MARK: - API URL
extension MoreNetworkManager {
    internal var urlString: String {
        switch endPoint {
            case .getFeedbacks(_, _): return "Feedback/getFeedback/"
            case .none: return ""
        }
    }
}

// MARK: - API Method
extension MoreNetworkManager {
    internal var method: HTTPMethod {
        return .post
    }
}

// MARK: - API Parameters
extension MoreNetworkManager {
    internal var params: [String: Any]? {
        switch endPoint {
            case .getFeedbacks(let page, let pageSize):
                return ["page": page, "pageSize": pageSize]
            default:
                return nil
        }
    }
}

// MARK: - API Header
extension MoreNetworkManager {
    internal var header: String {
        return "text/plain"
    }
}

class MoreNetworkManager: ConfigRequestDelegate {
    static let shared = MoreNetworkManager()

    private var endPoint: MoreAPIEndPoint = .none
    internal var selectedLanguage = "1"
    internal var hashedUserID = Utility.shared.getHashedUserID()

    private init() { }

    internal func getRequest(with endPoint: APIEndPoint) -> URLRequest? {
        self.endPoint = endPoint as? MoreAPIEndPoint ?? .none

        let configRequest = ConfigRequest(endPoint)
        configRequest.delegate = self
        hashedUserID = Utility.shared.getHashedUserID()

        return configRequest.request
    }
}

// MARK: - Abuse API
extension MoreNetworkManager {
    func getFeedbackList(for page: String, pageSize: String, successCallBack: @escaping (_ response: FeedbackResponseModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: MoreAPIEndPoint.getFeedbacks(page, pageSize))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<FeedbackResponseModel>.self, from: resData)

                if model.resCode == 0 {
                    successCallBack(model.response)
                } else {
                    failureCallBack(model.resStr)
                }
            } catch _ { }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}
