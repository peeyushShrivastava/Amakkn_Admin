//
//  DetailsOverviewCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 26/10/20.
//

import UIKit

class DetailsOverviewCell: UITableViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibValueLabel: UILabel!

    var dataSource: OverviewListModel? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        ibTitleLabel.layer.masksToBounds = true
        ibValueLabel.layer.masksToBounds = true

        ibTitleLabel.layer.borderWidth = 1.0
        ibValueLabel.layer.borderWidth = 1.0

        ibTitleLabel.layer.borderColor = AppColors.borderColor?.cgColor
        ibValueLabel.layer.borderColor = AppColors.borderColor?.cgColor
    }

    private func updateUI() {
        ibTitleLabel.text = dataSource?.name
        ibValueLabel.text = dataSource?.value
    }
}
