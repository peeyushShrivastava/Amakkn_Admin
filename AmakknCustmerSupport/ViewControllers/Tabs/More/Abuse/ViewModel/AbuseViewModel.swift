//
//  AbuseViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 16/12/20.
//

import Foundation
import UIKit

class AbuseViewModel {
    private var abuseList: [AbuseModel]?

    var cellHeight: CGFloat {
        return 105.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width*0.7 : UIScreen.main.bounds.width - 20.0
        return width
    }

    var cellCount: Int {
        return abuseList?.count ?? 0
    }

    func getPropertyID(at index: Int) -> String? {
        return abuseList?[index].propertyID
    }

    subscript (_ index: Int) -> AbuseModel? {
        return abuseList?[index]
    }
}

// MARK: - API Calls
extension AbuseViewModel {
    func getAbuseList(successCallBack: @escaping(_ isListEmpty: Bool) -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        guard AppSession.manager.validSession else { return }

        AppNetworkManager.shared.getAbuseList(successCallBack: { [weak self] responseModel in
            DispatchQueue.main.async {
                self?.abuseList = responseModel

                successCallBack(self?.abuseList?.isEmpty ?? true)
            }
        }, failureCallBack: { errorStr in
            DispatchQueue.main.async {
                failureCallBack(errorStr)
            }
        })
    }
}
