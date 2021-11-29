//
//  SubjectCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 14/10/20.
//

import UIKit

class SubjectCell: UITableViewCell {
    @IBOutlet weak var ibSubjectLabel: UILabel!

    var subject: String? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    private func updateUI() {
        ibSubjectLabel.text = subject
    }
}
