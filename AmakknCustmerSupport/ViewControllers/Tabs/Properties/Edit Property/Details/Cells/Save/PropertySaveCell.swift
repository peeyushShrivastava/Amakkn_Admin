//
//  PropertySaveCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 08/01/21.
//

import UIKit

// MARK: - PropertySave Delegate
protocol PropertySaveDelegate {
    func propertyDidSaved()
}

class PropertySaveCell: UICollectionViewCell, ConfigurableCell {

    var delegate: PropertySaveDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(data details: String?) { }
}

// MARK: - Button Action
extension PropertySaveCell {
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        delegate?.propertyDidSaved()
    }
}
