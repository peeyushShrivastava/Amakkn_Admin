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
    case getTickets
    case getSubjects
    case getStatusList
    case getTicketDetails(_ ticketID: String)
    case addComment(_ text: String, _ ticketID: String, _ status: String)
    case changeStatus(_ note: String, _ ticketID: String, _ status: String)
    case addScreenShot(_ images: String, _ ticketID: String, _ status: String)
    case createTicket(_ userID: String, _ title: String, _ images: String, _ notes: String, _ propertyID: String)
    case none
}

// MARK: - API URL
extension TicketsNetworkManager {
    internal var urlString: String {
        switch endPoint {
            case .getTickets: return "Feedback/getMyTickets/"
            case .getSubjects: return "Feedback/getTicketListSubjects/"
            case .getStatusList: return "Feedback/getTicketStatusList/"
            case .getTicketDetails(_): return "Feedback/getTicketDetails/"
            case .addComment(_, _, _): return "Feedback/addCommentToATicket/"
            case .changeStatus(_, _, _): return "Feedback/changeStatusOfATicket/"
            case .addScreenShot(_, _, _): return "Feedback/addScreenshotsToATicket/"
            case .createTicket(_, _, _, _, _): return "Feedback/createATicket/"
            case .none: return ""
        }
    }
}

// MARK: - API Parameters
extension TicketsNetworkManager {
    internal var params: [String: Any]? {
        switch endPoint {
            case .getTickets: return ["userId": hashedUserID, "language": selectedLanguage]
            case .getSubjects: return ["language": selectedLanguage]
            case .getStatusList: return ["language": selectedLanguage]
            case .getTicketDetails(let ticketID): return ["ticketId": ticketID, "userId": hashedUserID, "language": selectedLanguage]
            case .addComment(let comment, let ticketID, let status): return ["ticketId": ticketID, "userId": hashedUserID, "language": selectedLanguage, "text": comment, "status": status]
            case .changeStatus(let note, let ticketID, let status): return ["ticketId": ticketID, "userId": hashedUserID, "language": selectedLanguage, "notes": note, "status": status]
            case .addScreenShot(let images, let ticketID, let status): return ["ticketId": ticketID, "userId": hashedUserID, "language": selectedLanguage, "images": images, "status": status]
            case .createTicket(let userID, let title, let images, let notes, let propertyID): return ["title": title, "userId": userID, "createdBy": hashedUserID, "language": selectedLanguage, "screenshots": images, "notes": notes, "propertyId": propertyID]
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
    func getTickets(successCallBack: @escaping (_ model: TicketListModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.getTickets)

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<TicketListModel>.self, from: resData)

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

// MARK: - Get Ticket Details
extension TicketsNetworkManager {
    func getTicketDetails(for ticketID: String, successCallBack: @escaping (_ model: [TicketDetails]?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.getTicketDetails(ticketID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { resData in
            guard let resData = resData else { return }

            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(ResponseModel<[TicketDetails]>.self, from: resData)

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
    func addComment(_ comment: String, for ticketID: String, and status: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping () -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.addComment(comment, ticketID, status))

        BaseNetworkManager.shared.fetch(request, successCallBack: { _ in successCallBack() }, failureCallBack: { _ in failureCallBack() })
    }
}

// MARK: - Change Status
extension TicketsNetworkManager {
    func changeStatus(with note: String, _ ticketID: String, and status: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.changeStatus(note, ticketID, status))

        BaseNetworkManager.shared.fetch(request, successCallBack: { _ in successCallBack() }, failureCallBack: { errorStr in failureCallBack(errorStr) })
    }
}

// MARK: - Add ScreenShots
extension TicketsNetworkManager {
    func addScreenShots(_ images: String, for ticketID: String, and status: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping () -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.addScreenShot(images, ticketID, status))

        BaseNetworkManager.shared.fetch(request, successCallBack: { _ in successCallBack() }, failureCallBack: { _ in failureCallBack() })
    }
}

// MARK: - Create Ticket
extension TicketsNetworkManager {
    func createTicket(for userID: String, with title: String, _ notes: String, _ images: String, and propertyID: String, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let request = getRequest(with: TicketsAPIEndPoint.createTicket(userID, title, images, notes, propertyID))

        BaseNetworkManager.shared.fetch(request, successCallBack: { _ in successCallBack() }, failureCallBack: { errorStr in failureCallBack(errorStr) })
    }
}

// MARK: - S3 Upload
extension TicketsNetworkManager {
    func uploadToS3(imageData: Data, successCallBack: @escaping (_ urlStr: String) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        let imageName = "image\(self.generateRandomNumber()).jpg"
        let localPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageName)
        let keyOnS3 = "Tickets/\(imageName)"

        try? imageData.write(to: localPath, options: [.atomic])

        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "amakkn-bucket"
        uploadRequest?.acl = AWSS3ObjectCannedACL.publicRead
        uploadRequest?.key = keyOnS3
        uploadRequest?.contentType = "image/png"
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
