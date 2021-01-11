//
//  EditAmenitiesCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/01/21.
//

import UIKit

// MARK: - EditAmenity Delegate
protocol EditAmenityDelegate {
    func cellDid(select: Bool, amenity: Amenity?)
}

class EditAmenitiesCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleHolderView: UIView!
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibCollectionView: UICollectionView!

    private var dataSource: EditAmenitiesDataSource?
    private var selectedData: [String]?
    var delegate: EditAmenityDelegate?

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
        ibCollectionView.register(UINib(nibName: "DataSelectCell", bundle: nil), forCellWithReuseIdentifier: "dataSelectCellID")
    }

    private func getAmenity(at index: Int) -> Amenity? {
        let amenity = dataSource?.params?[index]

        return Amenity(key: amenity?.key, name: amenity?.name)
    }

    func configure(data details: EditAmenitiesDataSource?) {
        dataSource = details

        selectedData = dataSource?.dataSource?.compactMap({ $0.name })

        DispatchQueue.main.async { [weak self] in
            self?.ibCollectionView.reloadData()
        }
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension EditAmenitiesCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.params?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dataSelectCellID", for: indexPath) as? DataSelectCell else { return UICollectionViewCell() }

        cell.selectedData = selectedData
        cell.data = dataSource?.params?[indexPath.row].name

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        cell.backgroundColor = (cell.backgroundColor == .clear) ? AppColors.darkSlateColor : .clear

        delegate?.cellDid(select: (cell.backgroundColor != .clear), amenity: getAmenity(at: indexPath.row))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width-40.0)/2

        return .init(width: width, height: 50.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 5.0, bottom: 10.0, right: 5.0)
    }
}
