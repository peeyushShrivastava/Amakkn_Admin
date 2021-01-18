//
//  UserCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/10/20.
//

import UIKit

// MARK:- UserCell Delgate
protocol UserCellDelegate {
    func didSelectCall(with phone: String?, _ countryCode: String?)
    func didSelectChat(at index: Int)
}

class UserCell: UICollectionViewCell {
    @IBOutlet weak var ibAvatar: UIImageView!
    @IBOutlet weak var ibNameLabel: UILabel!
    @IBOutlet weak var ibPhoneText: UILabel!
    @IBOutlet weak var ibCallButton: UIButton!
    @IBOutlet weak var ibChatButton: UIButton!
    @IBOutlet weak var ibInitiallabel: UILabel!
    @IBOutlet weak var ibUserTypeLabel: UILabel!
    @IBOutlet weak var ibVerified: UIImageView!
    @IBOutlet weak var ibCreatedDate: UILabel!

    var isFilterCalled = false

    var delegate: UserCellDelegate?
    var cellIndex = 0

    var userModel: SearchedUserModel? {
        didSet {
            updateUI()
            updateAvatar()
            updateUserType()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.masksToBounds = true
        layer.cornerRadius = 8.0
        layer.borderColor = AppColors.borderColor?.cgColor
        layer.borderWidth = 1.0

        ibAvatar.layer.masksToBounds = true
        ibAvatar.layer.cornerRadius = 30.0
        ibAvatar.layer.borderColor = AppColors.borderColor?.cgColor
        ibAvatar.layer.borderWidth = 1.0
        
        ibUserTypeLabel.layer.masksToBounds = true
        ibUserTypeLabel.layer.cornerRadius = 2.0
        
        ibCallButton.layer.masksToBounds = true
        ibCallButton.layer.cornerRadius = 20.0
        ibCallButton.layer.borderColor = AppColors.borderColor?.cgColor
        ibCallButton.layer.borderWidth = 1.0
        
        ibChatButton.layer.masksToBounds = true
        ibChatButton.layer.cornerRadius = 20.0
        ibChatButton.layer.borderColor = AppColors.borderColor?.cgColor
        ibChatButton.layer.borderWidth = 1.0
    }

    private func updateUI() {
        ibNameLabel.text = userModel?.userName
        ibPhoneText.text = "\(userModel?.countryCode ?? "") \(userModel?.userPhone ?? "")"
        ibVerified.isHidden = isFilterCalled ? (userModel?.isUserVerified != "2") : (userModel?.isVerified != "2")
        ibCreatedDate.text = "Created On: \(Utility.shared.convertDates(for: userModel?.createdAt) ?? "")"
    }

    private func updateAvatar() {
        guard let imageURLStr = userModel?.userAvatar, !imageURLStr.isEmpty else {
            ibAvatar.image = nil

            ibInitiallabel.text = userModel?.userName?.first?.uppercased()
            ibInitiallabel.isHidden = false

            return
        }

        ibInitiallabel.text = nil
        ibInitiallabel.isHidden = true
        ibAvatar.sd_setImage(with: URL(string: imageURLStr), placeholderImage: UIImage())
    }

    private func updateUserType() {
        guard let rawUserType = userModel?.userType, let userType = UserType(rawValue: rawUserType) else { return }

        switch userType {
            case .normal:
                ibUserTypeLabel.text = "  \(UserTypeStr.normal.rawValue)  "
            case .owner:
                ibUserTypeLabel.text = "  \(UserTypeStr.owner.rawValue)  "
            case .broker:
                ibUserTypeLabel.text = "  \(UserTypeStr.broker.rawValue)  "
            case .company:
                ibUserTypeLabel.text = "  \(UserTypeStr.company.rawValue)  "
            case .agent:
                ibUserTypeLabel.text = "  \(UserTypeStr.agent.rawValue)  "
            case .admin:
                ibUserTypeLabel.text = "  \(UserTypeStr.admin.rawValue)  "
        }
    }
}

// MARK: - Button Actions
extension UserCell {
    @IBAction func callButtonTapped(_ sender: UIButton) {
        delegate?.didSelectCall(with: userModel?.userPhone, userModel?.countryCode)
    }

    @IBAction func chatButtonTapped(_ sender: UIButton) {
        delegate?.didSelectChat(at: cellIndex)
    }
}
