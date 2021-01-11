//
//  EditImageCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 07/01/21.
//

import UIKit

class EditImageCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleLabel: UILabel!

    var count = 0

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(data details: EditImagesDataSource?) {
        count = details?.dataSource?.filter({ $0 != "" }).count ?? 0

        ibTitleLabel.text = "Images (\(count))"
    }
}
