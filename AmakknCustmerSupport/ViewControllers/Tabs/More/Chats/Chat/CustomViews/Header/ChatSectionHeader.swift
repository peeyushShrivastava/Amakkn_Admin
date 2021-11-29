//
//  ChatSectionHeader.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import UIKit

class ChatSectionHeader: UICollectionReusableView {
    @IBOutlet weak var ibHeaderTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func update(title: String?) {
        guard let title = title else { return }

        ibHeaderTitle.text = "\(title)"
    }
}
