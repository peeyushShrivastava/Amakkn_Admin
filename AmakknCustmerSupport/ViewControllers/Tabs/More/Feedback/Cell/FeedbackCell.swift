//
//  FeedbackCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 31/12/20.
//

import UIKit

class FeedbackCell: UICollectionViewCell {
    @IBOutlet weak var ibNameLabel: UILabel!
    @IBOutlet weak var ibEmailLabel: UILabel!
    @IBOutlet weak var ibMessageLabel: UILabel!

    var dataSource: FeedbackModel? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.masksToBounds = true
        layer.cornerRadius = 8.0
        layer.borderColor = AppColors.borderColor?.cgColor
        layer.borderWidth = 1.0
    }

    private func updateUI() {
        ibNameLabel.text = dataSource?.name
        ibEmailLabel.text = dataSource?.email
        ibMessageLabel.text = dataSource?.message
    }
}
