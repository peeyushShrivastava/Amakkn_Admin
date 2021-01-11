//
//  EditPlansCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/01/21.
//

import UIKit

class EditPlansCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleLabel: UILabel!

    var count = 0

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(data details: EditPlansDataSource?) {
        count = details?.dataSource?.filter({ $0 != "" }).count ?? 0

        ibTitleLabel.text = "Plans (\(count))"
    }
}
