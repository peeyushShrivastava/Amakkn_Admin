//
//  UserPropertiesViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 23/12/20.
//

import UIKit

class UserPropertiesViewController: BaseViewController {
    @IBOutlet weak var ibCollectionView: UICollectionView!
    @IBOutlet weak var ibEmptyBGView: EmptyBGView!

    let viewModel = UserPropertiesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        ibEmptyBGView.delegate = self

        registerCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true

        ibEmptyBGView.updateUI()
        AppSession.manager.validSession ? ibEmptyBGView.startActivityIndicator(with: "Fetching Properties...") : ibEmptyBGView.updateErrorText()
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "PropertyCardCell", bundle: nil), forCellWithReuseIdentifier: "propertyCardCellID")

        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.itemSize = CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)

        ibCollectionView.collectionViewLayout = layout
    }
}

// MARK: - Alert View
extension UserPropertiesViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension UserPropertiesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "propertyCardCellID", for: indexPath) as? PropertyCardCell else { return UICollectionViewCell() }

        cell.dataSource = viewModel[indexPath.item]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let propertyDetailsVC = PropertyDetailsViewController.instantiateSelf() else { return }

        propertyDetailsVC.viewModel.update(with: viewModel.getPropertyID(at: indexPath.item))

        navigationController?.pushViewController(propertyDetailsVC, animated: true)
    }
}

// MARK: - EmptyBGView Delegate
extension UserPropertiesViewController {
    override func didSelectRefresh() {
        viewModel.getProperties()
    }
}

// MARK: - ViewModel Delegate
extension UserPropertiesViewController: UserPropertiesDelegate {
    func didFinishWithSuccess(_ isListEmpty: Bool) {
        ibCollectionView.isHidden = isListEmpty
        ibEmptyBGView.isHidden = !isListEmpty

        ibCollectionView.reloadData()
    }

    func didFinishWithFailure(_ errorStr: String?) {
        ibCollectionView.isHidden = true
        ibEmptyBGView.isHidden = false
        ibEmptyBGView.updateErrorText()

        showAlert(with: errorStr)
    }
}
