//
//  GalleryImageCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import UIKit

class GalleryImageCell: UICollectionViewCell {
    @IBOutlet weak var ibImageView: UIImageView!
    @IBOutlet weak var ibSelectIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.masksToBounds = true
        layer.borderWidth = 1.0
        layer.borderColor = AppColors.borderColor?.cgColor
    }
}
