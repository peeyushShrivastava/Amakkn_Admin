//
//  TicketsInboxViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import Foundation
import UIKit

// MARK: - TicketsList Delegate
protocol TicketsListDelegate {
    func success()
    func failed(with errorStr: String?)
}

class TicketsInboxViewModel {
    private var tickets: [TicketsModel]?
    private var violatingUserID: String?
    var statusList: [StatusModel]?
    var ticketStatus = "-5"
    
    var delegate: TicketsListDelegate?

    var cellCount: Int {
        return tickets?.count ?? 0
    }

    func getCellHeight(at index: Int) -> CGFloat {
        guard tickets?[index].children?.count ?? 0 > 0  else { return 90.0 }

        return 150.0
    }

    var vUserID: String? {
        return violatingUserID
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - 32.0)/2 : UIScreen.main.bounds.width - 32.0
        return width
    }

    subscript (_ index: Int) -> TicketsModel? {
        return tickets?[index]
    }

    func updateViolating(userID: String?) {
        violatingUserID = userID
    }
}

// MARK: Get Tickets API Call
extension TicketsInboxViewModel {
    func getStatusList() {
        TicketsNetworkManager.shared.getStatusList { [weak self] statusModel in
            self?.statusList = statusModel?.statusList
        } failureCallBack: { _ in }
    }

    func getTickets() {
        AppLoader.show()

        violatingUserID == nil ? ticketsList() : violationsList()
    }

    private func ticketsList() {
        TicketsNetworkManager.shared.getTickets(for: ticketStatus) { respModel in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.tickets = respModel?.tickets
                self?.delegate?.success()
            }
        } failureCallBack: { errorStr in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.tickets = nil
                self?.delegate?.failed(with: errorStr)
            }
        }
    }

    private func violationsList() {
        guard let violatingUserID = violatingUserID else { return }

        TicketsNetworkManager.shared.getViolations(for: violatingUserID) { respModel in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.tickets = respModel?.tickets
                self?.delegate?.success()
            }
        } failureCallBack: { errorStr in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }
    }
}
