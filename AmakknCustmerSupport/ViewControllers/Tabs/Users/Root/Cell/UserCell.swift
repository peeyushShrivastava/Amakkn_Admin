//
//  UserCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/10/20.
//

import UIKit

class UserCell: UICollectionViewCell {
    @IBOutlet weak var ibPropertyImageView: UIImageView!
    @IBOutlet weak var ibNameLabel: UILabel!
    @IBOutlet weak var ibPhoneText: UIButton!
    @IBOutlet weak var ibEmailText: UIButton!

    var userModel: UserStatsModel? {
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

        ibPropertyImageView.layer.masksToBounds = true
        ibPropertyImageView.layer.cornerRadius = 50.0
        ibPropertyImageView.layer.borderColor = AppColors.borderColor?.cgColor
        ibPropertyImageView.layer.borderWidth = 1.0
    }

    private func updateUI() {
        ibNameLabel.text = userModel?.userName
        ibEmailText.setTitle(userModel?.userEmail, for: .normal)
        ibPhoneText.setTitle("\(userModel?.countryCode ?? "") \(userModel?.userPhone ?? "")", for: .normal)
    }
}
