//
//  AppGeneral.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/12/20.
//

import UIKit
import Foundation
import CoreTelephony

// MARK: - Property Type
enum PropertyType: String {
    case residentialLand = "1"
    case residentialBuilding = "2"
    case apartment = "3"
    case villa = "4"
    case commercialLand = "5"
    case commercialBuilding = "6"
    case warehouse = "7"
    case showroom = "8"
    case office = "9"
}

// MARK: - Property Type
enum PropertyCategory: String {
    case sale = "1"
    case rent = "2"
}

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
