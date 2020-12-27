//
//  ResolveComplaintsCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 24/12/20.
//

import UIKit

// MARK: - Resolve Delegate
protocol ResolveDelegate {
    func resolveAllComplaints()
}

class ResolveComplaintsCell: UITableViewCell {

    var delegate: ResolveDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func resolveButtonTapped(_ sender: UIButton) {
        delegate?.resolveAllComplaints()
    }
}
