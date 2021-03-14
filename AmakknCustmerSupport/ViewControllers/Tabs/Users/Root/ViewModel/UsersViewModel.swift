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
    case status = "Status"
    case filter1 = "Filter 1"
    case filter2 = "Filter 2"
    case filter3 = "Filter 3"
}

// MARK: - UsersView Delegate
protocol UsersViewDelegate {
    func reloadView(_ isListEmpty: Bool)
    func show(_ errorStr: String?)
    func updateProperty(count: String?)
}

class UsersViewModel {
    private var page = 0
    private var pageSize = "50"
    private var totalSize: String?
    private var users: [SearchedUserModel]?

    private var filterOrder = "userId"
    private var filterSequence = "desc"
    private var filterOperator = "AND"
    private var filters = ""
    var isFilterCalled = false

    var delegate: UsersViewDelegate?
    var searchQuery: String?
    var apiCallIndex = 49

    var cellCount: Int {
        return users?.count ?? 0
    }

    var cellHeight: CGFloat {
        return 135.0
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
        guard users?.count ?? 0 > 0 else { return nil }

        return users?[index]
    }

    func updateFilter(_ dataSource: [String: String]) {
        isFilterCalled = true
        filterOrder = dataSource[UsersFilterType.order.rawValue] ?? "userId"
        filterOperator = dataSource[UsersFilterType.searchOperator.rawValue]?.uppercased() ?? "AND"
        filterSequence = dataSource[UsersFilterType.sequence.rawValue] == "ascendingOrder" ? "asc" : "desc"

        filters = "\(dataSource[UsersFilterType.filter1.rawValue] ?? ""),\(dataSource[UsersFilterType.filter2.rawValue] ?? ""),\(dataSource[UsersFilterType.filter3.rawValue] ?? "")"

        filters = filters.components(separatedBy: ",").filter({ $0 != ""}).joined(separator: ",")

        page = 0
        searchQuery = ""
    }

    func resetPage() {
        page = 0
        apiCallIndex = 49
    }

    func updateSearch(with data: String?) {
        searchQuery = data
    }
}

// MARK: - API Calls
extension UsersViewModel {
    func getSearchedUserList() {
        guard AppSession.manager.validSession else { return }

        if page == 0 { users = [SearchedUserModel]() }
        page += 1

        isFilterCalled ? getFilteredUsers() : getSearchedUsers()
    }

    private func getSearchedUsers() {
        UsersNetworkManager.shared.getSearchedUsers(for: "\(page)", with: pageSize, searchQuery ?? "") { [weak self] responseModel in
            self?.totalSize = responseModel?.totalCount

            if let userList = responseModel?.users {
                self?.users?.append(contentsOf: userList)
            }

            DispatchQueue.main.async {
                self?.delegate?.reloadView(self?.users?.isEmpty ?? true)
                self?.delegate?.updateProperty(count: " \(self?.users?.count ?? 0) of \(self?.totalSize ?? "")")
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.delegate?.show(errorStr)
            }
        }
    }

    private func getFilteredUsers() {
        UsersNetworkManager.shared.getUsers(for: "\(page)", with: pageSize, filterOrder, filterSequence, filters, filterOperator) { [weak self] responseModel in
            self?.totalSize = String(responseModel?.totalCount ?? 0)

            if let userList = responseModel?.userArray {
                self?.users?.append(contentsOf: userList)
            }

            DispatchQueue.main.async {
                self?.delegate?.reloadView(self?.users?.isEmpty ?? true)
                self?.delegate?.updateProperty(count: " \(self?.users?.count ?? 0) of \(self?.totalSize ?? "")")
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.delegate?.show(errorStr)
            }
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
