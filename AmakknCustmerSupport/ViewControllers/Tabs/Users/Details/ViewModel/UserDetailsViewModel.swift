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
    case changeUserType = "Change User Type"
}

// MARK: - Sections Enum
enum UserDetailsSection: Int {
    case profile = 0
    case account
    case company
    case properties
    case appUsages
    case changeUserType
}

// MARK: - UserDetails Delegate
protocol UserDetailsDelegate {
    func updateData()
}

class UserDetailsViewModel {
    private var userDataType: UserDetailsDataSource?
    private var userDataSource: [UserDetailsModel]?
    var userType: String?
    var userID: String?

    var delegate: UserDetailsDelegate?

    func updateDataSource(with userModel: UserStatsModel?) {
        guard let userModel = userModel else { getUserStats(); return }

        userDataType = UserDetailsDataSource(userModel)
        userType = userModel.userType

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
                         UserDetailsModel(with: UserDetailsType.appUsages.rawValue, for: userDataType?.appUsagesDetails?.userAppUsagesData),
                         UserDetailsModel(with: UserDetailsType.changeUserType.rawValue, for: nil)]
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
        guard let sectionType = UserDetailsSection(rawValue: section) else { return 0.0 }

        switch sectionType {
            case .profile: return 250.0
            default: return 45.0
        }
    }

    var subjectID: String {
        return "4" // Can be changed according to backend
    }

    func getCellCount(for section: Int) -> Int {
        guard let sectionType = UserDetailsSection(rawValue: section) else { return 0 }

        switch sectionType {
            case .profile: return 1
            case .changeUserType: return 0
            default:
                guard let details = userDataSource?[section] else { return 0 }

                return details.isExpanded ? (details.detailsData?.count ?? 0) : 0
        }
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

// MARK: - Call Action
extension UserDetailsViewModel {
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
extension UserDetailsViewModel {
    func getChatModel(for userID: String?, successCallBack: @escaping (_ chatModel: ChatInboxModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void)  {
        guard let  senderID = AppSession.manager.userID, let receiverID = userID else { return }

        AppNetworkManager.shared.initChat(for: senderID, receiverID, subjectID) { [weak self] channelID in
            guard let channelID = channelID else { return }

            successCallBack(self?.chatModel(for: channelID))
        } failureCallBack: { (errorStr) in
            failureCallBack(errorStr)
        }
    }

    private func chatModel(for channelID: String?) -> ChatInboxModel? {
        guard let userModel = userDataType?.profileDetails else { return nil }
        guard let  senderID = AppSession.manager.userID, let receiverID = userModel.userID,
              let senderName = AppSession.manager.userName, let receiverName = userModel.userName,
              let senderAvatar = AppSession.manager.userAvatar, let receiverAvatar = userModel.userAvatar else { return nil }

        let model = ChatInboxModel(senderID: senderID, receiverID: receiverID, channelID: channelID, propertyID: subjectID, chatID: senderID,
                                   senderName: senderName, receiverName: receiverName, senderAvatar: senderAvatar, receiverAvatar: receiverAvatar, isVerified: userModel.isVerified,
                                   category: nil, propertyType: nil, propertyTypeName: nil, listedFor: nil,
                                   unreadCount: nil, lastMessage: nil, time: nil,
                                   photos: nil, defaultPrice: nil, address: nil, senderUserType: nil, receiverUserType: nil)

        return model
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
