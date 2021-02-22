//
//  LoginViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 13/10/20.
//

import Foundation

// MARK: - Login Delegate
protocol LoginDelegate {
    func loginSuccess()
}

class LoginViewModel {
    func login(with countryCode: String, _ phone: String, and pwd: String, successCallBack: @escaping() -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        AppNetworkManager.shared.login(with: countryCode, phone, and: pwd) {
            AppNetworkManager.shared.updateToken()
            successCallBack()
        } failureCallBack: { errorStr in
            failureCallBack(errorStr)
        }
    }
}
