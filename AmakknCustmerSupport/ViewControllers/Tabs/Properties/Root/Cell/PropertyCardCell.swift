//
//  PropertyCardCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/10/20.
//

import UIKit

class PropertyCardCell: UICollectionViewCell {
    @IBOutlet weak var ibPropertyImageView: UIImageView!
    @IBOutlet weak var ibPropertyTypeLabel: UILabel!
    @IBOutlet weak var ibStatusLabel: UILabel!
    @IBOutlet weak var ibPriceLabel: UILabel!
    @IBOutlet weak var ibAddressLabel: UILabel!
    @IBOutlet weak var ibCreatedDate: UILabel!

    var dataSource: PropertyCardsModel? {
        didSet {
            updateUI()
            updatePhoto()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.masksToBounds = true
        layer.cornerRadius = 8.0
        layer.borderColor = AppColors.borderColor?.cgColor
        layer.borderWidth = 1.0

        ibPropertyTypeLabel.layer.masksToBounds = true
        ibPropertyTypeLabel.layer.cornerRadius = 2.0

        ibStatusLabel.layer.masksToBounds = true
        ibStatusLabel.layer.cornerRadius = 2.0
    }

    private func updateUI() {
        ibPriceLabel.text = dataSource?.defaultPrice?.amkFormat
        ibPropertyTypeLabel.text = "  \(Utility.shared.getPropertyTypeName(for: dataSource?.propertyType, with: dataSource?.category) ?? "")  "
        ibAddressLabel.text = dataSource?.address
        ibCreatedDate.text = "Created On: \(Utility.shared.convertDates(for: dataSource?.createdAt) ?? "")"
        ibStatusLabel.text = getStatus()
    }

    private func updatePhoto() {
        guard let category = dataSource?.category, let type = dataSource?.propertyType else { return }

        let imgName = "PlaceHolder_\(category)_\(type)"
        let placeHolderImage = UIImage(named: imgName)

        ibPropertyImageView.image = nil
        ibPropertyImageView.image = placeHolderImage
        ibPropertyImageView.contentMode = .center

        guard let imageURLStr = dataSource?.photos else { return }

        ibPropertyImageView.sd_setImage(with: URL(string: imageURLStr), placeholderImage: placeHolderImage)
        ibPropertyImageView.contentMode = .scaleAspectFill
    }

    private func getStatus() -> String? {
        guard let status = dataSource?.status, let price = dataSource?.defaultPrice else { return nil }

        switch status {
            case "0":
                if price == "" || price == "0" {
                    return "  Incomplete  "
                } else {
                    return "  Unpublished  "
                }
            case "1":
                return "  Published  "
            default:
                return "  Sold out  "
                
        }
    }
}
