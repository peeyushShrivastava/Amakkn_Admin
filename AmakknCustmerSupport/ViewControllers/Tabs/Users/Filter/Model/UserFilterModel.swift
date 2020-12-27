//
//  UserFilterModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 19/10/20.
//

import Foundation

struct UserFilterModel {
    var isExpanded = false
    var filterTitle: String?
    let filterData: [String]?
    var selectedValues: [String: String]?
    var selectedData: [String: Bool]?

    init(with filterTitle: String?, for filterData: [String]?, _ selectedData: [String: Bool] = [String: Bool](), _ selectedValues: [String: String] = [String: String]()) {
        self.filterTitle = filterTitle
        self.filterData = filterData
        self.selectedValues = selectedValues
        self.selectedData = selectedData
    }
}
