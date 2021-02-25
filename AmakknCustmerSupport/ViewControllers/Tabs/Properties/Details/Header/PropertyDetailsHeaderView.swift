//
//  PropertyDetailsHeaderView.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 27/10/20.
//

import UIKit

// MARK: - PropertyDetailsHeader Delegate
protocol PropertyDetailsHeaderDelegate {
    func didQRCodeTapped(with model: DetailsHeaderModel?)
    func showGallery(with images: [String]?)
}

// MARK: - Status Enum
enum ButtonStatus: Int {
    case on = 1
    case off = 2
}

class PropertyDetailsHeaderView: UICollectionReusableView {
    @IBOutlet weak var ibHeaderImageView: UIImageView!
    @IBOutlet weak var ibBlurView: UIVisualEffectView!
    @IBOutlet weak var ibPropertyTypeLabel: UILabel!
    @IBOutlet weak var ibLikesLabel: UILabel!
    @IBOutlet weak var ibPriceLabel: UILabel!
    @IBOutlet weak var ibPriceTypeLabel: UILabel!
    @IBOutlet weak var ibAddressLabel: UILabel!
    @IBOutlet weak var ibImageCount: UILabel!
    @IBOutlet weak var ibImageCountHolderView: UIView!

    @IBOutlet weak var ibQRCodeButton: UIButton!

    var delegate: PropertyDetailsHeaderDelegate?

    var model: DetailsHeaderModel? {
        didSet {
            updateDataSource()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        updateUI()
    }

    private func updateUI() {
        ibPropertyTypeLabel.layer.masksToBounds = true
        ibPropertyTypeLabel.layer.cornerRadius = 2.0
    }

    private func updateDataSource() {
        ibLikesLabel.text = "\(model?.likes ?? "0") Likes"
        ibPriceLabel.text = model?.propertyPrice?.amkFormat
        ibAddressLabel.text = model?.address
        ibPriceTypeLabel.text = model?.priceType?.isEmpty ?? true ? model?.priceType : "(per \(model?.priceType ?? ""))"

        ibPropertyTypeLabel.text = "\(model?.listedFor ?? "")"

        updatePhoto()
        updateQRCode()
        updatePhotoCunt()
    }

    private func updatePhoto() {
        guard let category = model?.category, let type = model?.propertyType else { return }

        let imgName = "PlaceHolder_\(category)_\(type)"
        let placeHolderImage = UIImage(named: imgName)

        ibHeaderImageView.image = placeHolderImage

        guard let imageURLStr = model?.photos?.first else { return }

        ibHeaderImageView.sd_setImage(with: URL(string: imageURLStr), placeholderImage: placeHolderImage)
        ibHeaderImageView.contentMode = .scaleAspectFill
    }

    private func updatePhotoCunt() {
        guard let photos = model?.photos, photos.count > 0 else { ibImageCountHolderView.isHidden = true; return }

        ibImageCountHolderView.isHidden = false
        ibImageCount.text = "1/\(photos.count)"
    }

    private func updateQRCode() {
        guard let propertyID = model?.propertyID else { return }

        let shareURLStr = "https://amakkn.com/#!/propertyDescription/\(propertyID)"
        let qrCodeImage = QRCodeGenerator.generateQRCode(for: shareURLStr)

        ibQRCodeButton.setImage(qrCodeImage, for: .normal)
    }
}

// MARK: - Button Actions
extension PropertyDetailsHeaderView {
    @IBAction func viewImages(_ sender: UIButton) {
        delegate?.showGallery(with: model?.photos)
    }

    @IBAction func qrCodeButtonTapped(_ sender: UIButton) {
        delegate?.didQRCodeTapped(with: model)
    }
}
