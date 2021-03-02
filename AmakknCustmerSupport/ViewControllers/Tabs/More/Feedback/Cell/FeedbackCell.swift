//
//  FeedbackCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/01/21.
//

import UIKit

// MARK: - Feedback Delegate
protocol FeedbackDelegate {
    func didSelect(userID: String?)
    func didSelect(email: String?)
}

class FeedbackCell: UITableViewCell {
    @IBOutlet weak var ibHolderView: UIView!
    @IBOutlet weak var ibUserIDButton: UIButton!
    @IBOutlet weak var ibEmailButton: UIButton!

    @IBOutlet weak var ibNextIcon: UIImageView!
    @IBOutlet weak var ibNextIconWidth: NSLayoutConstraint!

    @IBOutlet weak var ibUserIDLabel: UILabel!
    @IBOutlet weak var ibHeaderLabel: UILabel!
    @IBOutlet weak var ibNameLabel: UILabel!
    @IBOutlet weak var ibMessageLabel: UILabel!
    @IBOutlet weak var ibDateLabel: UILabel!

    var delegate: FeedbackDelegate?

    var dataSource: FeedbackModel? {
        didSet {
            updateUI()
            updateUserID()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        ibHolderView.layer.borderWidth = 1.0
        ibHolderView.layer.borderColor = AppColors.borderColor?.cgColor

        ibHeaderLabel.layer.masksToBounds = true
        ibHeaderLabel.layer.cornerRadius = 4.0
    }

    private func updateUI() {
        ibNameLabel.text = dataSource?.name
        ibMessageLabel.text = dataSource?.message
        ibDateLabel.text = Utility.shared.convertDates(for: dataSource?.createdDate)
        ibHeaderLabel.text = "  \(dataSource?.subject ?? "")  "

        ibEmailButton.setTitle(dataSource?.email, for: .normal)
    }

    private func updateUserID() {
        let title = (dataSource?.userID == "0") ? "Guest" : "UserID: \(dataSource?.userID ?? "")"
        ibUserIDLabel.text = title

        ibUserIDButton.isUserInteractionEnabled = (dataSource?.userID != "0")
        ibNextIcon.isHidden = (dataSource?.userID == "0")
        ibNextIconWidth.constant = (dataSource?.userID != "0") ? 24.0 : 0.0
    }
}

// MARK: - Button Actions
extension FeedbackCell {
    @IBAction func userIDButtonTapped(_ sender: UIButton) {
        delegate?.didSelect(userID: dataSource?.userID)
    }

    @IBAction func emailButtonTapped(_ sender: UIButton) {
        delegate?.didSelect(email: dataSource?.email)
    }
}
