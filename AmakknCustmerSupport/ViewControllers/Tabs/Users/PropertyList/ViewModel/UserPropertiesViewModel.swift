//
//  UserPropertiesViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 23/12/20.
//

import Foundation
import UIKit

// MARK: - UserProperties Delegate
protocol UserPropertiesDelegate {
    func didFinishWithSuccess(_ isListEmpty: Bool)
    func didFinishWithFailure(_ errorStr: String?)
}

class UserPropertiesViewModel {
    private var properties: String?
    private var propertyList: [PropertyCardsModel]?

    var delegate: UserPropertiesDelegate?

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

    subscript (_ index: Int) -> PropertyCardsModel? {
        return propertyList?[index]
    }

    func update(_ properties: String?) {
        self.properties = properties

        getProperties()
    }
}

// MARK: - API Call
extension UserPropertiesViewModel {
    func getProperties() {
        guard AppSession.manager.validSession, let properties =  properties else { return }

        UsersNetworkManager.shared.getUserProperties(for: properties) { [weak self] responseModel in
            DispatchQueue.main.async {
                self?.propertyList = responseModel

                self?.delegate?.didFinishWithSuccess(self?.propertyList?.isEmpty ?? true)
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.delegate?.didFinishWithFailure(errorStr)
            }
        }
    }
}
