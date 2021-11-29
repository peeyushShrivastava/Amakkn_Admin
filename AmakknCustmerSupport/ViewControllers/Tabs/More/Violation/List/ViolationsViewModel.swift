//
//  ViolationsViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 02/08/21.
//

import Foundation
import UIKit

class ViolationsViewModel {
    private var violations: [ViolationModel]?

    var delegate: TicketsListDelegate?

    var cellCount: Int {
        return violations?.count ?? 0
    }

    var cellHeight: CGFloat {
        return 90.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - 32.0)/2 : UIScreen.main.bounds.width - 32.0
        return width
    }

    subscript (_ index: Int) -> ViolationModel? {
        return violations?[index]
    }
}

// MARK: Get getViolations API Call
extension ViolationsViewModel {
    func getViolations() {
        AppLoader.show()

        TicketsNetworkManager.shared.getViolationUsers { respModel in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.violations = respModel
                self?.delegate?.success()
            }
        } failureCallBack: { errorStr in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }
    }
}
