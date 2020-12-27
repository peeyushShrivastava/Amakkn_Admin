//
//  TitleFloorPlanCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 26/10/20.
//

import UIKit

class TitleFloorPlanCell: UICollectionViewCell {
    @IBOutlet weak var ibPlanLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.masksToBounds = true
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
        layer.borderColor = AppColors.borderColor?.cgColor
    }
}
