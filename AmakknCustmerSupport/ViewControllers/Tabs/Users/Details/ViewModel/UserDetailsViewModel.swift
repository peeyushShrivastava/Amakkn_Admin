//
//  UserDetailsViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/10/20.
//

import Foundation
import UIKit

// MARK: - Sections Enum
enum UserDetailsType: String {
    case profile = "Profile Details"
    case account = "Account Details"
    case company = "Company Details"
    case properties = "Properties Details"
    case appUsages = "App Usages Details"
}

// MARK: - Sections Enum
enum UserDetailsSection: Int {
    case profile = 0
    case account
    case company
    case properties
    case appUsages
}

// MARK: - UserDetails Delegate
protocol UserDetailsDelegate {
    func updateData()
}

class UserDetailsViewModel {
    private var userDataType: UserDetailsDataSource?
    private var userDataSource: [UserDetailsModel]?
    var userID: String?

    var delegate: UserDetailsDelegate?

    func updateDataSource(with userModel: UserStatsModel?) {
        guard let userModel = userModel else { getUserStats(); return }

        userDataType = UserDetailsDataSource(userModel)

        updateData()
        updateCompanyDetails(with: userModel)
    }

    var userStatus: String? {
        return userDataSource?[1].detailsData?[3].value
    }

    private func updateData() {
        userDataSource = [UserDetailsModel(with: UserDetailsType.profile.rawValue, for: nil),
                         UserDetailsModel(with: UserDetailsType.account.rawValue, for: userDataType?.accountDetails?.userAccountData),
                         UserDetailsModel(with: UserDetailsType.properties.rawValue, for: userDataType?.profilePropertyDetails?.userPropertiesData),
                         UserDetailsModel(with: UserDetailsType.appUsages.rawValue, for: userDataType?.appUsagesDetails?.userAppUsagesData)]
    }

    private func updateCompanyDetails(with userModel: UserStatsModel?) {
        guard userModel?.userType == UserType.company.rawValue, userModel?.accountType == AccountType.corporate.rawValue else { return }

        let companyDetails = UserDetailsModel(with: UserDetailsType.company.rawValue, for: userDataType?.companyDetails?.userCompanysData)

        userDataSource?.insert(companyDetails, at: 2)
    }

    var sectionCount: Int {
        return userDataSource?.count ?? 0
    }

    var sectionCellCount: Int {
        return 1
    }

    var headerHeight: CGFloat {
        return 60.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width*0.7 : UIScreen.main.bounds.width-20.0
        return width
    }

    func getCellHeight(at section: Int) -> CGFloat {
        guard (userDataSource?[section].detailsData) != nil else { return 250.0 }

        return 45.0
    }

    func getCellCount(for section: Int) -> Int {
        guard (userDataSource?[section].detailsData) != nil else { return 1 }
        guard let details = userDataSource?[section] else { return 0 }

        return details.isExpanded ? (details.detailsData?.count ?? 0) : 0
    }

    func getData(at section: Int) -> UserDetailsModel? {
        return userDataSource?[section]
    }

    func updateExpand(at section: Int) {
        let isExpanded = userDataSource?[section].isExpanded
        userDataSource?[section].isExpanded = !(isExpanded ?? true)
    }

    func getProfileData() -> UserProfileDetails? {
        return userDataType?.profileDetails
    }

    func isLastCell(at indexPath: IndexPath) -> Bool {
        guard let dataCount = userDataSource?[indexPath.section].detailsData?.count else { return false }

        return (dataCount-1 == indexPath.row)
    }
}

// MARK: - API Calls
extension UserDetailsViewModel {
    func getUserStats() {
        guard AppSession.manager.validSession, let userID = userID else { return }

        UsersNetworkManager.shared.getUser(for: "1", with: "1", "userId", "asc", "userId:\(userID)", "AND") { [weak self] responseModel in
            if let chatList = responseModel?.userArray, responseModel?.totalCount != 0 {
                self?.updateDataSource(with: chatList.first)
            }

            self?.delegate?.updateData()
        } failureCallBack: { _ in }
    }

    func changeUser(_ status: String?, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        guard AppSession.manager.validSession, let userID = userID, let status = status else { return }

        UsersNetworkManager.shared.changeUserStatus(for: userID, status, successCallBack: {
            DispatchQueue.main.async {
                successCallBack()
            }
        }, failureCallBack: { errorStr in
            DispatchQueue.main.async {
                failureCallBack(errorStr)
            }
        })
    }
}
