//
//  AmenityDetailsCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 26/10/20.
//

import UIKit

class AmenityDetailsCell: UICollectionViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!

    var model: Amenity? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.masksToBounds = true
        layer.borderColor = AppColors.borderColor?.cgColor
        layer.borderWidth = 1.0
    }

    private func updateUI() {
        ibTitleLabel.text = model?.name
    }
}
