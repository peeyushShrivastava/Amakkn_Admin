//
//  MoreViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 19/10/20.
//

import Foundation

class MoreViewModel {
    private let section1Data = ["Feedback".localized(), "Chat", "Users Filter", "Properties Filter", "Violations"]
    private var section2Data = AppSession.manager.validSession ? ["Logout".localized()] : ["Login".localized()]

    var sectionCount: Int {
        return 2
    }

    func getCellCount(for section: Int) -> Int {
        switch section {
        case 0:
            return AppSession.manager.validSession ? section1Data.count : 0
        default:
            return section2Data.count
        }
    }

    func getText(at indexpath: IndexPath) -> String {
        switch indexpath.section {
        case 0:
            return section1Data[indexpath.row]
        default:
            return section2Data[indexpath.row]
        }
    }

    func updateData() {
        section2Data = AppSession.manager.validSession ? ["Logout".localized()] : ["Login".localized()]
    }

    func updateBadgeCount(callback: @escaping () -> Void) {
        AppNetworkManager.shared.getBadge {
            DispatchQueue.main.async {
                callback()
            }
        }
    }
}

// MARK: - Logout API Call
extension MoreViewModel {
    func logout(successCallBack: @escaping() -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        AppNetworkManager.shared.logout {
            successCallBack()
        } failureCallBack: { erorStr in
            failureCallBack(erorStr)
        }

    }
}
