//
//  EditPropertyTextFieldCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/01/21.
//

import UIKit

// MARK: - EditPropertyTextField Delegate
protocol EditPropertyTextFieldDelegate {
    func didShowKeyboard()
    func update(details data: String?, with key: String?, completion: @escaping() -> Void)
}

class EditPropertyTextFieldCell: UICollectionViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibHolderView: UIView!
    @IBOutlet weak var ibTextField: UITextField!
    @IBOutlet weak var icArrowDown: UIImageView!

    var delegate: EditPropertyTextFieldDelegate?

    var selectedData: [Feature]?
    var dataSource: Feature? {
        didSet {
            updateTitle()
            updateValue()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        ibHolderView.layer.borderWidth = 1.0
        ibHolderView.layer.borderColor = AppColors.whitishBorderColor.cgColor
    }

    private func updateTitle() {
        guard let unit = dataSource?.unit, unit != "--" else { ibTitleLabel.text = dataSource?.name; return }

        ibTitleLabel.text = "\(dataSource?.name ?? "") (\(unit))"
        ibTextField.inputAccessoryView = getAccessoryView()
    }

    private func updateValue() {
        guard let key = dataSource?.key else { return }
        guard let index = selectedData?.firstIndex(where: { $0.key == key }) else { icArrowDown.isHidden = true; ibTextField.text = nil; return }

        ibTextField.text = selectedData?[index].value

        icArrowDown.isHidden = (key != "6")
    }

    func getAccessoryView() -> UIView {
        guard let accessoryView = Bundle.main.loadNibNamed("EditAccessoryView", owner: self, options: nil)?.last as? EditAccessoryView else { return UIView() }

        accessoryView.delegate = self

        return accessoryView
    }
}

// MARK: - UITextFeild Delegate
extension EditPropertyTextFieldCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return (dataSource?.key != "6")
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.didShowKeyboard()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            delegate?.update(details: updatedText, with: dataSource?.key) {
                textField.becomeFirstResponder()
            }
        }

        return true
    }
}

// MARK: - EditAccessoryView Delegate
extension EditPropertyTextFieldCell: EditAccessoryViewDelegate {
    func didTappedDone() {
        ibTextField.resignFirstResponder()
    }
}
