//
//  ChangeTypeViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 03/10/21.
//

import Foundation
import UIKit

// MARK: - ChangeType Model
struct ChangeTypeModel {
    let title: String?
    let type: UserType?
}

class ChangeTypeViewModel {
    private var userID: String?
    private var userType = UserType.normal
    private let userTypes = [ChangeTypeModel(title: UserTypeStr.normal.rawValue, type: .normal),
                             ChangeTypeModel(title: UserTypeStr.owner.rawValue, type: .owner),
                             ChangeTypeModel(title: UserTypeStr.broker.rawValue, type: .broker),
                             ChangeTypeModel(title: UserTypeStr.company.rawValue, type: .company),
                             ChangeTypeModel(title: UserTypeStr.agent.rawValue, type: .agent),
                             ChangeTypeModel(title: UserTypeStr.admin.rawValue, type: .admin)]

    var cellCount: Int {
        return userTypes.count
    }

    var cellHeight: CGFloat {
        return 50.0
    }

    func update(data: (userID: String?, userType: String?)) {
        guard let type = data.userType else { return }

        userID = data.userID
        self.userType =  UserType(rawValue: type) ?? .normal
    }

    subscript (_ index: Int) -> (model: ChangeTypeModel?, userType: UserType) {
        return (userTypes[index], userType)
    }

    func updateUser(with type: UserType?) {
        userType = type ?? .normal
    }

    func getUserType() -> String {
        let typeStr = userTypes.filter( {$0.type == userType }).first?.title
        return typeStr ?? ""
    }
}

// MARK: - Change User Type API
extension ChangeTypeViewModel {
    func changeUserType(successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        guard let userID = userID else { return }

        UsersNetworkManager.shared.changeUserType(for: userID, userType.rawValue) {
            DispatchQueue.main.async {
                successCallBack()
            }
        } failureCallBack: { errorStr in
            DispatchQueue.main.async {
                failureCallBack(errorStr)
            }
        }
    }
}
