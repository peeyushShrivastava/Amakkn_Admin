//
//  EditDetailsCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/01/21.
//

import UIKit

class EditDetailsCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleHolderView: UIView!
    @IBOutlet weak var ibCollectionView: UICollectionView!

    var dataSource: [Feature]?

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
        ibCollectionView.register(UINib(nibName: "EditPropertyTextFieldCell", bundle: nil), forCellWithReuseIdentifier: "textFieldCellID")
        ibCollectionView.register(UINib(nibName: "EditFrontIsPieceCell", bundle: nil), forCellWithReuseIdentifier: "editFrontIsPieceCellID")
    }

    func configure(data details: EditPropertyDetailsDataSource?) {
        dataSource = details?.dataSource

        DispatchQueue.main.async { [weak self] in
            self?.ibCollectionView.reloadData()
        }
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension EditDetailsCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if dataSource?[indexPath.row].key == "7" {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "editFrontIsPieceCellID", for: indexPath) as? EditFrontIsPieceCell else { return UICollectionViewCell() }

            cell.selectedData = dataSource?[indexPath.row]

            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCellID", for: indexPath) as? EditPropertyTextFieldCell else { return UICollectionViewCell() }

        cell.dataSource = dataSource?[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        delegate?.didSelect(floorPlans?[indexPath.item], at: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width-40.0)

        if dataSource?[indexPath.row].key == "7" {
            return .init(width: width, height: 220.0)
        }

        return .init(width: width, height: 85.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 5.0, bottom: 10.0, right: 5.0)
    }
}
