//
//  FloorPlansCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 26/10/20.
//

import UIKit

// MARK: - Floor Plan Delegate
protocol DetailsFloorPlanDelegate {
    func didSelect(_ floorPlan: String?, at index: Int)
}

class FloorPlansCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibCollectionView: UICollectionView!

    var floorPlans: [String]?
    var delegate: DetailsFloorPlanDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        ibCollectionView.register(UINib(nibName: "TitleFloorPlanCell", bundle: nil), forCellWithReuseIdentifier: "titleFloorPlanCellID")
    }

    func configure(data details: DetailsFloorPlansModel?) {
        floorPlans = details?.dataSource

        ibCollectionView.reloadData()
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension FloorPlansCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return floorPlans?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "titleFloorPlanCellID", for: indexPath) as? TitleFloorPlanCell else { return UICollectionViewCell() }

        cell.ibPlanLabel.text = "Plan \(indexPath.item+1)"

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(floorPlans?[indexPath.item], at: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width-40.0)/3

        return .init(width: width, height: 106.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 5.0, bottom: 10.0, right: 5.0)
    }
}
