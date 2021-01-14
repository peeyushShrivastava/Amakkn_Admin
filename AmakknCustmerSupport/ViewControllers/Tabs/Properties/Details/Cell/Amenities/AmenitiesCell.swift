//
//  AmenitiesCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 26/10/20.
//

import UIKit

class AmenitiesCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibCollectionView: UICollectionView!
    
    var dataSource: [Amenity]?

    override func awakeFromNib() {
        super.awakeFromNib()

        ibTitleLabel.text = "Amenities"

        registerCell()
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "AmenityDetailsCell", bundle: nil), forCellWithReuseIdentifier: "amenityDetailsCellID")
    }

    func configure(data details: DetailsAmenityModel?) {
        dataSource = details?.dataSource

        ibCollectionView.reloadData()
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension AmenitiesCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "amenityDetailsCellID", for: indexPath) as? AmenityDetailsCell else { return UICollectionViewCell() }

        cell.model = dataSource?[indexPath.item]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width-9)/2

        return .init(width: width, height: 44.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
}
