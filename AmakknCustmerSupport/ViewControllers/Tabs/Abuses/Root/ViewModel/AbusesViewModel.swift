//
//  AbusesViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/12/20.
//

import Foundation
import UIKit

// MARK: - AbusesView Delegate
protocol AbusesViewDelegate {
    func reloadView(_ isListEmpty: Bool)
    func showError(_ errorStr: String?)
}

class AbusesViewModel {
    private var page = 0
    private var pageSize = "15"
    private var totalSize: String?
    private var abusesList: [PropertyCardsModel]?

    private let sortOrders = ["Newest", "Oldest"]
    var selectedOrder = "Newest"

    var delegate: AbusesViewDelegate?
    var apiCallIndex = 14

    var cellCount: Int {
        return abusesList?.count ?? 0
    }

    var cellHeight: CGFloat {
        return 100.0
    }

    var isFirstPage: Bool {
        return page == 1
    }

    var isMoreDataAvailable: Bool {
        guard let totalCount = Int(totalSize ?? "0"), let listCount = abusesList?.count else { return false }

        return totalCount > listCount
    }

    subscript (_ index: Int) -> PropertyCardsModel? {
        return ((abusesList?.isEmpty ?? true) ? nil : abusesList?[index])
    }

    func getSortOrders() -> [String]? {
        return sortOrders
    }

    func resetPage() {
        page = 0
        apiCallIndex = 14
    }

    func updateComplaint(for propertyID: String?) {
        guard let propertyID = propertyID, let index = abusesList?.firstIndex(where: { $0.propertyID == propertyID}) else { return }
        guard let cCount = abusesList?[index].complaintCount, cCount != "1" else { deleteCell(at: index); return }
        guard let count = Int(cCount) else { return }

        abusesList?[index].complaintCount = "\(count-1)"

        delegate?.reloadView(abusesList?.isEmpty ?? true)
    }

    func updateAllComplaints(for propertyID: String?) {
        guard let propertyID = propertyID, let index = abusesList?.firstIndex(where: { $0.propertyID == propertyID}) else { return }

        deleteCell(at: index)
    }

    private func deleteCell(at index: Int) {
        abusesList?.remove(at: index)

        delegate?.reloadView(abusesList?.isEmpty ?? true)
    }
}

// MARK: - API Calls
extension AbusesViewModel {
    func getAbuses() {
        guard AppSession.manager.validSession else { return }

        if page == 0 { abusesList = [PropertyCardsModel]() }
        page += 1

        let sortOrder = selectedOrder == "Newest" ? "desc" : "asc"

        AbusesNetworkManager.shared.getAbuses(for: "\(page)", with: pageSize, sortOrder) { [weak self] responseModel in
            self?.totalSize = responseModel?.totalCount ?? "0"

            if let chatList = responseModel?.properties {
                self?.abusesList?.append(contentsOf: chatList)
            }

            self?.delegate?.reloadView(self?.abusesList?.isEmpty ?? true)
        } failureCallBack: { [weak self] errorStr in
            self?.delegate?.showError(errorStr)
        }
    }
}
