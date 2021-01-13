//
//  MoreNetworkManager.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 31/12/20.
//

import Foundation

// MARK: - More APIs End Points
enum MoreAPIEndPoint: APIEndPoint {
    case getFeedbacks(_ page: String, _ pageSize: String, _ status: String)
    case changeFeedbackStatus(_ status: String, _ feedbackID: String)
    case none
}

// MARK: - API URL
extension MoreNetworkManager {
    internal var urlString: String {
        switch endPoint {
            case .getFeedbacks(_, _, _): return "Feedback/getFeedback/"
            case .changeFeedbackStatus(_, _): return "Feedback/changeFeedbackStatus/"
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
            case .getFeedbacks(let page, let pageSize, let status):
                return ["page": page, "pageSize": pageSize, "status": status]
            case .changeFeedbackStatus(let status, let feedbackID):
                return ["feedbackId": feedbackID, "status": status]
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

// MARK: - More API
extension MoreNetworkManager {
    func getFeedbackList(for page: String, _ pageSize: String, _ status: String, successCallBack: @escaping (_ response: FeedbackResponseModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: MoreAPIEndPoint.getFeedbacks(page, pageSize, status))

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

    func changeFeedback(_ status: String, for feedbackID: String) {
        let request = getRequest(with: MoreAPIEndPoint.changeFeedbackStatus(status, feedbackID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let _ = jsonDictionary["resCode"] as? Int else { return }
            } catch _ { }
        }, failureCallBack: { _ in })
    }
}
