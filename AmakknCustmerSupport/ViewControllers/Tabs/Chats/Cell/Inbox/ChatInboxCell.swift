//
//  ChatInboxCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 14/10/20.
//

import UIKit
import SDWebImage

class ChatInboxCell: UICollectionViewCell {
    @IBOutlet weak var ibAvatarView: UIImageView!

    @IBOutlet weak var ibInitialLabel: UILabel!
    @IBOutlet weak var ibLastMsgLabel: UILabel!
    @IBOutlet weak var ibSubjectLabel: UILabel!

    @IBOutlet weak var ibNameLabel: UILabel!
    @IBOutlet weak var ibDateLabel: UILabel!

    var inboxModel: ChatInboxModel? {
        didSet {
            updateTitle()
            updateAvater()
            updateLabels()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        updateUI()
    }

    private func updateUI() {
        ibSubjectLabel.layer.masksToBounds = true
        ibSubjectLabel.layer.cornerRadius = 4.0

        ibAvatarView.layer.masksToBounds = true
        ibAvatarView.layer.borderWidth = 1.0
        ibAvatarView.layer.borderColor = AppColors.borderColor?.cgColor
    }

    private func updateTitle() {
        let userType = AppSession.manager.userID == inboxModel?.userID1 ? inboxModel?.userType2 : inboxModel?.userType1
        let userName = AppSession.manager.userID == inboxModel?.userID1 ? inboxModel?.userName2 : inboxModel?.userName1

        if let userTypeStr = userType, let userType = UserType(rawValue: userTypeStr), let userName = userName {
            switch userType {
            case .normal:
                ibNameLabel.text = "\(UserTypeStr.normal.rawValue): \(userName)"
            case .owner:
                ibNameLabel.text = "\(UserTypeStr.owner.rawValue): \(userName)"
            case .broker:
                ibNameLabel.text = "\(UserTypeStr.broker.rawValue): \(userName)"
            case .company:
                ibNameLabel.text = "\(UserTypeStr.company.rawValue): \(userName)"
            case .agent:
                ibNameLabel.text = "\(UserTypeStr.agent.rawValue): \(userName)"
            }
        }
    }

    private func updateLabels() {
        ibDateLabel.text = Utility.shared.convertDates(for: inboxModel?.updatedAt)
        ibLastMsgLabel.text = inboxModel?.lastMessage
        ibSubjectLabel.text = "  \(inboxModel?.subject ?? "")  "
    }

    private func updateAvater() {
        guard let userName = AppSession.manager.userID == inboxModel?.userID1 ? inboxModel?.userName2 : inboxModel?.userName1 else { return }

        let avatar = AppSession.manager.userID == inboxModel?.userAvatar2 ? inboxModel?.userName2 : inboxModel?.userAvatar1

        if avatar?.isEmpty ?? true {
            ibAvatarView.image = nil

            ibInitialLabel.isHidden = false
            ibInitialLabel.text = userName.first?.uppercased()
        } else {
            ibInitialLabel.isHidden = true

            ibAvatarView.sd_setImage(with: URL(string: avatar ?? ""), placeholderImage: UIImage())
        }
    }
}
