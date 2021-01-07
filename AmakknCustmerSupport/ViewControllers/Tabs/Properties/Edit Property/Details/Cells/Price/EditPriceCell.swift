//
//  EditPriceCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/01/21.
//

import UIKit

class EditPriceCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleHolderView: UIView!
    @IBOutlet weak var ibCollectionView: UICollectionView!

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

        cell.salePrice = dataSource?.salePrice
        cell.rentPrice = dataSource?.rentPrice
        cell.param = dataSource?.params?[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        delegate?.didSelect(floorPlans?[indexPath.item], at: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width-40.0)

        return .init(width: width, height: 85.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 5.0, bottom: 10.0, right: 5.0)
    }
}
