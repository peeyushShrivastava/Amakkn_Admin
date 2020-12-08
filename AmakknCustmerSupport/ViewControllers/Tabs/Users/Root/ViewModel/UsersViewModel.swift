//
//  UsersViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import Foundation
import UIKit

class UsersViewModel {
    private var page = 0
    private var pageSize = "15"
    private var totalSize: String?
    private var users: [UserStatsModel]?

    var apiCallIndex = 14

    var cellCount: Int {
        return users?.count ?? 0
    }

    var cellHeight: CGFloat {
        return 250.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - 30.0)/2 : UIScreen.main.bounds.width - 20.0
        return width
    }

    var isMoreDataAvailable: Bool {
        guard let totalCount = Int(totalSize ?? "0"), let listCount = users?.count else { return false }

        return totalCount > listCount
    }

    subscript (_ index: Int) -> UserStatsModel? {
        return users?[index]
    }
}

// MARK: - API Calls
extension UsersViewModel {
    func getUserStatsList(successCallBack: @escaping(_ isListEmpty: Bool) -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        if page == 0 { users = [UserStatsModel]() }
        page += 1

        AppNetworkManager.shared.getUsers(for: "\(page)", with: pageSize) { [weak self] responseModel in
            self?.totalSize = String(responseModel?.totalCount ?? 0)

            if let chatList = responseModel?.userArray {
                self?.users?.append(contentsOf: chatList)
            }

            successCallBack(self?.users?.isEmpty ?? true)
        } failureCallBack: { errorStr in
            failureCallBack(errorStr)
        }
    }
}
