//
//  FeedbackViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 31/12/20.
//

import Foundation
import UIKit

class FeedbackViewModel {
    private var page = 0
    private var pageSize = "50"
    private var totalSize: String?
    private var feedbackList: [FeedbackModel]?

    var apiCallIndex = 49

    var cellHeight: CGFloat {
        return 101.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width*0.7 : UIScreen.main.bounds.width - 20.0
        return width
    }

    var cellCount: Int {
        return feedbackList?.count ?? 0
    }

    var isFirstPage: Bool {
        return page == 1
    }

    var isMoreDataAvailable: Bool {
        guard let totalCount = Int(totalSize ?? "0"), let listCount = feedbackList?.count else { return false }

        return totalCount > listCount
    }

    subscript (_ index: Int) -> FeedbackModel? {
        return feedbackList?[index]
    }
}

// MARK: - API Calls
extension FeedbackViewModel {
    func getFeedbackList(successCallBack: @escaping(_ isListEmpty: Bool) -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        guard AppSession.manager.validSession else { return }

        if page == 0 { feedbackList = [FeedbackModel]() }
        page += 1

        MoreNetworkManager.shared.getFeedbackList(for: "\(page)", pageSize: pageSize, successCallBack: { [weak self] responseModel in
            DispatchQueue.main.async {
                self?.totalSize = responseModel?.totalCount

                if let feedbackList = responseModel?.feedbackArray {
                    self?.feedbackList?.append(contentsOf: feedbackList)
                }

                successCallBack(self?.feedbackList?.isEmpty ?? true)
            }
        }, failureCallBack: { errorStr in
            DispatchQueue.main.async {
                failureCallBack(errorStr)
            }
        })
    }
}
