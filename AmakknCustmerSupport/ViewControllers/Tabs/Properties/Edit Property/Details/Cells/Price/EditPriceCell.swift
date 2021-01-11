//
//  EditPriceCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/01/21.
//

import UIKit

// MARK: - EditPrice Delegate
protocol EditPriceDelegate {
    func slideCell(for tag: Int)
    func update(price: String?, with key: String?, for tag: Int, completion: @escaping () -> Void)
}

class EditPriceCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibTitleHolderView: UIView!
    @IBOutlet weak var ibCollectionView: UICollectionView!

    var delegate: EditPriceDelegate?

    private var dataSource: EditPriceDataSource?
    private var selectedData: [String]?

    override func awakeFromNib() {
        super.awakeFromNib()

        updateUI()
        registerCell()
    }

    private func updateUI() {
        let corners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let radii: CGFloat = 8.0

        ibTitleHolderView.corner(radii, for: corners)
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "EditPriceTextFieldCell", bundle: nil), forCellWithReuseIdentifier: "priceTextFieldCellID")
    }

    func configure(data details: EditPriceDataSource?) {
        dataSource = details

        selectedData = dataSource?.params?.compactMap({ $0.name })
        ibTitleLabel.text = (dataSource?.defaultPriceType == "0") ? "Sale Price" : "Rent Price"

        DispatchQueue.main.async { [weak self] in
            self?.ibCollectionView.reloadData()
        }
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension EditPriceCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.params?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "priceTextFieldCellID", for: indexPath) as? EditPriceTextFieldCell else { return UICollectionViewCell() }

        cell.defaultPriceType = dataSource?.defaultPriceType
        cell.salePrice = dataSource?.salePrice
        cell.rentPrice = dataSource?.rentPrice
        cell.param = dataSource?.params?[indexPath.row]
        cell.delegate = self

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width-40.0)

        return .init(width: width, height: 85.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 5.0, bottom: 10.0, right: 5.0)
    }
}

// MARK: - EditPriceTextField Delegate
extension EditPriceCell: EditPriceTextFieldDelegate {
    func slideCell() {
        delegate?.slideCell(for: self.tag)
    }

    func update(price data: String?, with key: String?, completion: @escaping () -> Void) {
        delegate?.update(price: data, with: key, for: self.tag, completion: { completion() })
    }
}
