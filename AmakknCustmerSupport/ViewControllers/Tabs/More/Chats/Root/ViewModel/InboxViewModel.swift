//
//  InboxViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import Foundation
import UIKit

class InboxViewModel {
    private var page = 0
    private var pageSize = "50"
    private var totalSize: String?
    private var filteredSupportChats: [CSInboxModel]?
    private var supportChats: [CSInboxModel]?
    private var subjects: [ChatSubjectModel]?

    var apiCallIndex = 49
    var subjectID = ""

    var cellHeight: CGFloat {
        return 115.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width*0.7 : UIScreen.main.bounds.width
        return width
    }

    var isFirstPage: Bool {
        return page == 1
    }

    var cellCount: Int {
        return supportChats?.count ?? 0
    }

    var isMoreDataAvailable: Bool {
        guard let totalCount = Int(totalSize ?? "0"), let listCount = supportChats?.count else { return false }

        return totalCount > listCount
    }

    var chatSubjects: [ChatSubjectModel]? {
        return subjects
    }

    subscript (_ index: Int) -> CSInboxModel? {
        return filteredSupportChats?[index]
    }

    func deleteObject(at index: Int) {
        supportChats?.remove(at: index)
    }

    func resetPage() {
        page = 0
        apiCallIndex = 49
    }

    func resetUnreadCount(at index: Int) {
        supportChats?[index].unreadCount = "0"

        guard let badgeCount = Int(AppUserDefaults.manager.chatBadgeCount ?? "1") else { return }
        Utility.shared.updateChat(badgeCount: "\(badgeCount-1)")
    }

    func getChatID(at index: Int) -> String? {
        return supportChats?[index].chatID
    }
}

// MARK: - API Calls
extension InboxViewModel {
    func getSupportChatList(successCallBack: @escaping(_ isListEmpty: Bool) -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        guard AppSession.manager.validSession else { return }

        if page == 0 { supportChats = [CSInboxModel]() }
        page += 1

        AppNetworkManager.shared.getSupportChats(for: "\(page)", with: pageSize, subjectID) { [weak self] responseModel in
            self?.totalSize = responseModel?.totalCount

            if let chatList = responseModel?.chatArray {
                self?.supportChats?.append(contentsOf: chatList)
                self?.filteredSupportChats = self?.supportChats
            }

            successCallBack(self?.supportChats?.isEmpty ?? true)
        } failureCallBack: { errorStr in
            failureCallBack(errorStr)
        }
    }

    func getSubjects() {
        AppNetworkManager.shared.getSubjects(successCallBack: { [weak self] responseModel in
            self?.subjects = responseModel

            let newSubject = ChatSubjectModel(subjectID: "", adminID: "1", subject: "All")
            self?.subjects?.insert(newSubject, at: 0)
        }, failureCallBack: { _ in })
    }

    func closeChatThread(_ chatID: String?, completion: @escaping() -> Void) {
        guard let chatID = chatID else { return }

        AppNetworkManager.shared.closeChatThead(chatID)

        completion()
    }
}
