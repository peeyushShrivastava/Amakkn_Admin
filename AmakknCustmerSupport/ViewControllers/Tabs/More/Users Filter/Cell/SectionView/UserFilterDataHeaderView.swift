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

        updateAccessoryViews(for: title)
    }

    private func updateAccessoryViews(for title: String?) {
        guard let title = title else { return }
        
        if title == "Last Added property" || title == "Created Date" || title == "Last Opened" || title == "Updated Date" {
            ibSelectedDataTextField.inputAccessoryView = getInputAccessoryView()
            ibSelectedDataTextField.inputView = getAccessoryView()
        }
        
        if title == "Property Id" || title == "User Id" || title == "Type Number" || title == "Views" {
            ibSelectedDataTextField.keyboardType = .numberPad
            ibSelectedDataTextField.inputAccessoryView = getInputAccessoryView()
        } else {
            ibSelectedDataTextField.keyboardType = .asciiCapable
        }
    }

    private func getAccessoryView() -> UIView {
        guard let accessoryView = Bundle.main.loadNibNamed("AccessoryDatePickerView", owner: self, options: nil)?.last as? AccessoryDatePickerView else { return UIView() }

        accessoryView.delegate = self

        return accessoryView
    }
    
    func getInputAccessoryView() -> UIView {
        guard let accessoryView = Bundle.main.loadNibNamed("EditAccessoryView", owner: self, options: nil)?.last as? EditAccessoryView else { return UIView() }

        accessoryView.delegate = self

        return accessoryView
    }
}

// MARK: - Button Action
extension UserFilterDataHeaderView {
    @IBAction func expandButtonTapped(_ sender: UIButton) {
        endEditing(true)
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

// MARK: - DatePickerView Delegate
extension UserFilterDataHeaderView: DatePickerViewDelegate {
    func didValueChanged(_ date: Date) {
        updateDate(date)
    }

    private func updateDate(_ date: Date) {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat =  "dd/MM/yyyy"

        ibSelectedDataTextField.text = dateFormatter.string(from: date)
        dataDelegate?.textFieldDidChange(ibSelectedDataTextField.text, for: ibSelectedTitleLabel.text, at: ibExpandButton.tag)
    }
}

// MARK: - InputAccessoryView Delegate
extension UserFilterDataHeaderView: EditAccessoryViewDelegate {
    func didTappedDone() {
        ibSelectedDataTextField.resignFirstResponder()
    }
}
