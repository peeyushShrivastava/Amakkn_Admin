//
//  EditPriceTextFieldCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 07/01/21.
//

import UIKit

// MARK: - EditPriceTextField Delegate
protocol EditPriceTextFieldDelegate {
    func slideCell()
    func update(price data: String?, with key: String?, completion: @escaping() -> Void)
}

class EditPriceTextFieldCell: UICollectionViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibHolderView: UIView!
    @IBOutlet weak var ibTextField: UITextField!

    var delegate: EditPriceTextFieldDelegate?

    var defaultPriceType: String?
    var salePrice: String?
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

        if defaultPriceType == "0" {
            ibTextField.text = salePrice
        } else {
            let _ = rentPrice?.map { rentPrice -> Bool in
                if rentPrice.key == param?.key {
                    ibTextField.text = rentPrice.value
                }
                return false
            }
        }

        ibTextField.inputAccessoryView = getAccessoryView()
    }

    func getAccessoryView() -> UIView {
        guard let accessoryView = Bundle.main.loadNibNamed("EditAccessoryView", owner: self, options: nil)?.last as? EditAccessoryView else { return UIView() }

        accessoryView.delegate = self

        return accessoryView
    }
}

// MARK: - UITextField Delegate
extension EditPriceTextFieldCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.slideCell()

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            delegate?.update(price: updatedText, with: param?.key) {
                textField.becomeFirstResponder()
            }
        }

        return true
    }
}

// MARK: - EditAccessoryView Delegate
extension EditPriceTextFieldCell: EditAccessoryViewDelegate {
    func didTappedDone() {
        ibTextField.resignFirstResponder()
    }
}
