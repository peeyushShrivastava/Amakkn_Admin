//
//  AbusesViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/12/20.
//

import Foundation
import UIKit

class AbusesViewModel {
    private var page = 0
    private var pageSize = "15"
    private var totalSize: String?
    private var abusesList: [PropertyCardsModel]?

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

    func resetPage() {
        page = 0
    }
}

// MARK: - API Calls
extension AbusesViewModel {
    func getAbuses(successCallBack: @escaping(_ isListEmpty: Bool) -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        guard AppSession.manager.validSession else { return }

        if page == 0 { abusesList = [PropertyCardsModel]() }
        page += 1

        AbusesNetworkManager.shared.getAbuses(for: "\(page)", with: pageSize) { [weak self] responseModel in
            self?.totalSize = responseModel?.totalCount ?? "0"

            if let chatList = responseModel?.properties {
                self?.abusesList?.append(contentsOf: chatList)
            }

            successCallBack(self?.abusesList?.isEmpty ?? true)
        } failureCallBack: { errorStr in
            failureCallBack(errorStr)
        }
    }
}
