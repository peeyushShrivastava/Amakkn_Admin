//
//  AbuseCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 16/12/20.
//

import UIKit

class AbuseCell: UICollectionViewCell {
    @IBOutlet weak var ibDescriptionLabel: UILabel!
    @IBOutlet weak var ibDateLabel: UILabel!

    var dataSource: AbuseModel? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.masksToBounds = true
        layer.cornerRadius = 8.0
        layer.borderColor = AppColors.borderColor?.cgColor
        layer.borderWidth = 1.0
    }

    private func updateUI() {
        ibDescriptionLabel.text = dataSource?.description
        ibDateLabel.text = dataSource?.updatedAt //getFormatedDate()
    }

    private func getFormatedDate() -> String? {
        guard let dateStr = dataSource?.updatedAt else { return nil }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"

        guard let date = df.date(from: dateStr) else { return nil }
        df.dateFormat = "MMM dd yyyy, HH:mm"

        return df.string(from: date)
    }
}
