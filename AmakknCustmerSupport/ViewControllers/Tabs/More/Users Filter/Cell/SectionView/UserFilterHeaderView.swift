//
//  UserFilterHeaderView.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/10/20.
//

import UIKit

// MARK: - UserFilterHeader Delegate
protocol UserFilterHeaderDelegate {
    func expandCell(at section: Int)
}

class UserFilterHeaderView: UIView {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibSelectedDataLabel: UILabel!
    @IBOutlet weak var ibIndicatorIcon: UIImageView!
    @IBOutlet weak var ibExpandButton: UIButton!

    var delegate: UserFilterHeaderDelegate?

    func update(_ title: String?, at section: Int) {
        ibTitleLabel.text = title

        ibExpandButton.tag = section
    }

    func updateValue(_ text: String?) {
        ibSelectedDataLabel.text = text
    }

    @IBAction func expandButtonTapped(_ sender: UIButton) {
        delegate?.expandCell(at: sender.tag)

        if let buttonImg = ibIndicatorIcon.image?.pngData(), let img = UIImage(named: "icArrowDown")?.pngData(), buttonImg == img {
            ibIndicatorIcon.image = UIImage(named: "icArrowUp")
        } else {
            ibIndicatorIcon.image = UIImage(named: "icArrowDown")
        }
    }
}
