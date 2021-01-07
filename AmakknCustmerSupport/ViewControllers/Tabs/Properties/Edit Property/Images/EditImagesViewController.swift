//
//  EditImagesViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 04/01/21.
//

import UIKit

class EditImagesViewController: UIViewController {
    @IBOutlet weak var ibCollectionView: UICollectionView!

    let viewModel = EditImagesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "EditImagesCell", bundle: nil), forCellWithReuseIdentifier: "editImageCellID")

        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.itemSize = CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)

        ibCollectionView.collectionViewLayout = layout
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension EditImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "editImageCellID", for: indexPath) as? EditImagesCell else { return UICollectionViewCell() }

        cell.updateUI(with: viewModel[indexPath.item])
        cell.delegate = self

        return cell
    }
}

// MARK: - Edit Images delegate
extension EditImagesViewController: EditImagesDelegate {
    func deleteDidTapped() {
        
    }

    func makeDefault() {
        
    }
}
