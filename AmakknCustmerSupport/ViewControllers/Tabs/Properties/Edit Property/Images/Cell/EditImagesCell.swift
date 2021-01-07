//
//  EditImagesCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 04/01/21.
//

import UIKit

// MARK: - Edit Images delegate
protocol EditImagesDelegate {
    func deleteDidTapped()
    func makeDefault()
}

class EditImagesCell: UICollectionViewCell {
    @IBOutlet weak var ibImageView: UIImageView!
    @IBOutlet weak var ibDefaultButton: UIButton!
    @IBOutlet weak var ibTextView: UITextView!
    @IBOutlet weak var ibPlaceHolder: UILabel!

    var delegate: EditImagesDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func updateUI(with image: String?) {
        guard let imageURLStr = image else { return }
        guard let imageURL = URL(string: imageURLStr) else { return }

        ibImageView.sd_setImage(with: imageURL, placeholderImage: UIImage())
    }
}

// MARK: - Button Actions
extension EditImagesCell {
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        delegate?.deleteDidTapped()
    }

    @IBAction func defaultButtonTapped(_ sender: UIButton) {
        delegate?.makeDefault()
    }
}
