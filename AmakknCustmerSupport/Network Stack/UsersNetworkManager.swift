//
//  UsersNetworkManager.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 24/12/20.
//

import Foundation

// MARK: - Users APIs End Points
enum UsersAPIEndPoint: APIEndPoint {
    case getSearchedUsers(_ page: String, _ pageSize: String, _ searchQuery: String)
    case getUsers(_ page: String, _ pageSize: String, _ sortBy: String, _ sortOrder: String, _ searchString: String, _ searchOperator: String)
    case getUserProperties(_ propertyIDs: String)
    case changeUserStatus(_ userID: String, _ status: String)
    case sendNotification(_ userID: String, _ title: String, _ body: String)
    case none
}

// MARK: - API URL
extension UsersNetworkManager {
    internal var urlString: String {
        switch endPoint {
            case .getSearchedUsers(_, _, _): return "Extras/getUsersForSearchQuery/"
            case .getUsers(_, _, _, _, _, _): return "Extras/getUserStatsNew/"
            case .getUserProperties(_): return "Property/getPropertyDescriptionsForAdmin/"
            case .changeUserStatus(_, _): return "Login/changeUserStatus/"
            case .sendNotification(_, _, _): return "Login/sendCustomNotification1/"
            case .none: return ""
        }
    }
}

// MARK: - API Method
extension UsersNetworkManager {
    internal var method: HTTPMethod {
        return .post
    }
}

// MARK: - API Parameters
extension UsersNetworkManager {
    internal var params: [String: Any]? {
        switch endPoint {
            case .getSearchedUsers(let page, let pageSize, let searchQuery):
                return ["userId": hashedUserID, "page": page, "pageSize": pageSize, "searchQuery": searchQuery]
            case .getUsers(let page, let pageSize, let sortBy, let sortOrder, let searchString, let searchOperator):
                return ["page": page, "pageSize": pageSize, "sortBy": sortBy, "sortOrder": sortOrder, "searchString": searchString, "searchOperator": searchOperator]
            case .getUserProperties(let propertyIDs):
                return ["propertyIds": propertyIDs, "userId": hashedUserID]
            case .changeUserStatus(let userID, let status):
                return ["userId": userID, "status": status, "adminId": hashedUserID]
            case .sendNotification(let userID, let title, let body):
                return ["userId": userID, "title": title, "body": body, "adminId": hashedUserID]
            default:
                return nil
        }
    }
}

// MARK: - API Header
extension UsersNetworkManager {
    internal var header: String {
        return "text/plain"
    }
}

class UsersNetworkManager: ConfigRequestDelegate {
    static let shared = UsersNetworkManager()

    private var endPoint: UsersAPIEndPoint = .none
    internal var selectedLanguage = "1"
    internal var hashedUserID = Utility.shared.getHashedUserID()

    private init() { }

    internal func getRequest(with endPoint: APIEndPoint) -> URLRequest? {
        self.endPoint = endPoint as? UsersAPIEndPoint ?? .none

        let configRequest = ConfigRequest(endPoint)
        configRequest.delegate = self
        hashedUserID = Utility.shared.getHashedUserID()

        return configRequest.request
    }
}

// MARK: - Get Users API Call
extension UsersNetworkManager {
    func getUser(for page: String, with pageSize: String, _ sortBy: String, _ sortOrder: String, _ searchString: String, _ searchOperator: String, successCallBack: @escaping (_ response: UsersReponseModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: UsersAPIEndPoint.getUsers(page, pageSize, sortBy, sortOrder, searchString, searchOperator))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<UsersReponseModel>.self, from: resData)

                successCallBack(model.response)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }

    func getUsers(for page: String, with pageSize: String, _ sortBy: String, _ sortOrder: String, _ searchString: String, _ searchOperator: String, successCallBack: @escaping (_ response: FilteredUsersReponseModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: UsersAPIEndPoint.getUsers(page, pageSize, sortBy, sortOrder, searchString, searchOperator))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<FilteredUsersReponseModel>.self, from: resData)

                successCallBack(model.response)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}

// MARK: - Get Searched Users API Call
extension UsersNetworkManager {
    func getSearchedUsers(for page: String, with pageSize: String, _ searchQuery: String, successCallBack: @escaping (_ response: SearchedUsersReponseModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: UsersAPIEndPoint.getSearchedUsers(page, pageSize, searchQuery))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<SearchedUsersReponseModel>.self, from: resData)

                successCallBack(model.response)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}

// MARK: - Get Users Properties API Call
extension UsersNetworkManager {
    func getUserProperties(for propertyIDs: String, successCallBack: @escaping (_ response: [PropertyCardsModel]?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: UsersAPIEndPoint.getUserProperties(propertyIDs))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<[PropertyCardsModel]>.self, from: resData)

                successCallBack(model.response)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}

// MARK: - Change Users Status API Call
extension UsersNetworkManager {
    func changeUserStatus(for userID: String, _ status: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: UsersAPIEndPoint.changeUserStatus(userID, status))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<UsersReponseModel>.self, from: resData)

                if model.resCode == 0 {
                    successCallBack()

                    return
                }

                failureCallBack(model.resStr)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}

// MARK: - Send Ntification API Call
extension UsersNetworkManager {
    func sendNotification(for userID: String, _ title: String, _ body: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: UsersAPIEndPoint.sendNotification(userID, title, body))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<UsersReponseModel>.self, from: resData)

                if model.resCode == 0 {
                    successCallBack()

                    return
                }

                failureCallBack(model.resStr)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}
