//
//  AppNetworkManager.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 13/10/20.
//

import Foundation

// MARK: - App APIs End Points
enum AppAPIEndPoint: APIEndPoint {
    case getAppDomains
    case login(_ countryCode: String, _ phone: String, _ pwd: String)
    case saveFCMToken
    case logout
    case getBadgeCount
    case getSupportChats(_ page: String, _ pageSize: String, _ subjectID: String)
    case getProperties(_ page: String, _ pageSize: String)
    case getPropertyDetails(_ userID: String, _ propertyID: String)
    case getListOfSubjects
    case saveLastMessage(_ userID1: String, _ userID2: String, _ subjectID: String, _ lastMessage: String)
    case initChat(_ userID1: String, _ userID2: String, _ subjectID: String)
    case getAbuseList
    case getStatsDetails(_ startDate: String, _ endDate: String)
    case none
}

// MARK: - API URL
extension AppNetworkManager {
    internal var urlString: String {
        switch endPoint {
            case .getAppDomains: return "SystemVariables/getListOfDomains/"
            case .login(_, _, _): return "Login/loginUser/"
            case .saveFCMToken: return "Login/setPushTokenForUserNew/"
            case .logout: return "Login/logoutUser/"
            case .getBadgeCount: return "Login/getCSUnreadChatsCount/"
            case .getSupportChats(_, _, _): return "Login/getListOfChannelsForCustomerSupport/"
            case .getProperties(_, _): return "Property/getPropertiesForAdmin/"
            case .getPropertyDetails(_, _): return "Property/getPropertyDescription/"
            case .getListOfSubjects: return "Login/getListOfSubjects/"
            case .saveLastMessage(_, _, _, _): return "Login/saveSupportLastMessage/"
            case .initChat(_, _, _): return "Login/initiateSupportChatChannel/"
            case .getAbuseList: return "Property/getListOfReportAbuses/"
            case .getStatsDetails(_, _): return "Property/getStats/"
            case .none: return ""
        }
    }
}

// MARK: - API Method
extension AppNetworkManager {
    internal var method: HTTPMethod {
        switch endPoint {
            case .getAbuseList: return .get
            default: return .post
        }
    }
}

// MARK: - API Parameters
extension AppNetworkManager {
    internal var params: [String: Any]? {
        switch endPoint {
            case .getAppDomains:
                return ["language": selectedLanguage]
            case .login(let countryCode, let phone, let pwd):
                return ["countryCode": countryCode, "phone": phone, "password": pwd, "language": selectedLanguage]
            case .saveFCMToken:
                return ["userId": hashedUserID, "pushToken": AppUserDefaults.manager.pushFCMToken ?? "", "platform": Utility.shared.appPlatform, "language": selectedLanguage, "identifier": Utility.shared.deviceIdentifier]
            case .logout:
                return ["userId": hashedUserID, "pushToken": AppUserDefaults.manager.pushFCMToken ?? "abcd"]
            case .getBadgeCount:
                return ["userId": hashedUserID]
            case .getSupportChats(let page, let pageSize, let subjectID):
                return ["page": page, "pageSize": pageSize, "userId": hashedUserID, "language": selectedLanguage, "subjectId": subjectID]
            case .getProperties(let page, let pageSize):
                return ["page": page, "pageSize": pageSize, "sortBy": "updatedAt", "sortOrder": "desc", "status": "published", "searchString": "", "searchOperator": "AND"]
            case .getPropertyDetails(let userID, let propertyID):
                return ["userId": userID, "propertyId": propertyID, "language": selectedLanguage]
            case .getListOfSubjects:
                return ["language": selectedLanguage]
            case .saveLastMessage(let userID1, let userID2, let subjectID, let lastMessage):
                return ["userId1": userID1, "userId2": userID2, "subjectId": subjectID, "lastMessage": lastMessage]
            case .initChat(let userID1, let userID2, let subjectID):
                return ["userId1": userID1, "userId2": userID2, "subjectId": subjectID]
            case .getStatsDetails(let startDate, let endDate):
                return ["startDate": startDate, "endDate": endDate]
            default:
                return nil
        }
    }
}

// MARK: - API Header
extension AppNetworkManager {
    internal var header: String {
        return "text/plain"
    }
}

class AppNetworkManager: ConfigRequestDelegate {
    static let shared = AppNetworkManager()

    private var endPoint: AppAPIEndPoint = .none
    internal var selectedLanguage = "1"
    internal var hashedUserID = Utility.shared.getHashedUserID()

    private init() { }

    internal func getRequest(with endPoint: APIEndPoint) -> URLRequest? {
        self.endPoint = endPoint as? AppAPIEndPoint ?? .none

        let configRequest = ConfigRequest(endPoint)
        configRequest.delegate = self
        hashedUserID = Utility.shared.getHashedUserID()

        return configRequest.request
    }
}

// MARK: - APIs Call
extension AppNetworkManager {
    func getSupportChats(for page: String, with pageSize: String, _ subjectID: String, successCallBack: @escaping (_ response: InboxResponseModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: AppAPIEndPoint.getSupportChats(page, pageSize, subjectID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<InboxResponseModel>.self, from: resData)

                successCallBack(model.response)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }

    func getProperties(for page: String, with pageSize: String, successCallBack: @escaping (_ response: PropertyResponseModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: AppAPIEndPoint.getProperties(page, pageSize))

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

    func getSubjects(successCallBack: @escaping (_ response: [ChatSubjectModel]?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: AppAPIEndPoint.getListOfSubjects)

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<[ChatSubjectModel]>.self, from: resData)

                successCallBack(model.response)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }

    func getPropertyDetails(for userID: String, and propertyID: String, successCallBack: @escaping (_ response: PropertyDetails?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: AppAPIEndPoint.getPropertyDetails(userID, propertyID))

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

// MARK: - Messages APIs
extension AppNetworkManager {
    func saveLastMessage(for userID1: String, _ userID2: String, _ subjectID: String, _ lastMessage: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: AppAPIEndPoint.saveLastMessage(userID1, userID2, subjectID, lastMessage))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<PropertyDetails>.self, from: resData)

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

    func initChat(for userID1: String, _ userID2: String, _ subjectID: String, successCallBack: @escaping (_ channelID: String?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: AppAPIEndPoint.initChat(userID1, userID2, subjectID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let resDict = jsonDictionary["response"] as? [String: Any] else { return }
                guard let chatDict = resDict["chat"] as? [String: Any], let channelID = chatDict["channelId"] as? String else { return }

                successCallBack(channelID)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}

// MARK: - Domain List API
extension AppNetworkManager {
    func getDomain() {
        let request = getRequest(with: AppAPIEndPoint.getAppDomains)

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<[AppDomainResponse]>.self, from: resData)

                if let domains = model.response?.first?.countryCodes {
                    AppUserDefaults.manager.save(domains: domains)
                }
            } catch _ { }
        }, failureCallBack: { _ in })
    }
}

// MARK: - Login API
extension AppNetworkManager {
    func login(with countryCode: String, _ phone: String, and pwd: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: AppAPIEndPoint.login(countryCode, phone, pwd))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<UserResponse>.self, from: resData)

                if model.resCode == 0, let user = model.response?.user {
                    if user.userType == "6" {
                        AppUserDefaults.manager.save(user: user)
                        AppSession.manager.updateUser()

                        successCallBack()
                    } else {
                        failureCallBack("This User cannot use this App.")
                    }
                } else {
                    failureCallBack(model.resStr)
                }
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}

// MARK: - Logout API
extension AppNetworkManager {
    func logout(successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: AppAPIEndPoint.logout)

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<UserResponse>.self, from: resData)

                if model.resCode == 0 {
                    AppSession.manager.resetAppSession()
                    SocketIOManager.sharedInstance.closeConnection()
                    SocketIOManager.sharedInstance.dataProvider.clearCodeData()

                    successCallBack()
                } else {
                    failureCallBack(model.resStr)
                }
            } catch _ { }
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }
}

// MARK: - Abuse API
extension AppNetworkManager {
    func getAbuseList(successCallBack: @escaping (_ response: [AbuseModel]?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: AppAPIEndPoint.getAbuseList)

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<[AbuseModel]>.self, from: resData)

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

// MARK: - Badge count API
extension AppNetworkManager {
    func getBadge() {
        let request = getRequest(with: AppAPIEndPoint.getBadgeCount)

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let badgeCount = jsonDictionary["response"] as? String else { return }

                Utility.shared.update(badgeCount: badgeCount)
            } catch _ { }
        }, failureCallBack: { _ in })
    }
}

// MARK: - Update Token
extension AppNetworkManager {
    func updateToken() {
        let request = getRequest(with: AppAPIEndPoint.saveFCMToken)

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let _ = try decoder.decode(ResponseModel<UserResponse>.self, from: resData)
            } catch _ { }
        }, failureCallBack: { _ in })
    }
}

// MARK: - Stats Details API
extension AppNetworkManager {
    func getStatsDetails(from startDate: String, to endDate: String, successCallBack: @escaping (_ responseDict: [String: Any]?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: AppAPIEndPoint.getStatsDetails(startDate, endDate))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let responseDict = jsonDictionary["response"] as? [String: Any] else { return }

                successCallBack(responseDict)
            } catch _ { }
        }, failureCallBack: { _ in })
    }
}
