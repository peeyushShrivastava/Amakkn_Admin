//
//  UserFilterDataCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/10/20.
//

import UIKit



class UserFilterDataCell: UITableViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibValueTextField: UITextField!

    var delegate: UserFilterDataDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func update(_ title: String?, with tag: Int) {
        ibTitleLabel.text = title

        ibValueTextField.tag = tag
    }

    func updateValue(_ text: String?) {
        ibValueTextField.text = text
    }
}

// MARK: - UITextField Delegate
extension UserFilterDataCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

//            delegate?.textFieldDidChange(updatedText, for: ibTitleLabel.text)
        }

        return true
    }
}
