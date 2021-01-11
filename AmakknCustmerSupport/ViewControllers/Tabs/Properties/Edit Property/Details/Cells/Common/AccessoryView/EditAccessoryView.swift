//
//  EditAccessoryView.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 11/01/21.
//

import UIKit

// MARK: - EditAccessoryView Delegate
protocol EditAccessoryViewDelegate {
    func didTappedDone()
}

class EditAccessoryView: UIView {
    var delegate: EditAccessoryViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        delegate?.didTappedDone()
    }
}
