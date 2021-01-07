//
//  EditDescriptionCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/01/21.
//

import UIKit

class EditDescriptionCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleHolderView: UIView!
    @IBOutlet weak var ibCharCountLabel: UILabel!
    @IBOutlet weak var ibTextView: UITextView!
    @IBOutlet weak var ibHolderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        updateUI()
    }

    private func updateUI() {
        let corners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let radii: CGFloat = 8.0

        ibTitleHolderView.corner(radii, for: corners)

        ibCharCountLabel.layer.masksToBounds = true
        ibCharCountLabel.layer.cornerRadius = 12.0

        ibHolderView.layer.borderWidth = 1.0
        ibHolderView.layer.borderColor = AppColors.whitishBorderColor.cgColor
    }

    func configure(data details: EditDescriptionDataSource?) {
        ibTextView.text = details?.dataSource
    }
}
