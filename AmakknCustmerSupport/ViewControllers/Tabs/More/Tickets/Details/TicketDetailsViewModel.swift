//
//  TicketDetailsViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import Foundation
import UIKit

class TicketDetailsViewModel {
    private var ticketID: String?
    private var userID: String?
    private var parentTicketID: String?
    private var statusID: String?
    private var ticketDetails: [TicketDetails]?
    var statusList: [StatusModel]?
    var isTicketClosed = false
    private var propertyInfoModel: PropertyInfo?
    private var userInfoModel: UserInfo?
    private var feedback: TFeedbackModel?

    var statusChanged = false
    var title = ""

    var delegate: TicketsListDelegate?

    /// Navigation Bar height = 65.0
    /// Top constraint = 35.0
    /// ibStatus1View height = 25.0
    var startPointY: CGFloat {
        return 125.0
    }

    /// ibLine1View Leading constraint = 40.0
    var startPointX: CGFloat {
        return 40.0
    }

    /// ibLine1View height = 79.0
    /// ibStatus1View height = 30.0
    var endPointY: CGFloat {
        return ((1.0 * (79.0 + 30.0)) + startPointY)
    }

    var propertyInfo: (imageURL: String?, type: String?, price: String?, address: String?, placeHolderStr: String)? {
        guard let type = propertyInfoModel?.type, let address = propertyInfoModel?.address else { return nil }

        let propertyInfo = (imageURL: propertyInfoModel?.imageURL, type: type, price: propertyInfoModel?.price, address: address, placeHolderStr: "\(propertyInfoModel?.placeHolderStr ?? "")")

        return propertyInfo
    }

    var propertyID: String? {
        return propertyInfoModel?.propertyID
    }

    private func updateLast() {
        let active = ticketDetails?.filter({$0.isActive != "0"})
        guard let last = active?.last else { return }

        isTicketClosed = last.status == "5" && last.isActive == "-1"
    }

    func updateTicket(_ ticketID: String?) {
        self.ticketID = ticketID
    }

    func updateUserID(_ userID: String?) {
        self.userID = userID
    }

    func updateStatusID(_ statusID: String?) {
        self.statusID = statusID
    }

    func updatePropertyInfo(_ propertyDetail: PropertyDetails?) {
        propertyInfoModel = PropertyInfo(imageURL: propertyDetail?.photos,
                                         type: propertyDetail?.propertyTypeName,
                                         price: propertyDetail?.defaultPrice,
                                         address: propertyDetail?.address,
                                         placeHolderStr: "PlaceHolder_\(propertyDetail?.category ?? "")_\(propertyDetail?.propertyType ?? "")",
                                         propertyID: propertyDetail?.propertyID,
                                         userID: propertyDetail?.userID,
                                         cCode: propertyDetail?.hostInfo?.countryCode,
                                         phone: propertyDetail?.hostInfo?.phone)
    }

    func updateFeedbackModel(_ feedback: TFeedbackModel?) {
        self.feedback = feedback
    }

    func updateParentTicketID(_ pTicketID: String?) {
        parentTicketID = pTicketID
    }

    func getDetails() -> [TicketDetails]? {
        return ticketDetails
    }

    func getUserID() -> String? {
        return userID
    }

    func getTicketID() -> String? {
        return ticketID
    }

    func getPropertyInfo() -> PropertyInfo? {
        return propertyInfoModel
    }

    func getUserInfo() -> UserInfo? {
        return userInfoModel
    }

    func getFeedback() -> TFeedbackModel? {
        return feedback
    }

    func getparentTicketID() -> String? {
        return parentTicketID
    }
}

// MARK: Get Ticket Details API
extension TicketDetailsViewModel {
    func getStatusList() {
        TicketsNetworkManager.shared.getStatusList { [weak self] statusModel in
            self?.statusList = statusModel?.statusList
        } failureCallBack: { _ in }
    }

    func getTicketDetails() {
        guard let ticketID = ticketID else { return }

        AppLoader.show()

        TicketsNetworkManager.shared.getTicketDetails(for: ticketID) { ticketDetailsModel in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.ticketDetails = ticketDetailsModel?.details
                self?.updatePropertyInfo(ticketDetailsModel?.property)
                self?.userInfoModel = ticketDetailsModel?.userInfo
                self?.updateLast()

                self?.delegate?.success()
            }
        } failureCallBack: { errorStr in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }
    }

    func addComment(_ text: String?, for statusID: String?) {
        guard let comment = text, let ticketID = ticketID, let statusID = statusID else { return }

        AppLoader.show()

        TicketsNetworkManager.shared.addComment(comment, for: ticketID, and: statusID, successCallBack: {
            DispatchQueue.main.async { [weak self] in
                self?.getTicketDetails()
            }
        }, failureCallBack: {
            DispatchQueue.main.async {
                AppLoader.dismiss()
            }
        })
    }
 
    func uploadToS3(imageData: Data, for ext: String) {
        TicketsNetworkManager.shared.uploadToS3(imageData: imageData, for: ext) { urlStr in
            DispatchQueue.main.async { [weak self] in
                self?.addScreenShot(with: urlStr, for: ext)
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }
    }

    private func addScreenShot(with imageURLStr: String, for ext: String) {
        guard let ticketID = ticketID, let statusID = statusID else { return }

        let fileType = ext == "pdf" ? "PDF" : "image"

        TicketsNetworkManager.shared.addScreenShots(imageURLStr, fileType, for: ticketID, and: statusID, successCallBack: {
            DispatchQueue.main.async { [weak self] in
                self?.getTicketDetails()
            }
        }, failureCallBack: {
            DispatchQueue.main.async {
                AppLoader.dismiss()
            }
        })
    }

    func changeStatus(for statusID: String?, status: String?, and fromStatusID: String?) {
        guard let statusID = statusID, let ticketID = ticketID, let fromStatusID = fromStatusID else { return }

        statusChanged = true
        AppLoader.show()

        TicketsNetworkManager.shared.changeStatus(with: "", ticketID, statusID, and: fromStatusID) {
            DispatchQueue.main.async { [weak self] in
                self?.getTicketDetails()
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }
    }
}
