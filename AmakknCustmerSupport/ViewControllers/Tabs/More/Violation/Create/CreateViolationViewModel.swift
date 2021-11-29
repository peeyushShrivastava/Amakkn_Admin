//
//  CreateViolationViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 01/08/21.
//

import Foundation

class CreateViolationViewModel {
    private var selectedUser: SearchedUserModel?
    private var userInfoModel: UserInfo?
    private var ticketID: String?

    var isViolationCreated = false

    var delegate: TicketsListDelegate?

    var userID: String? {
        return userInfoModel?.userID
    }

    var userData: String? {
        return "\(userInfoModel?.cCode ?? "")-\(userInfoModel?.userPhone ?? "") (UserId: \(userInfoModel?.userID ?? ""))"
    }

    func update(_ user: SearchedUserModel?) {
        selectedUser = user

        userInfoModel?.userID = user?.userID
        userInfoModel?.userName = user?.userName
        userInfoModel?.cCode = user?.countryCode
        userInfoModel?.userPhone = user?.userPhone
    }

    func updateTicketID(_ ticketID: String?) {
        self.ticketID = ticketID
    }

    func updateUserInfo(_ userInfo: UserInfo?) {
        userInfoModel = userInfo
    }
}

// MARK: - API Call
extension CreateViolationViewModel {
    func createViolation(with message: String?) {
        guard let ticketID = ticketID, let userID = userID, let message = message else { return }

        AppLoader.show()

        TicketsNetworkManager.shared.createViolation(for: userID, with: message, and: ticketID) { [weak self] in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.isViolationCreated = true
                self?.delegate?.success()
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }

    }
}
