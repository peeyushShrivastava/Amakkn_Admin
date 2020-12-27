//
//  PropertyInfoView.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import UIKit

// MARK: - Proeprty Info Delegate
protocol PropertyInfoDelegate {
    func infoDidTapped()
}

class PropertyInfoView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ibPropertyImageView: UIImageView!
    @IBOutlet weak var ibPropertyTypelabel: UILabel!
    @IBOutlet weak var ibPropertyPriceLabel: UILabel!
    @IBOutlet weak var ibPropertyAddressLabel: UILabel!

    var delegate: PropertyInfoDelegate?

    // MARK: Init Method
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        addContentView()
    }

    // MARK: - Init Content View
    private func addContentView() {
        Bundle.main.loadNibNamed("PropertyInfoView", owner: self, options: nil)
        addSubview(contentView)

        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = .clear

        updateUI()
    }

    private func updateUI() {
        ibPropertyImageView.layer.masksToBounds = true
        ibPropertyImageView.layer.cornerRadius = 4.0
        ibPropertyImageView.contentMode = .scaleAspectFill
    }

    func update(with dataSource: (imageURL: String?, type: String?, price: String?, address: String?, placeHolderStr: String)?) {
        ibPropertyTypelabel.text = "  \(dataSource?.type ?? "")  "
        ibPropertyPriceLabel.text = dataSource?.price?.amkFormat
        ibPropertyAddressLabel.text = dataSource?.address
        ibPropertyImageView.sd_setImage(with: getImageURL(from: dataSource?.imageURL), placeholderImage: UIImage(named: dataSource?.placeHolderStr ?? ""))
    }

    private func getImageURL(from data: String?) -> URL? {
        guard let data = data else { return nil }

        let imageList = data.components(separatedBy: ",")

        return URL(string: imageList.first ?? "")
    }
}

// MARK: - Button Actions
extension PropertyInfoView {
    @IBAction func propertyButtonTapped(_ sender: UIButton) {
        delegate?.infoDidTapped()
    }
}
