//
//  AppGeneral.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/12/20.
//

import UIKit
import Foundation
import CoreTelephony

class AppGeneral {
    static let shared = AppGeneral()

    private init() { }
}

// MARK: - Call Methods
extension AppGeneral {
    func isSimAvialbale() -> Bool {
        guard let carrier = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value else { return false }
        guard let carrierCode = carrier.mobileNetworkCode else { return false }
        guard carrierCode != "" else { return false }

        return true
    }

    func isESimAvialable() -> Bool {
        let telephonyInfo = CTTelephonyNetworkInfo()

        if telephonyInfo.serviceCurrentRadioAccessTechnology == nil {
            if #available(iOS 12, *) {
                 if let radioTechnologies = telephonyInfo.serviceCurrentRadioAccessTechnology, !radioTechnologies.isEmpty {
                       return true
                 }
            }
        }

        return false
    }

    func callingAction(phoneNumber: String) {
        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
            let application = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(phoneCallURL)
                }
            }
        }
    }
}
