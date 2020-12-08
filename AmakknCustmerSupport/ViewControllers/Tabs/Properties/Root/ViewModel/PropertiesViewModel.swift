//
//  PropertiesViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import Foundation
import UIKit

class PropertiesViewModel {
    private var page = 0
    private var pageSize = "15"
    private var totalSize: String?
    private var propertyList: [PropertyCardsModel]?

    var apiCallIndex = 14

    var cellHeight: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 250.0 : 200.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width*0.7 : UIScreen.main.bounds.width - 20.0
        return width
    }

    var cellCount: Int {
        return propertyList?.count ?? 0
    }

    func getPropertyID(at index: Int) -> String? {
        return propertyList?[index].propertyID
    }

    var isMoreDataAvailable: Bool {
        guard let totalCount = Int(totalSize ?? "0"), let listCount = propertyList?.count else { return false }

        return totalCount > listCount
    }

    subscript (_ index: Int) -> PropertyCardsModel? {
        return propertyList?[index]
    }
}

// MARK: - API Calls
extension PropertiesViewModel {
    func getProperties(successCallBack: @escaping(_ isListEmpty: Bool) -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        if page == 0 { propertyList = [PropertyCardsModel]() }
        page += 1

        AppNetworkManager.shared.getProperties(for: "\(page)", with: pageSize) { [weak self] responseModel in
            self?.totalSize = String(responseModel?.totalCount ?? 0)

            if let chatList = responseModel?.propertyArray {
                self?.propertyList?.append(contentsOf: chatList)
            }

            successCallBack(self?.propertyList?.isEmpty ?? true)
        } failureCallBack: { errorStr in
            failureCallBack(errorStr)
        }
    }
}
