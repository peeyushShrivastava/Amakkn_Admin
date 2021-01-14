//
//  UserFilterDataHeaderView.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 14/01/21.
//

import UIKit

// MARK: - UserFilterData Delegate
protocol UserFilterDataDelegate {
    func textFieldDidChange(_ text: String?, for filterData: String?, at index: Int)
}

class UserFilterDataHeaderView: UIView {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibSelectedTitleLabel: UILabel!
    @IBOutlet weak var ibSelectedDataTextField: UITextField!
    @IBOutlet weak var ibIndicatorIcon: UIImageView!
    @IBOutlet weak var ibExpandButton: UIButton!
    @IBOutlet weak var ibBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var ibBottomHolderView: UIView!

    var delegate: UserFilterHeaderDelegate?
    var dataDelegate: UserFilterDataDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        ibBottomHeight.constant = 0.0
        ibBottomHolderView.isHidden = true
    }

    func update(_ title: String?, at section: Int) {
        ibTitleLabel.text = title

        ibExpandButton.tag = section
    }

    func updateValue(for title: String?, _ text: String?) {
        guard title?.count ?? 0 > 0 else { return }

        ibBottomHeight.constant = 45.0
        ibBottomHolderView.isHidden = false

        ibSelectedTitleLabel.text = title
        ibSelectedDataTextField.text = text
    }
}

// MARK: - Button Action
extension UserFilterDataHeaderView {
    @IBAction func expandButtonTapped(_ sender: UIButton) {
        delegate?.expandCell(at: sender.tag)

        if let buttonImg = ibIndicatorIcon.image?.pngData(), let img = UIImage(named: "icArrowDown")?.pngData(), buttonImg == img {
            ibIndicatorIcon.image = UIImage(named: "icArrowUp")
        } else {
            ibIndicatorIcon.image = UIImage(named: "icArrowDown")
        }
    }
}

// MARK: - UITextField Delegate
extension UserFilterDataHeaderView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string != "\n" else { textField.resignFirstResponder(); return true }
        guard let text = textField.text, let textRange = Range(range, in: text) else { return false }

        let updatedString = text.replacingCharacters(in: textRange, with: string)
        dataDelegate?.textFieldDidChange(updatedString, for: ibSelectedTitleLabel.text, at: ibExpandButton.tag)

        return true
    }
}
