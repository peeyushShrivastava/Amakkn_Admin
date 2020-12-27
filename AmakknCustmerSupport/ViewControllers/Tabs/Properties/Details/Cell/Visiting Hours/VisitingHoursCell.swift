//
//  VisitingHoursCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 26/10/20.
//

import UIKit

// MARK: - Visiting Hrs Delegate
protocol DetailsVisitingsHrsDelegate {
    func callDidTap(with phone: String?, and countryCode: String?)
}

class VisitingHoursCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleLabel: UILabel!

    @IBOutlet weak var ibTimingTitleLabel: UILabel!
    @IBOutlet weak var ibDaysTitleLabel: UILabel!
    @IBOutlet weak var ibPhoneTitleLabel: UILabel!

    @IBOutlet weak var ibTimingLabel: UILabel!
    @IBOutlet weak var ibDaysLabel: UILabel!
    @IBOutlet weak var ibPhoneButton: UIButton!

    var dataSource: DetailsVisitingHrsModel?
    var delegate: DetailsVisitingsHrsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        ibTitleLabel.text = "VisitingHrs".localized()
        ibTimingTitleLabel.text = "Timing".localized()
        ibDaysTitleLabel.text = "Days".localized()
        ibPhoneTitleLabel.text = "PhoneNo".localized()
    }

    func configure(data details: DetailsVisitingHrsModel?) {
        dataSource = details

        updateUI()
    }

    private func updateUI() {
        ibTimingLabel.text = dataSource?.timing
        ibDaysLabel.text = dataSource?.days

        let phone = "(\(dataSource?.countryCode ?? "")) \(dataSource?.phone ?? "")"
        ibPhoneButton.setTitle(phone, for: .normal)
    }
}

// MARK: - Button Actions
extension VisitingHoursCell {
    @IBAction func phoneButtonTapped(_ sender: UIButton) {
        delegate?.callDidTap(with: dataSource?.phone, and: dataSource?.countryCode)
    }
}
