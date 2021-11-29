//
//  UserDetailsHeaderView.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 22/10/20.
//

import UIKit

// MARK: - UserFilterHeader Delegate
protocol UserDetailsHeaderDelegate {
    func expandCell(at section: Int, with title: String?)
}

class UserDetailsHeaderView: UIView {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibIndicatorIcon: UIImageView!
    @IBOutlet weak var ibExpandButton: UIButton!

    var delegate: UserDetailsHeaderDelegate?

    func update(_ title: String?, at section: Int) {
        ibTitleLabel.text = title

        ibExpandButton.tag = section

        let icon = (title == UserDetailsType.changeUserType.rawValue) ? UIImage(named: "icNextIcon") : UIImage(named: "icDropDownIcon")
        ibIndicatorIcon.image = icon
    }

    func updateUI(for isExpanded: Bool) {
        let corners: CACornerMask = isExpanded ? [.layerMaxXMinYCorner, .layerMinXMinYCorner] : [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        let radii: CGFloat = 8.0

        self.corner(radii, for: corners)
    }

    @IBAction func expandButtonTapped(_ sender: UIButton) {
        delegate?.expandCell(at: sender.tag, with: ibTitleLabel.text)
    }
}
