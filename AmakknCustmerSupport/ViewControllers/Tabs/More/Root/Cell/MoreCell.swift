//
//  MoreCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 19/10/20.
//

import UIKit

class MoreCell: UITableViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!

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
    }
}
