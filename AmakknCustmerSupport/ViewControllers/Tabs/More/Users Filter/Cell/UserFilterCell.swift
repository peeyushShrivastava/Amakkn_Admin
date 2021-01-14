//
//  UserFilterCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/10/20.
//

import UIKit

class UserFilterCell: UITableViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibTickIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func update(_ title: String?) {
        ibTitleLabel.text = title
    }
}
