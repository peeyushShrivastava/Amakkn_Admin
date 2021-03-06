//
//  UsersFilterViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 19/10/20.
//

import Foundation
import UIKit

// MARK: - Sections Enum
enum UserFilterSection: Int {
    case order = 0
    case sequence
    case search
    case filters
}

class UsersFilterViewModel {
    private let orderFilterData = ["User Id", "Name", "Phone", "User Type", "Account Type",
                                   "Status", "Devices", "Platforms", "Email", "Last Added property",
                                   "Created Date", "IsFeatured", "Last Opened", "App Versions", "Language",
                                   "Company Name", "Agent Count", "Is Verfied Company", "Published Property Count", "Incomplete or Unpublished Count"]
    private let sequenceFilterData = ["Ascending Order", "Decending Order"]
    private let searchFilterData = ["And", "Or"]

    var filterData: [UserFilterModel]?

    init() {
        updateData()
    }

    private func updateData() {
        filterData = [UserFilterModel(with: UsersFilterType.filter1.rawValue, for: orderFilterData),
                      UserFilterModel(with: UsersFilterType.filter2.rawValue, for: orderFilterData),
                      UserFilterModel(with: UsersFilterType.filter3.rawValue, for: orderFilterData),
                      UserFilterModel(with: UsersFilterType.order.rawValue, for: orderFilterData, [orderFilterData.first ?? "": true]),
                      UserFilterModel(with: UsersFilterType.sequence.rawValue, for: sequenceFilterData, [sequenceFilterData.first ?? "": true]),
                      UserFilterModel(with: UsersFilterType.searchOperator.rawValue, for: searchFilterData, [searchFilterData.first ?? "": true])]
    }

    var sectionCount: Int {
        return filterData?.count ?? 0
    }

    var sectionCellCount: Int {
        return 1
    }

    var cellHeight: CGFloat {
        return 45.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width*0.7 : UIScreen.main.bounds.width
        return width
    }

    func getHeaderHeight(at section: Int) -> CGFloat {
        guard section <= 2 else { return 45.0 }
        guard let filterData = filterData?[section] else { return 45.0 }

        return filterData.selectedData?.count == 0 ? 45.0: 90.0
    }

    func getCellCount(for section: Int) -> Int {
        guard let filterData = filterData?[section] else { return 0 }

        return filterData.isExpanded ? (filterData.filterData?.count ?? 0) : 0
    }

    func getData(at section: Int) -> UserFilterModel? {
        return filterData?[section]
    }

    func isValueSelected(at indexPath: IndexPath) -> Bool {
        let filteredData = filterData?[indexPath.section]
        guard let filteredValue = filteredData?.filterData?[indexPath.row] else { return false }

        return ((filteredData?.selectedData?[filteredValue]) != nil)
    }

    func updateExpand(at section: Int) {
        let isExpanded = filterData?[section].isExpanded
        filterData?[section].isExpanded = !(isExpanded ?? true)
    }

    func updateData(at indexPath: IndexPath) {
        let filteredData = filterData?[indexPath.section]
        guard let filteredValue = filteredData?.filterData?[indexPath.row] else { return }

        filterData?[indexPath.section].selectedData = [filteredValue: true]
        filterData?[indexPath.section].selectedValues = nil
    }

    func resetFilter() {
        updateData()
    }

    var order: String? {
        guard let orderData = filterData?[0] else { return "" }

        return orderData.selectedData?.keys.first
    }

    func updateFilterData(_ text: String?, for data: String?, at index: Int) {
        guard let data = data else { return }

        filterData?[index].selectedValues = [data: text ?? ""]
    }

    func getSelectedValue(at indexPath: IndexPath) -> String? {
        let filteredData = filterData?[indexPath.section]
        guard let filteredValue = filteredData?.filterData?[indexPath.row] else { return nil }

        return filteredData?.selectedValues?[filteredValue]
    }

    func getFilteredDataSource() -> [String: String] {
        let dataSource = [UsersFilterType.filter1.rawValue: getFilterValues(at: 0),
                          UsersFilterType.filter2.rawValue: getFilterValues(at: 1),
                          UsersFilterType.filter3.rawValue: getFilterValues(at: 2),
                          UsersFilterType.order.rawValue: getFilterData(at: 3),
                          UsersFilterType.sequence.rawValue: getFilterData(at: 4),
                          UsersFilterType.searchOperator.rawValue: getFilterData(at: 5)]

        return dataSource
    }

    private func getFilterData(at index: Int) -> String {
        return filterData?[index].selectedData?.keys.first?.trimWhitespaces.firstLowerCased ?? ""
    }

    private func getFilterValues(at index: Int) -> String {
        guard let selectedValues = filterData?[index].selectedValues else { return "" }

        var dataSource = ""
        for item in selectedValues {
            dataSource += "\(item.key.trimWhitespaces.firstLowerCased):\(item.value.trimmingCharacters(in: .whitespaces)),"
        }

        return String(dataSource.dropLast())
    }
}
