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
    private var pageSize = "15"
    private var totalSize: String?
    private var filteredSupportChats: [CSInboxModel]?
    private var supportChats: [CSInboxModel]?
    private var subjects: [ChatSubjectModel]?

    var apiCallIndex = 14
    var subjectID = ""

    var cellHeight: CGFloat {
        return 100.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width*0.7 : UIScreen.main.bounds.width - 20.0
        return width
    }

    var isFirstPage: Bool {
        return page == 1
    }

    var cellCount: Int {
        return 1
    }

    var sectionCount: Int {
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
        apiCallIndex = 14
    }

    func resetUnreadCount(at index: Int) {
        supportChats?[index].unreadCount = "0"
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
}
