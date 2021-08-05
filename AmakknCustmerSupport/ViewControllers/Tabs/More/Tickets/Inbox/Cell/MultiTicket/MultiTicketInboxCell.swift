//
//  MultiTicketInboxCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 03/08/21.
//

import UIKit

// MARK: - MultiTicketInboxCell Delegate
protocol MultiTicketCellDelegate {
    func didSelectTicket(with model: TicketsModel?, for tag: Int)
}

class MultiTicketInboxCell: UICollectionViewCell {
    @IBOutlet weak var ticketTitleLabel: UILabel!
    @IBOutlet weak var ibStatusHolder: UIView!
    @IBOutlet weak var ibStatusLabel: UILabel!
    @IBOutlet weak var ibDateLabel: UILabel!
    @IBOutlet weak var ibFeedBack: UILabel!
    @IBOutlet weak var ibLastMsg: UILabel!

    @IBOutlet weak var childTicketTitleLabel: UILabel!
    @IBOutlet weak var ibChildStatusHolder: UIView!
    @IBOutlet weak var ibChildStatusLabel: UILabel!
    @IBOutlet weak var ibChildDateLabel: UILabel!
    @IBOutlet weak var ibChildLastMsg: UILabel!

    var delegate: MultiTicketCellDelegate?

    var ticketModel: TicketsModel? {
        didSet {
            updateData()
            updateChildData()
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

        ibChildStatusHolder.layer.masksToBounds = true
        ibChildStatusHolder.layer.borderWidth = 1.0
        ibChildStatusHolder.layer.borderColor = AppColors.borderColor?.cgColor
    }

    private func updateData() {
        ticketTitleLabel.text = ticketModel?.title
        ibStatusLabel.text = ticketModel?.statusName
        ibLastMsg.text = ticketModel?.lastMessage

        let dateInMilliSec = Utility.shared.dateStrInMilliSecs(dateStr: ticketModel?.updatedDate)
        let dateStr = Utility.shared.convertDates(with: dateInMilliSec)
        ibDateLabel.text = dateStr
    }

    private func updateChildData() {
        guard let child = ticketModel?.children?.last else { return }

        childTicketTitleLabel.text = child.title
        ibChildStatusLabel.text = child.statusName
        ibLastMsg.text = child.lastMessage

        let dateInMilliSec = Utility.shared.dateStrInMilliSecs(dateStr: child.updatedDate)
        let dateStr = Utility.shared.convertDates(with: dateInMilliSec)
        ibChildDateLabel.text = dateStr
    }

    private func updateFeedback() {
        guard let feedback = ticketModel?.feedback, let status = feedback.isUserHappy else { return }

        switch status {
            case "0":
                ibFeedBack.text = "User is not happy"
                ibFeedBack.textColor = .systemRed
            case "1":
                ibFeedBack.text = "User is happy"
                ibFeedBack.textColor = .systemGreen
            default:
                ibFeedBack.text = nil
        }
    }
}

// MARK: - Button Action
extension MultiTicketInboxCell {
    @IBAction func SelectTapped(_ sender: UIButton) {
        delegate?.didSelectTicket(with: ticketModel, for: sender.tag)
    }
}
