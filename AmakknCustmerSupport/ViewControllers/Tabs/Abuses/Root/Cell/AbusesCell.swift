//
//  AbusesCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/12/20.
//

import UIKit

class AbusesCell: UITableViewCell {
    @IBOutlet weak var ibHolderView: UIView!
    @IBOutlet weak var ibCounterLabel: UILabel!
    @IBOutlet weak var ibPropertyImageView: UIImageView!

    @IBOutlet weak var ibPropertyTypeLabel: UILabel!
    @IBOutlet weak var ibPriceLabel: UILabel!
    @IBOutlet weak var ibAddressLabel: UILabel!

    var dataSource: PropertyCardsModel? {
        didSet {
            updateCount()
            updateTexts()
            updatePhoto()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        updateUI()
    }

    private func updateUI() {
        ibPropertyImageView.layer.masksToBounds = true
        ibPropertyImageView.layer.cornerRadius = 4.0

        ibHolderView.layer.masksToBounds = true
        ibHolderView.layer.cornerRadius = 8.0

        ibCounterLabel.layer.masksToBounds = true
        ibCounterLabel.layer.cornerRadius = 10.0
    }

    private func updateCount() {
        guard let count = dataSource?.complaintCount, !count.isEmpty else { ibCounterLabel.isHidden = true; return }

        ibCounterLabel.isHidden = false
        ibCounterLabel.text = count
    }

    private func updateTexts() {
        ibPriceLabel.text = dataSource?.defaultPrice?.amkFormat
        ibAddressLabel.text = dataSource?.address

        let propertyTypeName = Utility.shared.getPropertyTypeName(for: dataSource?.propertyType, with: dataSource?.category)
        ibPropertyTypeLabel.text = "\(propertyTypeName ?? "")"
    }

    private func updatePhoto() {
        guard let category = dataSource?.category, let type = dataSource?.propertyType else { return }

        let imgName = "PlaceHolder_\(category)_\(type)"
        let placeHolderImage = UIImage(named: imgName)

        ibPropertyImageView.image = placeHolderImage
        ibPropertyImageView.contentMode = .center

        guard let imageURLStr = dataSource?.photos?.components(separatedBy: ",").first else { return }

        ibPropertyImageView.sd_setImage(with: URL(string: imageURLStr), placeholderImage: placeHolderImage)
        ibPropertyImageView.contentMode = .scaleAspectFill
    }
}
