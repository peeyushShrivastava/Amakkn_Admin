//
//  UserDetailsDataCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 22/10/20.
//

import UIKit

class UserDetailsDataCell: UITableViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibValueLabel: UILabel!

    var model: UserDataTypeModel? {
        didSet {
            updateData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateUI(for isLastCell: Bool) {
        let corners: CACornerMask = isLastCell ? [.layerMaxXMaxYCorner, .layerMinXMaxYCorner] : []
        let radii: CGFloat = isLastCell ? 8.0 : 0.0

        self.corner(radii, for: corners)
    }

    private func updateData() {
        ibTitleLabel.text = model?.key

        if let value = model?.value {
            ibValueLabel.text = value.isEmpty ? "--" : value
        }
    }
}
