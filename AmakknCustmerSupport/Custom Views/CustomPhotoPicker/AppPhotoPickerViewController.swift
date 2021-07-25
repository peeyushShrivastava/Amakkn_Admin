//
//  AppPhotoPickerViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import UIKit
import Photos

// MARK: - PhotoPicker Delegate
protocol PhotoPickerDelegate {
    func didUpdateWith(image: UIImage?)
}

// Image Struct
struct ImageModel {
    let image: UIImage
    var isSelected: Bool
}

class AppPhotoPickerViewController: UIViewController {
    @IBOutlet weak var ibCollectionView: UICollectionView!

    private var doneButton: UIBarButtonItem?

    private var images = [ImageModel]()
    private var prevSelectedIndex = 0
    private var selectedImage: UIImage?
    private let cellWidth: CGFloat = (UIScreen.main.bounds.width - 55.0)/3

    var delegate: PhotoPickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Select Photos"

        registerCell()
        getPhotos()
        updateNavBar()
    }
    
    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "GalleryImageCell", bundle: nil), forCellWithReuseIdentifier: "galleryCellID")

        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 15.0, left: 16.0, bottom: 15.0, right: 16.0)
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)

        ibCollectionView.collectionViewLayout = layout
    }
}

// MARK: - Add Navigation Item
extension AppPhotoPickerViewController {
    private func updateNavBar() {
        doneButton = UIBarButtonItem(title: "\("Done".localized())(0)", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem  = doneButton

        let cancelButton = UIBarButtonItem(title: "Alert_Cancel".localized(), style: .done, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem  = cancelButton
    }

    @objc func doneTapped() {
        delegate?.didUpdateWith(image: selectedImage)

        dismiss(animated: true, completion: nil)
    }

    @objc func cancelTapped() {
         dismiss(animated: true, completion: nil)
    }
}

// MARK: - Get Photos from Gallery
extension AppPhotoPickerViewController {
    private func getPhotos() {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        let fetchOptions = PHFetchOptions()

        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat

        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        DispatchQueue.main.async {
            let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

            if results.count > 0 {
                for i in 0..<results.count {
                    let asset = results.object(at: i)
                    let size = CGSize(width: 700, height: 700)

                    manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { [weak self] (image, _) in
                        guard let image = image else { return }

                        self?.images.append(ImageModel(image: image, isSelected: false))
                        self?.ibCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension AppPhotoPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCellID", for: indexPath) as? GalleryImageCell else { return UICollectionViewCell() }

        let imageModel = images[indexPath.item]
        cell.ibImageView.image = imageModel.image
        cell.ibSelectIcon.isHidden = !imageModel.isSelected

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        images[indexPath.row].isSelected = true

        if indexPath.row != prevSelectedIndex {
            images[prevSelectedIndex].isSelected = false

            ibCollectionView.reloadItems(at: [indexPath, IndexPath(row: prevSelectedIndex, section: 0)])
        }

        selectedImage = images[indexPath.row].image
        prevSelectedIndex = indexPath.row
        doneButton?.title = "\("Done".localized())(1)"
    }
}
