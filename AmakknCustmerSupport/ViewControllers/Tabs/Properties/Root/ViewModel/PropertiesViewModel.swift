//
//  PropertiesViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import Foundation
import UIKit

// MARK: - UsersFilterType Enum
enum PropertyFilterType: String {
    case order = "Order"
    case sequence = "Sequence"
    case searchOperator = "Search Operator"
    case status = "Status"
    case filters = "Filters"
}

// MARK: - PropertiesView Delegate
protocol PropertiesViewDelegate {
    func reloadView(_ isListEmpty: Bool)
    func show(_ errorStr: String?)
    func updateProperty(count: String?)
}

class PropertiesViewModel {
    private var filterOrder = "userId"
    private var filterSequence = "desc"
    private var filterOperator = "AND"
    private var status = "All"
    private var filters = ""

    private var page = 0
    private var pageSize = "50"
    private var totalSize: String?
    private var propertyList: [PropertyCardsModel]?

    var delegate: PropertiesViewDelegate?
    private var searchQuery: String?
    var apiCallIndex = 49

    var cellHeight: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 280.0 : 230.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width*0.7 : UIScreen.main.bounds.width - 20.0
        return width
    }

    var isFirstPage: Bool {
        return page == 1
    }

    var cellCount: Int {
        return propertyList?.count ?? 0
    }

    func getPropertyID(at index: Int) -> String? {
        return propertyList?[index].propertyID
    }

    var isMoreDataAvailable: Bool {
        guard let totalCount = Int(totalSize ?? "0"), let listCount = propertyList?.count else { return false }

        return totalCount > listCount
    }

    subscript (_ index: Int) -> PropertyCardsModel? {
        return ((propertyList?.isEmpty ?? true) ? nil : propertyList?[index])
    }

    func updateSearch(with data: String?) {
        searchQuery = data
    }

    func updateFilter(_ dataSource: [String: String]) {
        filterOrder = dataSource[PropertyFilterType.order.rawValue] ?? "userId"
        status = dataSource[PropertyFilterType.status.rawValue] ?? "All"
        filterOperator = dataSource[PropertyFilterType.searchOperator.rawValue]?.uppercased() ?? "AND"
        filters = dataSource[PropertyFilterType.filters.rawValue] ?? ""
        filterSequence = dataSource[PropertyFilterType.sequence.rawValue] == "ascendingOrder" ? "asc" : "desc"

        page = 0
    }

    func resetPage() {
        page = 0
        apiCallIndex = 49
    }

    func change(status: String?, for propertyID: String?, completion: @escaping(_ index: Int, _ isDeleted: Bool) -> Void) {
        guard let status = status, let propertyID = propertyID else { return }
        guard let index = propertyList?.firstIndex(where: { $0.propertyID == propertyID}) else { return }

        switch status {
        case "Publish": propertyList?[index].status = "1"; completion(index, false)
            case "Unpublish": propertyList?[index].status = "0"; completion(index, false)
            case "Sold out": propertyList?[index].status = "2"; completion(index, false)
            case "Delete": propertyList?.remove(at: index); completion(index, true)
            default: break
        }
    }
}

// MARK: - API Calls
extension PropertiesViewModel {
    func getProperties() {
        guard AppSession.manager.validSession else { return }

        if page == 0 { propertyList = [PropertyCardsModel]() }
        page += 1

        PropertyNetworkManager.shared.getProperties(for: "\(page)", pageSize, with: searchQuery ?? "") { [weak self] responseModel in
            self?.totalSize = responseModel?.totalCount

            if let chatList = responseModel?.properties {
                self?.propertyList?.append(contentsOf: chatList)
            }

            DispatchQueue.main.async {
                self?.delegate?.reloadView(self?.propertyList?.isEmpty ?? true)
                self?.delegate?.updateProperty(count: " \(self?.propertyList?.count ?? 0) of \(self?.totalSize ?? "")")
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.delegate?.show(errorStr)
            }
        }
    }
}
