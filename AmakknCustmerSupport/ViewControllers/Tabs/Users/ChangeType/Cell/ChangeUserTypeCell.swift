//
//  ChangeUserTypeCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 03/10/21.
//

import UIKit

class ChangeUserTypeCell: UITableViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibTick: UIImageView!

    var data: (model: ChangeTypeModel?, userType: UserType)? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    private func updateUI() {
        ibTitleLabel.text = data?.model?.title

        ibTick.isHidden = (data?.model?.type != data?.userType)
    }
}
