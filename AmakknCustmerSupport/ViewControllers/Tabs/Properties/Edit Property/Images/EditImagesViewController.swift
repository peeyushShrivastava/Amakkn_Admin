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

        viewModel.delegate = self

        registerCell()
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "EditImagesCell", bundle: nil), forCellWithReuseIdentifier: "editImageCellID")

        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.itemSize = CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)

        ibCollectionView.collectionViewLayout = layout
        ibCollectionView.keyboardDismissMode = .interactive
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension EditImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "editImageCellID", for: indexPath) as? EditImagesCell else { return UICollectionViewCell() }

        cell.tag = indexPath.item
        cell.updateUI(with: viewModel[indexPath.item], isPlans: viewModel.isForPlans)
        cell.delegate = self

        return cell
    }
}

// MARK: - EditImagesView Delegate
extension EditImagesViewController: EditImagesViewDelegate {
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.ibCollectionView.reloadData()
        }
    }

    func show(_ errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Edit Images delegate
extension EditImagesViewController: EditImagesDelegate {
    func keyboardDidShow(at index: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.ibCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        }
    }
    
    func deleteDidTapped(at index: Int) {
        viewModel.deleteImage(at: index)
    }

    func makeDefault(at index: Int) {
        viewModel.makeDefault(at: index)
    }

    func update(_ photoTitle: String?, at index: Int) {
        viewModel.updatePhoto(title: photoTitle, at: index)
    }
}
