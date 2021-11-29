//
//  UserDetailsProfileCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 22/10/20.
//

import UIKit

// MARK: - UserDetailsProfile Delegate
protocol UserDetailsProfileDelegate {
    func callDidTapped(with phone: String?, _ countryCode: String?)
    func chatDidTapped(with userID: String?)
}

class UserDetailsProfileCell: UITableViewCell {
    @IBOutlet weak var ibAvatar: UIImageView!
    @IBOutlet weak var ibInitialLabel: UILabel!
    @IBOutlet weak var ibUserIDLabel: UILabel!
    @IBOutlet weak var ibNamelabel: UILabel!
    @IBOutlet weak var ibEmailLabel: UILabel!
    @IBOutlet weak var ibPhoneLabel: UILabel!
    @IBOutlet weak var ibVerifiedIcon: UIImageView!
    @IBOutlet weak var ibPhoneButton: UIButton!
    @IBOutlet weak var ibChatButton: UIButton!
    
    var delegate: UserDetailsProfileDelegate?

    var profileModel: UserProfileDetails? {
        didSet {
            updateUI()
            updateAvatar()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.masksToBounds = true
        layer.cornerRadius = 8.0
        
        ibAvatar.layer.masksToBounds = true
        ibAvatar.layer.borderWidth = 1.0
        ibAvatar.layer.borderColor = AppColors.borderColor?.cgColor

        ibPhoneButton.layer.masksToBounds = true
        ibPhoneButton.layer.borderWidth = 1.0
        ibPhoneButton.layer.borderColor = AppColors.borderColor?.cgColor

        ibChatButton.layer.masksToBounds = true
        ibChatButton.layer.borderWidth = 1.0
        ibChatButton.layer.borderColor = AppColors.borderColor?.cgColor
    }

    private func updateUI() {
        ibUserIDLabel.text = profileModel?.userID
        ibNamelabel.text = profileModel?.userName
        ibPhoneLabel.text = "\(profileModel?.countryCode ?? "") \(profileModel?.userPhone ?? "")"
        ibVerifiedIcon.isHidden = (profileModel?.isVerified != "2")

        if let email = profileModel?.userEmail {
            ibEmailLabel.text = email.isEmpty ? "--" : email
        }
    }

    private func updateAvatar() {
        guard let imageURLStr = profileModel?.userAvatar, !imageURLStr.isEmpty else {
            ibInitialLabel.text = profileModel?.userName?.first?.uppercased()
            ibInitialLabel.isHidden = false

            return
        }

        ibInitialLabel.isHidden = true
        ibAvatar.sd_setImage(with: URL(string: imageURLStr), placeholderImage: UIImage())
        ibAvatar.contentMode = .scaleAspectFill
    }
}

// MARK: - Button Actions
extension UserDetailsProfileCell {
    @IBAction func callButtonTapped(_ sender: UIButton) {
        delegate?.callDidTapped(with: profileModel?.userPhone, profileModel?.countryCode)
    }

    @IBAction func chatButtonTapped(_ sender: UIButton) {
        delegate?.chatDidTapped(with: profileModel?.userID)
    }
}
