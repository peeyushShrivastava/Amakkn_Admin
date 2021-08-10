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
    private var page = 0
    private var pageSize = "50"
    private var totalSize: String?
    private var tickets: [TicketsModel]?

    private var violatingUserID: String?
    var statusList: [StatusModel]?
    var ticketStatus = "-5"
    var searchQuery: String?
    var apiCallIndex = 49
    
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

    var isFirstPage: Bool {
        return page == 1
    }

    var isMoreDataAvailable: Bool {
        guard let totalCount = Int(totalSize ?? "0"), let listCount = tickets?.count else { return false }

        return totalCount > listCount
    }

    subscript (_ index: Int) -> TicketsModel? {
        guard tickets?.count ?? 0 > 0 else { return nil }

        return tickets?[index]
    }

    func updateViolating(userID: String?) {
        violatingUserID = userID
    }

    func resetPage() {
        page = 0
        apiCallIndex = 49
    }

    func updateSearch(with data: String?) {
        searchQuery = data
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

        if page == 0 { tickets = [TicketsModel]() }
        page += 1

        violatingUserID == nil ? ticketsList() : violationsList()
    }

    private func ticketsList() {
        TicketsNetworkManager.shared.getTickets(for: ticketStatus, with: searchQuery ?? "", at: "\(page)", pageSize) { [weak self] respModel in
            self?.totalSize = respModel?.totalCount

            if let userList = respModel?.tickets {
                self?.tickets?.append(contentsOf: userList)
            }

            DispatchQueue.main.async {
                AppLoader.dismiss()

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
