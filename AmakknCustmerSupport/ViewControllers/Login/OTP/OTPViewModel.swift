//
//  OTPViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 02/09/21.
//

import Foundation

class OTPViewModel {
    private var phone: String?
    private var countryCode: String?
    private var password: String?

    func updateData(_ data: (phone: String?, countryCode: String?, password: String?)) {
        phone = data.phone
        countryCode = data.countryCode
        password = data.password
    }
}

// MARK: - API Calls
extension OTPViewModel {
    func login(successCallBack: @escaping() -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        guard let countryCode = countryCode, let phone = phone, let pwd = password else { return }

        AppNetworkManager.shared.login(with: countryCode, phone, and: pwd) {
            successCallBack()
        } failureCallBack: { errorStr in
            failureCallBack(errorStr)
        }
    }

    func verify(OTP: String?, successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void) {
        guard let otpStr = OTP, let phone = phone, let cCode = countryCode else { return }

        AppLoader.show()

        AppNetworkManager.shared.verify(with: cCode, phone, and: otpStr) {
            AppUserDefaults.manager.forcedLogout = false
            Utility.shared.updateToken {
                AppNetworkManager.shared.updateToken {
                    DispatchQueue.main.async {
                        AppLoader.dismiss()

                        successCallBack()
                    }
                }
            }
        } failureCallBack: { errorStr in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                failureCallBack(errorStr)
            }
        }
    }
}
