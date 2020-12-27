//
//  DescriptionCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 26/10/20.
//

import UIKit

class DescriptionCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibDescriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(data desc: String?) {
        ibDescriptionLabel.text = desc
    }
}
