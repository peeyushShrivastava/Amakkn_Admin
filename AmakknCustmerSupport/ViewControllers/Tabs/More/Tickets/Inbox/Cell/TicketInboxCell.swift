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
    @IBOutlet weak var ibFeedback: UILabel!
    @IBOutlet weak var ibLastMsgLabel: UILabel!
    
    var ticketModel: TicketsModel? {
        didSet {
            updateData()
            updateFeedback()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        updateUI()
    }

    private func updateUI() {
        layer.masksToBounds = false
        layer.cornerRadius = 8.0
        layer.borderWidth = 1.0
        layer.borderColor = AppColors.borderColor?.cgColor

        ibStatusHolder.layer.masksToBounds = true
        ibStatusHolder.layer.borderWidth = 1.0
        ibStatusHolder.layer.borderColor = AppColors.borderColor?.cgColor
    }

    private func updateData() {
        ticketTitleLabel.text = ticketModel?.title
        ibStatusLabel.text = ticketModel?.statusName
        ibLastMsgLabel.text = ticketModel?.lastMessage

        let dateInMilliSec = Utility.shared.dateStrInMilliSecs(dateStr: ticketModel?.updatedDate)
        let dateStr = Utility.shared.convertDates(with: dateInMilliSec)
        ibDateLabel.text = dateStr
    }

    private func updateFeedback() {
        guard let feedback = ticketModel?.feedback, let status = feedback.isUserHappy else { return }

        switch status {
            case "0":
                ibFeedback.text = "User is not happy"
                ibFeedback.textColor = .systemRed
            case "1":
                ibFeedback.text = "User is happy"
                ibFeedback.textColor = .systemGreen
            default:
                ibFeedback.text = nil
        }
    }
}

