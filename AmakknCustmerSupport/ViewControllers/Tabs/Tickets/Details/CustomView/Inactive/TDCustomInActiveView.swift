//
//  TDCustomInActiveView.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import UIKit

class TDCustomInActiveView: UIView {
    @IBOutlet weak var ibTitleLabel: UILabel!

    /// Ticket Model
    var ticketModel: TicketDetails? {
        didSet {
            updateUI()
        }
    }

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    private func updateUI() {
        ibTitleLabel.text = ticketModel?.statusName
    }
}
