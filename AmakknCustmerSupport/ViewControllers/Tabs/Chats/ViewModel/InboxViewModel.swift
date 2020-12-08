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
    private var filteredSupportChats: [ChatInboxModel]?
    private var supportChats: [ChatInboxModel]?
    private var subjects: [ChatSubjectModel]?

    var apiCallIndex = 14

    var cellHeight: CGFloat {
        return 115.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width*0.7 : UIScreen.main.bounds.width - 20.0
        return width
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

    subscript (_ index: Int) -> ChatInboxModel? {
        return filteredSupportChats?[index]
    }

    func filterData(with subjectID: String?, callBack: @escaping () -> Void) {
        filteredSupportChats = supportChats?.filter { $0.subjectID == subjectID }

        callBack()
    }
}

// MARK: - API Calls
extension InboxViewModel {
    func getSupportChatList(successCallBack: @escaping(_ isListEmpty: Bool) -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        if page == 0 { supportChats = [ChatInboxModel]() }
        page += 1

        AppNetworkManager.shared.getSupportChats(for: "\(page)", with: pageSize) { [weak self] responseModel in
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
        }, failureCallBack: { _ in })
    }
}
