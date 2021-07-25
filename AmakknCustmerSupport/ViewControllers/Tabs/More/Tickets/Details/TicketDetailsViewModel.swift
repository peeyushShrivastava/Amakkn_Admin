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
    private var status: String?
    private var ticketDetails: [TicketDetails]?
    var statusList: [StatusModel]?
    var statusChanged = false

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

    func updateTicket(_ ticketID: String?) {
        self.ticketID = ticketID
    }

    func updateTicketStatus(_ status: String?) {
        self.status = status
    }

    func getDetails() -> [TicketDetails]? {
        return ticketDetails
    }

    func isLast(index: Int) -> Bool {
        return ticketDetails?.count == (index+1)
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

        TicketsNetworkManager.shared.getTicketDetails(for: ticketID) { ticketDetails in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.ticketDetails = ticketDetails

                self?.delegate?.success()
            }
        } failureCallBack: { errorStr in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }
    }

    func addComment(_ text: String?, for status: String?) {
        guard let comment = text, let status = status, let ticketID = ticketID else { return }

        AppLoader.show()

        TicketsNetworkManager.shared.addComment(comment, for: ticketID, and: status, successCallBack: {
            DispatchQueue.main.async { [weak self] in
                self?.getTicketDetails()
            }
        }, failureCallBack: {
            DispatchQueue.main.async {
                AppLoader.dismiss()
            }
        })
    }
 
    func uploadToS3(imageData: Data) {
        TicketsNetworkManager.shared.uploadToS3(imageData: imageData) { urlStr in
            DispatchQueue.main.async { [weak self] in
                self?.addScreenShot(with: urlStr)
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }
    }

    private func addScreenShot(with imageURLStr: String) {
        guard let status = status, let ticketID = ticketID else { return }

        TicketsNetworkManager.shared.addScreenShots(imageURLStr, for: ticketID, and: status, successCallBack: {
            DispatchQueue.main.async { [weak self] in
                self?.getTicketDetails()
            }
        }, failureCallBack: {
            DispatchQueue.main.async {
                AppLoader.dismiss()
            }
        })
    }

    func changeStatus(for statusID: String?, status: String?) {
        guard let statusID = statusID, let ticketID = ticketID else { return }

        statusChanged = true
        AppLoader.show()

        TicketsNetworkManager.shared.changeStatus(with: "", ticketID, and: statusID) {
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.delegate?.success()
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }
    }
}
