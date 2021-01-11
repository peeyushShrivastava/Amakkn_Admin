//
//  FeatureCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 04/01/21.
//

import UIKit

// MARK: - FeatureCell Delegate
protocol FeatureCellDelegate {
    func plusDidTapped(for key: String?)
    func minusDidTapped(for key: String?)
}

class FeatureCell: UITableViewCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibMinusButton: UIButton!
    @IBOutlet weak var ibPlusButton: UIButton!
    @IBOutlet weak var ibCenterView: UIView!
    @IBOutlet weak var ibValueLabel: UILabel!

    var delegate: FeatureCellDelegate?

    var dataSource: [Room]?
    var param: Room? {
        didSet {
            updateData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        updateUI()
    }

    private func updateUI() {
        ibMinusButton.layer.borderWidth = 1.0
        ibMinusButton.layer.borderColor = AppColors.whitishBorderColor.cgColor

        ibPlusButton.layer.borderWidth = 1.0
        ibPlusButton.layer.borderColor = AppColors.whitishBorderColor.cgColor

        ibCenterView.layer.borderWidth = 1.0
        ibCenterView.layer.borderColor = AppColors.whitishBorderColor.cgColor

        ibPlusButton.showsTouchWhenHighlighted = true
        ibMinusButton.showsTouchWhenHighlighted = true
    }

    private func updateData() {
        ibTitleLabel.text = param?.name

        let _ = dataSource?.map({ data -> Bool in
            if data.key == param?.key {
                ibValueLabel.text = data.value
            }
            return false
        })
    }
}

// MARK: - Button Actions
extension FeatureCell {
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        guard let key = param?.key, let index = dataSource?.firstIndex(where: { $0.key == key }) else { return }
        guard let value = dataSource?[index].value, let intValue = Int(value), intValue > 0 else { return }

        ibValueLabel.text = "\(intValue - 1)"

        delegate?.minusDidTapped(for: param?.key)
    }

    @IBAction func plusButtonTapped(_ sender: UIButton) {
        guard let key = param?.key, let index = dataSource?.firstIndex(where: { $0.key == key }) else { return }
        guard let value = dataSource?[index].value, let intValue = Int(value) else { return }

        ibValueLabel.text = "\(intValue + 1)"

        delegate?.plusDidTapped(for: param?.key)
    }
}
