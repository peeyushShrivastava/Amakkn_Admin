//
//  ViolationCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 02/08/21.
//

import UIKit

class ViolationCell: UICollectionViewCell {
    @IBOutlet weak var ibAvatar: UIImageView!
    @IBOutlet weak var ibFirstChar: UILabel!
    @IBOutlet weak var ibNameLabel: UILabel!
    @IBOutlet weak var ibPhoneLabel: UILabel!
    @IBOutlet weak var ibUserIDLabel: UILabel!
    @IBOutlet weak var ibCount: UILabel!

    var violationModel: ViolationModel? {
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
        layer.borderWidth = 1.0
        layer.borderColor = AppColors.borderColor?.cgColor

        ibAvatar.layer.masksToBounds = true
        ibAvatar.layer.borderWidth = 1.0
        ibAvatar.layer.borderColor = AppColors.borderColor?.cgColor

        ibCount.layer.masksToBounds = true
        ibCount.layer.cornerRadius = 12.5
    }

    private func updateData() {
        ibNameLabel.text = violationModel?.userName
        ibPhoneLabel.text = "\(violationModel?.cCode ?? "")-\(violationModel?.phone ?? "")"

        ibUserIDLabel.text = "UserID: \(violationModel?.userID ?? "")"
        ibCount.text = violationModel?.violationCount

        if let avatar = violationModel?.userAvatar, avatar != "" {
            ibFirstChar.isHidden = true

            ibAvatar.sd_setImage(with: URL(string: avatar), placeholderImage: nil)
        } else {
            ibAvatar.image = nil

            ibFirstChar.isHidden = false
            ibFirstChar.text = violationModel?.userName?.first?.uppercased()
        }
    }
}
