//
//  ComplaintCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 22/12/20.
//

import UIKit

class ComplaintCell: UITableViewCell {
    @IBOutlet weak var ibReporterNameLabel: UILabel!
    @IBOutlet weak var ibUserTypeLabel: UILabel!
    @IBOutlet weak var ibDateLabel: UILabel!
    @IBOutlet weak var ibDescriptionLabel: UILabel!
    @IBOutlet weak var ibAvatar: UIImageView!
    @IBOutlet weak var ibInitialLabel: UILabel!

    var index = 0
    var delegate: UserCellDelegate?

    var complaint: ComplaintModel? {
        didSet {
            updateUI()
            updateAvatar()
            updateUserType()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        ibAvatar.layer.masksToBounds = true
        ibAvatar.layer.borderWidth = 1.0
        ibAvatar.layer.cornerRadius = 25.0
        ibAvatar.layer.borderColor = AppColors.borderColor?.cgColor

        ibUserTypeLabel.layer.masksToBounds = true
        ibUserTypeLabel.layer.cornerRadius = 4.0
    }

    private func updateUI() {
        ibReporterNameLabel.text = complaint?.userName
        ibDateLabel.text = Utility.shared.convertDates(for: complaint?.updatedAt)
        ibDescriptionLabel.text = complaint?.description
    }

    private func updateAvatar() {
        guard let avatar = complaint?.avatar, let userName = complaint?.userName else { return }

        if avatar.isEmpty {
            ibAvatar.image = nil

            ibInitialLabel.isHidden = false
            ibInitialLabel.text = userName.first?.uppercased()
        } else {
            ibInitialLabel.isHidden = true

            ibAvatar.sd_setImage(with: URL(string: avatar), placeholderImage: UIImage())
        }
    }

    private func updateUserType() {
        if let userTypeStr = complaint?.userType, let userType = UserType(rawValue: userTypeStr) {
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
}

// MARK: - Button Actions
extension ComplaintCell {
    @IBAction func callButtonTapped(_ sender: UIButton) {
        delegate?.didSelectCall(with: complaint?.phone, complaint?.countryCode)
    }

    @IBAction func chatButtonTapped(_ sender: UIButton) {
        delegate?.didSelectChat(at: index)
    }
}
