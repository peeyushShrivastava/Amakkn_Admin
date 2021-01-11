//
//  EditFrontIsPieceCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/01/21.
//

import UIKit

// MARK: - EditFrontispeice Delegate
protocol EditFrontispeiceDelegate {
    func cellDid(frontispeice: Feature?)
}

class EditFrontIsPieceCell: UICollectionViewCell {
    @IBOutlet weak var ibCollectionView: UICollectionView!

    private let frontispiece = ["North", "South", "East", "West", "North-East", "South-East", "South-West"]

    var delegate: EditFrontispeiceDelegate?

    var param: Feature?
    var selectedData: Feature? {
        didSet {
            ibCollectionView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        ibCollectionView.register(UINib(nibName: "DataSelectCell", bundle: nil), forCellWithReuseIdentifier: "dataSelectCellID")
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension EditFrontIsPieceCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frontispiece.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dataSelectCellID", for: indexPath) as? DataSelectCell else { return UICollectionViewCell() }

        cell.selectedData = [selectedData?.value ?? ""]
        cell.data = frontispiece[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard frontispiece[indexPath.item] != selectedData?.value else { return }

        param?.value = frontispiece[indexPath.item]
        delegate?.cellDid(frontispeice: param)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width-40.0)/3

        return .init(width: width, height: 50.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 5.0, bottom: 10.0, right: 5.0)
    }
}
