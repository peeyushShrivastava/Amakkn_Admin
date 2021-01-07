//
//  EditPriceTextFieldCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 07/01/21.
//

import UIKit

class EditPriceTextFieldCell: UICollectionViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibHolderView: UIView!
    @IBOutlet weak var ibTextField: UITextField!

    var salePrice: [SalesPrice]?
    var rentPrice: [PriceRent]?
    var param: Price? {
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
        ibTitleLabel.text = "\(param?.name ?? "")"

        if let salePrice = salePrice {
            let _ = salePrice.map { salePrice -> Bool in
                if salePrice.priceID == param?.key {
                    ibTextField.text = salePrice.price
                }
                return false
            }
        } else {
            let _ = rentPrice?.map { rentPrice -> Bool in
                if rentPrice.key == param?.key {
                    ibTextField.text = rentPrice.value
                }
                return false
            }
        }
    }
}
