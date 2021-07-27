//
//  TicketInboxCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import UIKit

class TicketInboxCell: UICollectionViewCell {
    @IBOutlet weak var ticketTitleLabel: UILabel!
    @IBOutlet weak var ibStatusHolder: UIView!
    @IBOutlet weak var ibStatusLabel: UILabel!
    @IBOutlet weak var ibDateLabel: UILabel!
    
    var ticketModel: TicketsModel? {
        didSet {
            updateData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        updateUI()
    }

    private func updateUI() {
        layer.masksToBounds = false
        layer.cornerRadius = 8.0

        ibStatusHolder.layer.masksToBounds = true
        ibStatusHolder.layer.borderWidth = 1.0
        ibStatusHolder.layer.borderColor = AppColors.borderColor?.cgColor
    }

    private func updateData() {
        ticketTitleLabel.text = ticketModel?.title
        ibStatusLabel.text = ticketModel?.statusName

        let dateInMilliSec = Utility.shared.dateStrInMilliSecs(dateStr: ticketModel?.createdDate)
        let dateStr = Utility.shared.convertDates(with: dateInMilliSec)
        ibDateLabel.text = dateStr
    }
}

