//
//  EditPropertyDetailsViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 04/01/21.
//

import UIKit

// MARK: - EditProperty Delegate
protocol EditPropertyDelegate {
    func propertySaved()
}

class EditPropertyDetailsViewController: UIViewController {
    @IBOutlet weak var ibCollectionView: UICollectionView!

    var delegate: EditPropertyDelegate?
    let viewModel = EditPropertyDetailsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        updateCollection()
        registerCell()
    }

    private func updateCollection() {
        ibCollectionView.contentInsetAdjustmentBehavior = .never
        ibCollectionView.collectionViewLayout = PropertyDetailsFlowlayout()
        ibCollectionView.keyboardDismissMode = .interactive

        guard let layout = ibCollectionView.collectionViewLayout as? PropertyDetailsFlowlayout else { return }

        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0)
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "EditImageCell", bundle: nil), forCellWithReuseIdentifier: "EditImageCell")
        ibCollectionView.register(UINib(nibName: "EditFeaturesCell", bundle: nil), forCellWithReuseIdentifier: "EditFeaturesCell")
        ibCollectionView.register(UINib(nibName: "EditAmenitiesCell", bundle: nil), forCellWithReuseIdentifier: "EditAmenitiesCell")
        ibCollectionView.register(UINib(nibName: "EditDetailsCell", bundle: nil), forCellWithReuseIdentifier: "EditDetailsCell")
        ibCollectionView.register(UINib(nibName: "EditPlansCell", bundle: nil), forCellWithReuseIdentifier: "EditPlansCell")
        ibCollectionView.register(UINib(nibName: "EditDescriptionCell", bundle: nil), forCellWithReuseIdentifier: "EditDescriptionCell")
        ibCollectionView.register(UINib(nibName: "EditPriceCell", bundle: nil), forCellWithReuseIdentifier: "EditPriceCell")
        ibCollectionView.register(UINib(nibName: "PropertySaveCell", bundle: nil), forCellWithReuseIdentifier: "PropertySaveCell")
    }
}

// MARK: - Navigation
extension EditPropertyDetailsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photosSegueID",
           let destinationVC = segue.destination as? EditImagesViewController, let images = sender as? [Bool: [String]] {
            destinationVC.viewModel.update(images: images.values.first, isPlans: images.keys.first ?? false)
            destinationVC.viewModel.propertyID = viewModel.proprertyID
        }
    }
}

// MARK: - Button Action
extension EditPropertyDetailsViewController {
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        showSaveAlert()
    }
}

// MARK: - Alert View
extension EditPropertyDetailsViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: { [weak self] _ in
            self?.delegate?.propertySaved()
            self?.navigationController?.popViewController(animated: true)
        }))

        present(alertController, animated: true, completion: nil)
    }

    private func showSaveAlert() {
        let alertController = UIAlertController(title: "Do you want to Save the data?", message: nil, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Alert_Cancel".localized(), style: .default, handler: nil))

        alertController.addAction(UIAlertAction(title: "Save".localized(), style: .default, handler: { [weak self] _ in
            self?.viewModel.saveProperty()
        }))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Delegate / Data Source
extension EditPropertyDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dataSource = viewModel[indexPath.item]

        let detailCell = collectionView.dequeueReusableCell(withReuseIdentifier: type(of: dataSource).reuseCellID, for: indexPath)
    
        detailCell.tag = indexPath.row
        dataSource.configure(detailCell)

        if let featureCell = detailCell as? EditFeaturesCell {
            featureCell.delegate = self
        }

        if let amenityCell = detailCell as? EditAmenitiesCell {
            amenityCell.delegate = self
        }

        if let detailsCell = detailCell as? EditDetailsCell {
            detailsCell.delegate = self
        }

        if let descriptionCell = detailCell as? EditDescriptionCell {
            descriptionCell.delegate = self
        }

        if let priceCell = detailCell as? EditPriceCell {
            priceCell.delegate = self
        }

        if let saveCell = detailCell as? PropertySaveCell {
            saveCell.delegate = self
        }

        return detailCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: viewModel.height(for: indexPath.row))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? EditImageCell {
            guard cell.count != 0 else { return }

            performSegue(withIdentifier: "photosSegueID", sender: [false: viewModel.getPropertyImages()])
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? EditPlansCell {
            guard cell.count != 0 else { return }

            performSegue(withIdentifier: "photosSegueID", sender: [true: viewModel.getPlans()])
        }
    }
}

// MARK: - EditPropertyDetails Delegate
extension EditPropertyDetailsViewController: EditPropertyDetailsDelegate {
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.ibCollectionView.reloadData()
        }
    }

    func showError(with errorStr: String?) {
        showAlert(with: errorStr)
    }

    func popVC() {
        delegate?.propertySaved()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - EditFeatures Delegate
extension EditPropertyDetailsViewController: EditFeaturesDelegate {
    func plusDidTapped(for key: String?) {
        viewModel.updateFeatures(with: key, isPlus: true) { [weak self] in
            DispatchQueue.main.async {
                self?.ibCollectionView.reloadItems(at: [IndexPath(row: 1, section: 0)])
            }
        }
    }

    func minusDidTapped(for key: String?) {
        viewModel.updateFeatures(with: key, isPlus: false) { [weak self] in
            DispatchQueue.main.async {
                self?.ibCollectionView.reloadItems(at: [IndexPath(row: 1, section: 0)])
            }
        }
    }
}

// MARK: - EditAmenity Delegate
extension EditPropertyDetailsViewController: EditAmenityDelegate {
    func cellDid(select: Bool, amenity: Amenity?) {
        viewModel.update(amenity, isSelected: select) { [weak self] index in
            DispatchQueue.main.async {
                self?.ibCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
}

// MARK: - EditDetails Delegate
extension EditPropertyDetailsViewController: EditDetailsDelegate {
    func didShowKeyboard(for tag: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.ibCollectionView.scrollToItem(at: IndexPath(row: tag, section: 0), at: .top, animated: true)
        }
    }

    func update(frontispiece: Feature?, for tag: Int) {
        viewModel.update(frontispiece: frontispiece, for: tag) { [weak self] in
            DispatchQueue.main.async {
                self?.ibCollectionView.reloadItems(at: [IndexPath(row: tag, section: 0)])
            }
        }
    }

    func update(details: String?, with key: String?, for tag: Int, completion: @escaping () -> Void) {
        viewModel.updateDetails(data: details, with: key, for: tag) { [weak self] in
            DispatchQueue.main.async {
                self?.ibCollectionView.reloadItems(at: [IndexPath(row: tag, section: 0)])
                completion()
            }
        }
    }
}

// MARK: - EditDescription Delegate
extension EditPropertyDetailsViewController: EditDescriptionDelegate {
    func scrollCell(for tag: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.ibCollectionView.scrollToItem(at: IndexPath(row: tag, section: 0), at: .top, animated: true)
        }
    }

    func update(_ description: String?, completion: @escaping() -> Void) {
        viewModel.updateDescription(data: description) { [weak self] index in
            DispatchQueue.main.async {
                self?.ibCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                completion()
            }
        }
    }
}

// MARK: - EditPrice Delegate
extension EditPropertyDetailsViewController: EditPriceDelegate {
    func slideCell(for tag: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.ibCollectionView.scrollToItem(at: IndexPath(row: tag, section: 0), at: .top, animated: true)
        }
    }

    func update(price: String?, with key: String?, for tag: Int, completion: @escaping () -> Void) {
        viewModel.updatePrice(data: price, with: key, for: tag) { [weak self] in
            DispatchQueue.main.async {
                self?.ibCollectionView.reloadItems(at: [IndexPath(row: tag, section: 0)])
                completion()
            }
        }
    }
}

// MARK: - Property Save Delegate
extension EditPropertyDetailsViewController: PropertySaveDelegate {
    func propertyDidSaved() {
        showSaveAlert()
    }
}
