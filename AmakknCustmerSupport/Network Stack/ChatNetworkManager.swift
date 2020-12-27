//
//  ChatNetworkManager.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import Foundation

// MARK: - Inbox APIs End Points
enum ChatAPIEndPoint: APIEndPoint {
    case getOnlineStatus(_ userID: String)
    case saveOnlineStatus(_ state: String)
    case none
}

// MARK: - API URL
extension ChatNetworkManager {
    internal var urlString: String {
        switch endPoint {
            case .getOnlineStatus(_): return "\(baseURL)getState/"
            case .saveOnlineStatus(_): return "\(baseURL)saveState/"
            case .none: return ""
        }
    }
}

// MARK: - API Method
extension ChatNetworkManager {
    internal var method: HTTPMethod {
        switch endPoint {
            default: return .post
        }
    }
}

// MARK: - API Parameters
extension ChatNetworkManager {
    internal var params: [String: Any]? {
        switch endPoint {
            case .getOnlineStatus(let userID):
                return ["userId": userID]
            case .saveOnlineStatus(let state):
                return ["userId": AppSession.manager.userID ?? "", "state": state, "lastSeen": Utility.shared.currentDate]
            default: return nil
        }
    }
}

// MARK: - API Header
extension ChatNetworkManager {
    internal var header: String {
        return "application/json"
    }
}

class ChatNetworkManager: ConfigRequestDelegate {
    static let shared = ChatNetworkManager()

    private var endPoint: ChatAPIEndPoint = .none
    internal var selectedLanguage = Utility.shared.selectedLanguage.rawValue
    internal var hashedUserID = Utility.shared.getHashedUserID()
    internal let baseURL = "https://prodchat.amakkn.com/"

    private init() { }

    internal func getRequest(with endPoint: APIEndPoint) -> URLRequest? {
        self.endPoint = endPoint as? ChatAPIEndPoint ?? .none

        let configRequest = ConfigRequest(endPoint)
        configRequest.delegate = self
        hashedUserID = Utility.shared.getHashedUserID()

        return configRequest.request
    }
}

// MARK: - Get Online Status
extension ChatNetworkManager {
    func getOnlineStatus(for userID: String, callBack: @escaping (_ responseModel: UserStatusModel?) -> Void) {
        let request = getRequest(with: ChatAPIEndPoint.getOnlineStatus(userID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<UserStatusModel>.self, from: resData)

                callBack(model.response)
            } catch _ {
                // Do nothing
            }
        }, failureCallBack: { _ in
            // Do nothing
        })
    }
}

// MARK: - Save Online Status
extension ChatNetworkManager {
    func saveOnline(state: String) {
        let request = getRequest(with: ChatAPIEndPoint.saveOnlineStatus(state))

        BaseNetworkManager.shared.fetch(request, successCallBack: { _ in }, failureCallBack: { _ in })
    }
}
