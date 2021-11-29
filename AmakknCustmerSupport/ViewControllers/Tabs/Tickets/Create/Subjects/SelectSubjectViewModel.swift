//
//  SelectSubjectViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 25/07/21.
//

import Foundation
import UIKit

class SelectSubjectViewModel {
    private var subjects: [SubjectModel]?

    var delegate: TicketsListDelegate?

    var cellCount: Int {
        return subjects?.count ?? 0
    }

    var cellHeight: CGFloat {
        return 65.0
    }

    subscript (_ index: Int) -> SubjectModel? {
        return subjects?[index]
    }
}

// MARK: - Get Subject API Call
extension SelectSubjectViewModel {
    func getSubjects() {
        AppLoader.show()

        TicketsNetworkManager.shared.getSubjects { [weak self] model in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.subjects = model?.subjects

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
