//
//  TicketsInboxViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import Foundation
import UIKit

// MARK: - TicketsList Delegate
protocol TicketsListDelegate {
    func success()
    func failed(with errorStr: String?)
}

class TicketsInboxViewModel {
    private var tickets: [TicketsModel]?

    var delegate: TicketsListDelegate?

    var cellCount: Int {
        return tickets?.count ?? 0
    }

    var cellHeight: CGFloat {
        return 90.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? (UIScreen.main.bounds.width - 32.0)/2 : UIScreen.main.bounds.width - 32.0
        return width
    }

    subscript (_ index: Int) -> TicketsModel? {
        return tickets?[index]
    }
}

// MARK: Get Tickets API Call
extension TicketsInboxViewModel {
    func getTickets() {
        AppLoader.show()

        TicketsNetworkManager.shared.getTickets { respModel in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.tickets = respModel?.tickets
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
