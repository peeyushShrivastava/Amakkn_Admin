//
//  EditImagesCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 04/01/21.
//

import UIKit

// MARK: - Edit Images delegate
protocol EditImagesDelegate {
    func keyboardDidShow(at index: Int)
    func deleteDidTapped(at index: Int)
    func makeDefault(at index: Int)
    func update(_ photoTitle: String?, at index: Int)
}

class EditImagesCell: UICollectionViewCell {
    @IBOutlet weak var ibImageView: UIImageView!
    @IBOutlet weak var ibDefaultButton: UIButton!
    @IBOutlet weak var ibTextView: UITextView!
    @IBOutlet weak var ibPlaceHolder: UILabel!
    @IBOutlet weak var ibHolderView: UIView!

    let maxCharCount = 50
    var delegate: EditImagesDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func updateUI(with image: String?, isPlans: Bool) {
        ibDefaultButton.isHidden = isPlans
        ibHolderView.isHidden = isPlans

        let imageData = image?.components(separatedBy: "#")
        guard let imageURLStr = imageData?.first else { return }
        guard let imageURL = URL(string: imageURLStr) else { return }

        ibImageView.sd_setImage(with: imageURL, placeholderImage: UIImage())
        ibTextView.text = imageData?.last
        ibPlaceHolder.isHidden = (imageData?.last != "")

        let title = (self.tag == 0) ? "   Default Image   " : "   Make Default Image   "
        ibDefaultButton.setTitle(title, for: .normal)
        ibDefaultButton.backgroundColor = (self.tag == 0) ? AppColors.viewBGColor : AppColors.darkSlateColor
        ibDefaultButton.isUserInteractionEnabled = (self.tag != 0)
    }
}

// MARK: - Button Actions
extension EditImagesCell {
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        delegate?.deleteDidTapped(at: self.tag)
    }

    @IBAction func defaultButtonTapped(_ sender: UIButton) {
        delegate?.makeDefault(at: self.tag)
    }
}

// MARK: - UITextView Delegate
extension EditImagesCell: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        delegate?.keyboardDidShow(at: tag)
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else {
            delegate?.update(textView.text, at: tag)
            textView.resignFirstResponder()
            return false
        }

        if let string = textView.text, let textRange = Range(range, in: string) {
            let updatedText = string.replacingCharacters(in: textRange, with: text)

            ibPlaceHolder.isHidden = (updatedText.count != 0)

            return updatedText.count <= maxCharCount
        }

        return true
    }
}
