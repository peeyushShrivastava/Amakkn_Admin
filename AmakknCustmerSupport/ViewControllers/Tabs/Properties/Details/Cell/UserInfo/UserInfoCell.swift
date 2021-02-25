//
//  UserInfoCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 26/10/20.
//

import UIKit

// MARK: - Host Delegate
protocol DetailsHostdelegate {
    func companyDidTapped(for companyID: String?, and userType: String?)
    func hostDidTapped(for userID: String?, and userType: String?)
}

class UserInfoCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibHostNameLabel: UILabel!
    @IBOutlet weak var ibAccountTypeLabel: UILabel!
    @IBOutlet weak var ibPhoneTitle: UILabel!
    @IBOutlet weak var ibPhoneLabel: UILabel!

//    @IBOutlet weak var ibIndividualAvatar: UIImageView!
    @IBOutlet weak var ibCompanyAvatar: UIImageView!

    @IBOutlet weak var ibCompanyButton: UIButton!
//    @IBOutlet weak var ibIndividualButton: UIButton!

    @IBOutlet weak var ibVerifiedIcon: UIImageView!
//    @IBOutlet weak var ibVerifiedIconWidth: NSLayoutConstraint!
//    @IBOutlet weak var ibVerifiedIconLeadingConstraint: NSLayoutConstraint!
    
    var delegate: DetailsHostdelegate?
    var hostModel: DetailsHostModel?

    override func awakeFromNib() {
        super.awakeFromNib()

//        ibIndividualAvatar.layer.masksToBounds = true
        ibCompanyAvatar.layer.masksToBounds = true

//        ibIndividualAvatar.layer.cornerRadius = ibIndividualAvatar.frame.size.height/2
        ibCompanyAvatar.layer.cornerRadius = 10.0//ibCompanyAvatar.frame.size.height/2

//        ibIndividualAvatar.layer.borderWidth = 1.0
        ibCompanyAvatar.layer.borderWidth = 1.0
//        ibIndividualAvatar.layer.borderColor = AppColors.borderColor?.cgColor
        ibCompanyAvatar.layer.borderColor = AppColors.borderColor?.cgColor
    }

    func configure(data details: DetailsHostModel?) {
        hostModel = details

        updateTexts()
        updateAccountType()
        updateAvatar()
    }
}

// MARK: - Private Methods
extension UserInfoCell {
    private func updateTexts() {
        ibPhoneTitle.text = "\("Agent_Phone".localized()):"

        ibHostNameLabel.text = hostModel?.hostName
        ibPhoneLabel.text = "(\(hostModel?.countryCode ?? "")) \(hostModel?.hostPhone ?? "")"
    }

    private func updateAccountType() {
        guard let userTypeStr = hostModel?.userType, let userType = UserType(rawValue: userTypeStr) else { return }
        guard let accountTypeStr = hostModel?.accountType, let accountType = AccountType(rawValue: accountTypeStr) else { return }

        switch accountType {
        case .individual:
            let typeText = userType == .broker ? "\("UserType_Broker".localized())" : "\("UserType_Owner".localized())"

            ibAccountTypeLabel.text = typeText
        case .corporate:
            let typeText = userType == .company ? "\("UserType_Corporate".localized())" : "\("UserType_Agent".localized())"

            ibAccountTypeLabel.text = typeText
        }
    }

    private func updateAvatar() {
//        guard let userTypeStr = hostModel?.userType, let userType = UserType(rawValue: userTypeStr) else { return }
        guard let accountTypeStr = hostModel?.accountType, let accountType = AccountType(rawValue: accountTypeStr) else { return }

        switch accountType {
        case .individual:
            let placeHolderImage = UIImage(named: "icAvatarPlaceHolderIcon")

//            ibIndividualButton.isHidden = true
//            ibIndividualAvatar.isHidden = true

//            ibVerifiedIconWidth.constant = 0.0
//            ibVerifiedIconLeadingConstraint.constant = 0.0

            ibCompanyAvatar.sd_setImage(with: URL(string: hostModel?.hostAvatar ?? ""), placeholderImage: placeHolderImage)
        case .corporate:
            let compPlaceHolder = Utility.shared.selectedLanguage == .english ? UIImage(named: "icAvatarPlaceHolderIcon") : UIImage(named: "icAvatarPlaceHolderIcon")
//            let individualpPlaceHolder = UIImage(named: "icIndividualPlaceHolder")

//            ibIndividualButton.isHidden = true//!(userType == .company)
//            ibIndividualAvatar.isHidden = true//!(userType == .company)

            ibVerifiedIcon.isHidden = !(hostModel?.hasCompanyVerified ?? false)

//            ibVerifiedIconWidth.constant = ibVerifiedIcon.isHidden ? 0.0 : 21.0
//            ibVerifiedIconLeadingConstraint.constant = ibVerifiedIcon.isHidden ? 0.0 : 3.0

//            ibIndividualAvatar.sd_setImage(with: URL(string: hostModel?.hostAvatar ?? ""), placeholderImage: individualpPlaceHolder)
            ibCompanyAvatar.sd_setImage(with: URL(string: hostModel?.companyAvatar ?? ""), placeholderImage: compPlaceHolder)
        }
    }
}

// MARK: - Button Actions
extension UserInfoCell {
    @IBAction func companyButtonTapped(_ sender: UIButton) {
//        guard let accountTypeStr = hostModel?.accountType, let accountType = AccountType(rawValue: accountTypeStr) else { return }

        delegate?.hostDidTapped(for: hostModel?.hostID, and: hostModel?.userType)
//        accountType == .individual ? delegate?.hostDidTapped(for: hostModel?.hostID, and: hostModel?.userType) : delegate?.companyDidTapped(for: hostModel?.companyID, and: hostModel?.userType)
    }

//    @IBAction func hostButtonTapped(_ sender: UIButton) {
//        delegate?.hostDidTapped(for: hostModel?.hostID, and: hostModel?.userType)
//    }
}
