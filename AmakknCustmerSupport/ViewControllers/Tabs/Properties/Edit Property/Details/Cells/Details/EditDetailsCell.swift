//
//  EditDetailsCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/01/21.
//

import UIKit

// MARK: - EditDetails Delegate
protocol EditDetailsDelegate {
    func didShowKeyboard(for tag: Int)
    func update(frontispiece: Feature?, for tag: Int)
    func update(details: String?, with key: String?, for tag: Int, completion: @escaping () -> Void)
}

class EditDetailsCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleHolderView: UIView!
    @IBOutlet weak var ibCollectionView: UICollectionView!

    var delegate: EditDetailsDelegate?

    var dataSource: EditPropertyDetailsDataSource?

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
        dataSource = details

        DispatchQueue.main.async { [weak self] in
            self?.ibCollectionView.reloadData()
        }
    }

    private func getCellCount() -> Int {
        if let frontispeice = dataSource?.frontispeice {
            dataSource?.params?.append(frontispeice)
            return dataSource?.params?.count ?? 0
        }

        return dataSource?.params?.count ?? 0
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension EditDetailsCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getCellCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if dataSource?.params?[indexPath.row].key == "7" {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "editFrontIsPieceCellID", for: indexPath) as? EditFrontIsPieceCell else { return UICollectionViewCell() }

            cell.param = dataSource?.frontispeice
            cell.selectedData = dataSource?.dataSource?.filter({ $0.key == "7" }).first
            cell.delegate = self

            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFieldCellID", for: indexPath) as? EditPropertyTextFieldCell else { return UICollectionViewCell() }

        cell.selectedData = dataSource?.dataSource
        cell.dataSource = dataSource?.params?[indexPath.row]
        cell.delegate = self

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.width-40.0)

        if dataSource?.params?[indexPath.row].key == "7" {
            return .init(width: width, height: 220.0)
        }

        return .init(width: width, height: 85.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 5.0, bottom: 10.0, right: 5.0)
    }
}

// MARK: - EditFrontispeice Delegate
extension EditDetailsCell: EditFrontispeiceDelegate {
    func cellDid(frontispeice: Feature?) {
        delegate?.update(frontispiece: frontispeice, for: self.tag)
    }
}

// MARK: - EditPropertyTextField Delegate
extension EditDetailsCell: EditPropertyTextFieldDelegate {
    func didShowKeyboard() {
        delegate?.didShowKeyboard(for: self.tag)
    }

    func update(details data: String?, with key: String?, completion: @escaping () -> Void) {
        delegate?.update(details: data, with: key, for: self.tag) { completion() }
    }
}
