//
//  DataSelectCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/01/21.
//

import UIKit

class DataSelectCell: UICollectionViewCell {
    @IBOutlet weak var ibDataLabel: UILabel!

    var selectedData: [String]?
    var data: String? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.borderWidth = 1.0
        layer.borderColor = AppColors.whitishBorderColor.cgColor
    }

    private func updateUI() {
        guard let selectedData = selectedData, let data = data else { return }

        ibDataLabel.text = data

        backgroundColor = selectedData.contains(data) ? AppColors.darkSlateColor : .clear
    }
}
