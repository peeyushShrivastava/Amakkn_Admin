//
//  StatsDetailsDataCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/10/21.
//

import UIKit

class StatsDetailsDataCell: UITableViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibValueLabel: UILabel!

    var model: StatsDataTypeModel? {
        didSet {
            updateUI()
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

    private func updateUI() {
        ibTitleLabel.text = model?.key
        ibValueLabel.text = model?.value
    }
}
