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
        AppLoader.show()
        AppNetworkManager.shared.login(with: countryCode, phone, and: pwd) {
            DispatchQueue.main.async {
                AppLoader.dismiss()
                successCallBack()
            }
        } failureCallBack: { errorStr in
            DispatchQueue.main.async {
                AppLoader.dismiss()
                failureCallBack(errorStr)
            }
        }
    }

    func loginOld(with countryCode: String, _ phone: String, and pwd: String, successCallBack: @escaping() -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        AppLoader.show()
        AppNetworkManager.shared.loginOld(with: countryCode, phone, and: pwd) {
            DispatchQueue.main.async {
                AppLoader.dismiss()
                successCallBack()
            }
        } failureCallBack: { errorStr in
            DispatchQueue.main.async {
                AppLoader.dismiss()
                failureCallBack(errorStr)
            }
        }
    }
}
