//
//  TicketsNetworkManager.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import Foundation
import AWSS3
import AWSCore

// MARK: - Tickets APIs End Points
enum TicketsAPIEndPoint: APIEndPoint {
    case getSubjects
    case getStatusList
    case getViolationUserList
    case getTickets(_ status: String, _ subject: String, _ searchQuery: String, _ page: String, _ pageSize: String)
    case getTicketDetails(_ ticketID: String)
    case getViolationList(_ violatingUserID: String)
    case addComment(_ text: String, _ ticketID: String, _ statusID: String)
    case changeStatus(_ note: String, _ ticketID: String, _ status: String, _ statusID: String)
    case addScreenShot(_ images: String, _ fileType: String, _ ticketID: String, _ statusID: String)
    case createTicket(_ userID: String, _ parentTicketID: String, _ subjectID: String, _ images: String, _ fileType: String, _ notes: String, _ propertyID: String)
    case createViolation(_ userID: String, _ ticketID: String, _ message: String)
    case none
}

// MARK: - API URL
extension TicketsNetworkManager {
    internal var urlString: String {
        switch endPoint {
            case .getSubjects: return "Feedback/getTicketListSubjects/"
            case .getStatusList: return "Feedback/getTicketStatusList/"
            case .getViolationUserList: return "Feedback/getListOfViolatingUsers/"
            case .getTickets(_, _, _, _, _): return "Feedback/getMyTickets/"
            case .getTicketDetails(_): return "Feedback/getTicketDetails/"
            case .getViolationList(_): return "Feedback/getListOfViolations/"
            case .addComment(_, _, _): return "Feedback/addCommentToATicket/"
            case .changeStatus(_, _, _, _): return "Feedback/changeStatusOfATicket/"
            case .addScreenShot(_, _, _, _): return "Feedback/addScreenshotsToATicket/"
            case .createTicket(_, _, _, _, _, _, _): return "Feedback/createATicket/"
            case .createViolation(_, _, _): return "Feedback/addViolation/"
            case .none: return ""
        }
    }
}

// MARK: - API Parameters
extension TicketsNetworkManager {
    internal var params: [String: Any]? {
        switch endPoint {
            case .getSubjects: return ["language": selectedLanguage]
            case .getStatusList: return ["language": selectedLanguage]
            case .getViolationUserList: return ["userId": hashedUserID, "language": selectedLanguage]
            case .getTickets(let status, let subject, let searchQuery, let page, let pageSize): return ["userId": hashedUserID, "language": selectedLanguage, "status": status, "subjectId": subject, "phone": searchQuery, "page": page, "pageSize": pageSize]
            case .getTicketDetails(let ticketID): return ["ticketId": ticketID, "userId": hashedUserID, "language": selectedLanguage]
            case .getViolationList(let violatingUserID): return ["violatingUserIdNotHashed": violatingUserID, "userId": hashedUserID, "language": selectedLanguage]
            case .addComment(let comment, let ticketID, let statusID): return ["ticketId": ticketID, "userId": hashedUserID, "language": selectedLanguage, "text": comment, "statusId": statusID]
            case .changeStatus(let note, let ticketID, let status, let statusID): return ["ticketId": ticketID, "userId": hashedUserID, "language": selectedLanguage, "notes": note, "status": status, "fromStatusId": statusID]
            case .addScreenShot(let images, let fileType, let ticketID, let statusID): return ["ticketId": ticketID, "userId": hashedUserID, "language": selectedLanguage, "images": images, "statusId": statusID, "typeOfFile": fileType]
            case .createTicket(let userID, let parentTicketID, let subjectID, let images, let fileType, let notes, let propertyID): return ["subjectId": subjectID, "userId": userID, "parentTicketId": parentTicketID, "createdBy": hashedUserID, "language": selectedLanguage, "screenshots": images, "notes": notes, "propertyId": propertyID, "typeOfFile": fileType]
            case .createViolation(let userID, let ticketID, let message): return ["ticketId": ticketID, "userId": hashedUserID, "language": selectedLanguage, "violatingUserIdNotHashed": userID, "description": message]
            default:
                return nil
        }
    }
}

// MARK: - API Method
extension TicketsNetworkManager {
    internal var method: HTTPMethod {
        return .post
    }
}

// MARK: - API Header
extension TicketsNetworkManager {
    internal var header: String {
        return "text/plain"
    }
}

class TicketsNetworkManager: ConfigRequestDelegate {
    static let shared = TicketsNetworkManager()

    private var endPoint: TicketsAPIEndPoint = .none
    internal var selectedLanguage = ""
    internal var hashedUserID = ""

    private init() { }

    internal func getRequest(with endPoint: APIEndPoint) -> URLRequest? {
        self.endPoint = endPoint as? TicketsAPIEndPoint ?? .none

        let configRequest = ConfigRequest(endPoint)
        configRequest.delegate = self
        self.hashedUserID = Utility.shared.getHashedUserID()
        self.selectedLanguage = Utility.shared.selectedLanguage.rawValue

        return configRequest.request
    }
}

// MARK: - Get Ticket List
extension TicketsNetworkManager {
    func getTickets(for status: String, and subject: String, with searchQuery: String, at page: String, _ pageSize: String, successCallBack: @escaping (_ model: TicketListModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.getTickets(status, subject, searchQuery, page, pageSize))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<TicketListModel>.self, from: resData)

                if let resCode = model.resCode, let respModel = model.response {
                    if resCode == 0 {
                        respModel.tickets?.count ?? 0 > 0 ? successCallBack(respModel) : failureCallBack("No tickets available.")

                        return
                    }
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

// MARK: - Get Subject List
extension TicketsNetworkManager {
    func getSubjects(successCallBack: @escaping (_ model: SubListModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.getSubjects)

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<SubListModel>.self, from: resData)

                if let resCode = model.resCode, let respModel = model.response {
                    if resCode == 0 {
                        successCallBack(respModel)

                        return
                    }
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

// MARK: - Get Status List
extension TicketsNetworkManager {
    func getStatusList(successCallBack: @escaping (_ model: StatusListModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.getStatusList)

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<StatusListModel>.self, from: resData)

                if let resCode = model.resCode, let respModel = model.response {
                    if resCode == 0 {
                        successCallBack(respModel)

                        return
                    }
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

// MARK: - Get Violation User List
extension TicketsNetworkManager {
    func getViolationUsers(successCallBack: @escaping (_ model: [ViolationModel]?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.getViolationUserList)

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<[ViolationModel]>.self, from: resData)

                if let resCode = model.resCode, let respModel = model.response {
                    if resCode == 0 {
                        respModel.count > 0 ? successCallBack(respModel) : failureCallBack("No Violations available.")

                        return
                    }
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

// MARK: - Get Violation List
extension TicketsNetworkManager {
    func getViolations(for violatingUserID: String, successCallBack: @escaping (_ model: TicketListModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.getViolationList(violatingUserID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<TicketListModel>.self, from: resData)

                if let resCode = model.resCode, let respModel = model.response {
                    if resCode == 0 {
                        respModel.tickets?.count ?? 0 > 0 ? successCallBack(respModel) : failureCallBack("No tickets available.")

                        return
                    }
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
// MARK: - Get Ticket Details
extension TicketsNetworkManager {
    func getTicketDetails(for ticketID: String, successCallBack: @escaping (_ model: TicketDetailsModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.getTicketDetails(ticketID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<TicketDetailsModel>.self, from: resData)

                if let resCode = model.resCode, let respModel = model.response {
                    if resCode == 0 {
                        successCallBack(respModel)

                        return
                    }
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

// MARK: - Add Comments
extension TicketsNetworkManager {
    func addComment(_ comment: String, for ticketID: String, and statusID: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping () -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.addComment(comment, ticketID, statusID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { _ in successCallBack() }, failureCallBack: { _ in failureCallBack() })
    }
}

// MARK: - Change Status
extension TicketsNetworkManager {
    func changeStatus(with note: String, _ ticketID: String, _ status: String, and statusID: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.changeStatus(note, ticketID, status, statusID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { _ in successCallBack() }, failureCallBack: { errorStr in failureCallBack(errorStr) })
    }
}

// MARK: - Add ScreenShots
extension TicketsNetworkManager {
    func addScreenShots(_ images: String, _ fileType: String, for ticketID: String, and statusID: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping () -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.addScreenShot(images, fileType, ticketID, statusID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { _ in successCallBack() }, failureCallBack: { _ in failureCallBack() })
    }
}

// MARK: - Create Ticket
extension TicketsNetworkManager {
    func createTicket(for userID: String, _ parentTicketID: String, with subjectID: String, _ notes: String, _ images: String, _ fileType: String, and propertyID: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.createTicket(userID, parentTicketID, subjectID, images, fileType, notes, propertyID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let respCode = jsonDictionary["resCode"] as? Int else { return }

                respCode == 0 ? successCallBack() : failureCallBack(jsonDictionary["resStr"] as? String)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in failureCallBack(errorStr) })
    }
}

// MARK: - Create Violation
extension TicketsNetworkManager {
    func createViolation(for userID: String, with message: String, and ticketID: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.createViolation(userID, ticketID, message))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: resData, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let respCode = jsonDictionary["resCode"] as? Int else { return }

                respCode == 0 ? successCallBack() : failureCallBack(jsonDictionary["resStr"] as? String)
            } catch _ {
                failureCallBack("Invalid JSON.")
            }
        }, failureCallBack: { errorStr in failureCallBack(errorStr) })
    }
}

// MARK: - S3 Upload
extension TicketsNetworkManager {
    func uploadToS3(imageData: Data, for ext: String, successCallBack: @escaping (_ urlStr: String) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let imageName = ext == "pdf" ? "file\(self.generateRandomNumber()).pdf" : "image\(self.generateRandomNumber()).jpg"
        let localPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageName)
        let keyOnS3 = "Tickets/\(imageName)"

        try? imageData.write(to: localPath, options: [.atomic])

        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "amakkn-bucket"
        uploadRequest?.acl = AWSS3ObjectCannedACL.publicRead
        uploadRequest?.key = keyOnS3
        uploadRequest?.contentType = ext == "pdf" ? "pdf" : "image/png"
        uploadRequest?.body = localPath

        AWSS3TransferManager.default().upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { task in
                if task.error != nil {
                    failureCallBack(task.error?.localizedDescription)
                } else {
                    if task.isCompleted {
                        let fileName = "https://s3-eu-central-1.amazonaws.com/amakkn-bucket/Tickets/\(imageName)"

                        successCallBack(fileName)
                    }
                }
                return "" as Any
            })

        uploadRequest?.uploadProgress = { (_, _, _) in }
    }
    
    private func generateRandomNumber() -> Int {
        let lower: Int = 1
        let upper: Int = 1000

        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}
