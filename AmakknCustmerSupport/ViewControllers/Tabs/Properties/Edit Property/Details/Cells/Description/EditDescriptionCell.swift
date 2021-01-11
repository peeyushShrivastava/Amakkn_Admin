//
//  EditDescriptionCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/01/21.
//

import UIKit

// MARK: - EditDescription Delegate
protocol EditDescriptionDelegate {
    func scrollCell(for tag: Int)
    func update(_ description: String?, completion: @escaping() -> Void)
}

class EditDescriptionCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleHolderView: UIView!
    @IBOutlet weak var ibCharCountLabel: UILabel!
    @IBOutlet weak var ibTextView: UITextView!
    @IBOutlet weak var ibHolderView: UIView!

    let maxTextCount = 500
    var delegate: EditDescriptionDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        updateUI()
    }

    private func updateUI() {
        let corners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let radii: CGFloat = 8.0

        ibTitleHolderView.corner(radii, for: corners)

        ibCharCountLabel.layer.masksToBounds = true
        ibCharCountLabel.layer.cornerRadius = 12.0

        ibHolderView.layer.borderWidth = 1.0
        ibHolderView.layer.borderColor = AppColors.whitishBorderColor.cgColor
    }

    func configure(data details: EditDescriptionDataSource?) {
        ibTextView.text = details?.dataSource

        updateCount()
        ibTextView.inputAccessoryView = getAccessoryView()
    }

    private func updateCount() {
        let currentCont = ibTextView.text.count

        ibCharCountLabel.text = "\(maxTextCount-currentCont) characters remaining"
    }

    func getAccessoryView() -> UIView {
        guard let accessoryView = Bundle.main.loadNibNamed("EditAccessoryView", owner: self, options: nil)?.last as? EditAccessoryView else { return UIView() }

        accessoryView.delegate = self

        return accessoryView
    }
}

// MARK: - UITextView Delegate
extension EditDescriptionCell: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        delegate?.scrollCell(for: self.tag)

        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let string = textView.text, let textRange = Range(range, in: string) {
            let updatedText = string.replacingCharacters(in: textRange, with: text)

            updateCount()
            delegate?.update(updatedText) {
                textView.becomeFirstResponder()
            }

            return updatedText.count >= maxTextCount
        }

        return true
    }
}

// MARK: - EditAccessoryView Delegate
extension EditDescriptionCell: EditAccessoryViewDelegate {
    func didTappedDone() {
        ibTextView.resignFirstResponder()
    }
}
