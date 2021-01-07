//
//  EditFeaturesCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 04/01/21.
//

import UIKit

// MARK: - EditFeature Delegate
protocol EditFeaturesDelegate {
    func plusDidTapped(for key: String?)
    func minusDidTapped(for key: String?)
}

class EditFeaturesCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleHolderView: UIView!
    @IBOutlet weak var ibTableView: UITableView!

    var featureModel: EditFeaturesDataSource?
    var delegate: EditFeaturesDelegate?

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
        ibTableView.register(UINib(nibName: "FeatureCell", bundle: nil), forCellReuseIdentifier: "featureCellID")
    }

    func configure(data details: EditFeaturesDataSource?) {
        featureModel = details

        DispatchQueue.main.async { [weak self] in
            self?.ibTableView.reloadData()
        }
    }
}

// MARK: - UITableView Delegate / DataSource
extension EditFeaturesCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return featureModel?.params?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "featureCellID") as? FeatureCell else { return UITableViewCell() }

        cell.dataSource = featureModel?.dataSource
        cell.param = featureModel?.params?[indexPath.row]
        cell.delegate = self

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
}

// MARK: - EditFeatures Delegate
extension EditFeaturesCell: FeatureCellDelegate {
    func plusDidTapped(for key: String?) {
        delegate?.plusDidTapped(for: key)
    }

    func minusDidTapped(for key: String?) {
        delegate?.minusDidTapped(for: key)
    }
}
