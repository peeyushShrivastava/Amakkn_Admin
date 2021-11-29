//
//  MoreCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 19/10/20.
//

import UIKit

class MoreCell: UITableViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibCountLabel: UILabel!
    @IBOutlet weak var bCountHolder: UIView!

    var titleText: String? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    private func updateUI() {
        ibTitleLabel.text = titleText

        if titleText == "Logout".localized() {
            ibTitleLabel.textColor = .systemPink
        }

        let chatBadgeCount = AppUserDefaults.manager.chatBadgeCount
        bCountHolder.isHidden = (chatBadgeCount == nil || chatBadgeCount == "0")
        ibCountLabel.text = chatBadgeCount
        bCountHolder.isHidden = (titleText != "Chat")
    }
}
