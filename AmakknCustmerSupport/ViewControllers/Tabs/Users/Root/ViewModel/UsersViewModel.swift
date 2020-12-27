//
//  UsersViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import Foundation
import UIKit

// MARK: - UsersFilterType Enum
enum UsersFilterType: String {
    case order = "Order"
    case sequence = "Sequence"
    case searchOperator = "Search Operator"
    case filters = "Filters"
}

class UsersViewModel {
    private var page = 0
    private var pageSize = "15"
    private var totalSize: String?
    private var users: [SearchedUserModel]?

    private var filterOrder = "userId"
    private var filterSequence = "desc"
    private var filterOperator = "AND"
    private var filters = ""

    private var lastSearchedStr: String?
    private var latestSearchedStr: String?

    var apiCallIndex = 14

    var cellCount: Int {
        return users?.count ?? 0
    }

    var cellHeight: CGFloat {
        return 100.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - 30.0)/2 : UIScreen.main.bounds.width - 20.0
        return width
    }

    var isFirstPage: Bool {
        return page == 1
    }

    var subjectID: String {
        return "4" // Can be changed according to backend
    }

    var isMoreDataAvailable: Bool {
        guard let totalCount = Int(totalSize ?? "0"), let listCount = users?.count else { return false }

        return totalCount > listCount
    }

    subscript (_ index: Int) -> SearchedUserModel? {
        return users?[index]
    }

    func updateFilter(_ dataSource: [String: String]) {
        filterOrder = dataSource[UsersFilterType.order.rawValue] ?? "userId"
        filterOperator = dataSource[UsersFilterType.searchOperator.rawValue]?.uppercased() ?? "AND"
        filters = dataSource[UsersFilterType.filters.rawValue] ?? ""
        filterSequence = dataSource[UsersFilterType.sequence.rawValue] == "ascendingOrder" ? "asc" : "desc"

        page = 0
    }

    func resetPage() {
        page = 0
        users = nil
    }

    func updateLast(_ searchedStr: String?) {
        lastSearchedStr = searchedStr
    }

    func getLastSearchedStr() -> String? {
        return lastSearchedStr
    }

    func updateLatest(_ searchedStr: String?) {
        latestSearchedStr = searchedStr
    }
}

// MARK: - API Calls
extension UsersViewModel {
    func getSearchedUserList(_ searchQuery: String?, successCallBack: @escaping(_ isListEmpty: Bool) -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        guard AppSession.manager.validSession, let searchQuery = searchQuery else { return }

        if page == 0 { users = [SearchedUserModel]() }
        page += 1

        UsersNetworkManager.shared.getSearchedUsers(for: "\(page)", with: pageSize, searchQuery) { [weak self] responseModel in
            self?.totalSize = responseModel?.totalCount

            if let userList = responseModel?.users {
                self?.users?.append(contentsOf: userList)
            }

            successCallBack(self?.users?.isEmpty ?? true)
        } failureCallBack: { errorStr in
            failureCallBack(errorStr)
        }
    }
}

// MARK: - Call Action
extension UsersViewModel {
    func call(with phone: String?, _ countryCode: String?, callBack: @escaping(_ errorStr: String?) -> Void) {
        guard let phone = phone, let countryCode = countryCode else { return }

        if AppGeneral.shared.isSimAvialbale() || AppGeneral.shared.isESimAvialable() {
            AppGeneral.shared.callingAction(phoneNumber: "\(countryCode)\(phone)")
        } else {
            callBack("Sim is not avialbale")
        }
    }
}

// MARK: - Chat
extension UsersViewModel {
    func getChatModel(at index: Int, successCallBack: @escaping (_ chatModel: ChatInboxModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void)  {
        guard let userModel = users?[index] else { return }
        guard let  senderID = AppSession.manager.userID, let receiverID = userModel.userID else { return }

        AppNetworkManager.shared.initChat(for: senderID, receiverID, subjectID) { [weak self] channelID in
            guard let channelID = channelID else { return }

            successCallBack(self?.chatModel(for: channelID, userModel))
        } failureCallBack: { (errorStr) in
            failureCallBack(errorStr)
        }
    }

    private func chatModel(for channelID: String?, _ userModel: SearchedUserModel) -> ChatInboxModel? {
        guard let  senderID = AppSession.manager.userID, let receiverID = userModel.userID,
              let senderName = AppSession.manager.userName, let receiverName = userModel.userName,
              let senderAvatar = AppSession.manager.userAvatar,let receiverAvatar = userModel.userAvatar else { return nil }

        let model = ChatInboxModel(senderID: senderID, receiverID: receiverID, channelID: channelID, propertyID: subjectID, chatID: senderID,
                                   senderName: senderName, receiverName: receiverName, senderAvatar: senderAvatar, receiverAvatar: receiverAvatar, isVerified: userModel.isVerified,
                                   category: nil, propertyType: nil, propertyTypeName: nil, listedFor: nil,
                                   unreadCount: nil, lastMessage: nil, time: nil,
                                   photos: nil, defaultPrice: nil, address: nil, senderUserType: nil, receiverUserType: nil)

        return model
    }
}
