//
//  EditPropertyTextFieldCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/01/21.
//

import UIKit

class EditPropertyTextFieldCell: UICollectionViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibHolderView: UIView!
    @IBOutlet weak var ibTextField: UITextField!
    @IBOutlet weak var icArrowDown: UIImageView!

    var dataSource: Feature? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        ibHolderView.layer.borderWidth = 1.0
        ibHolderView.layer.borderColor = AppColors.whitishBorderColor.cgColor
    }

    private func updateUI() {
        ibTextField.text = dataSource?.value

        guard let unit = dataSource?.unit, unit != "--" else { ibTitleLabel.text = dataSource?.name; return }

        ibTitleLabel.text = "\(dataSource?.name ?? "") (\(unit))"
    }
}
