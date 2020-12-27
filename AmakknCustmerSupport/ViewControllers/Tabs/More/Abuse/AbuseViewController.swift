//
//  AbuseViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 16/12/20.
//

import UIKit

class AbuseViewController: BaseViewController {
    @IBOutlet weak var ibCollectionView: UICollectionView!
    @IBOutlet weak var ibEmptyBGView: EmptyBGView!

    let viewModel = AbuseViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        ibEmptyBGView.delegate = self

        registerCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true

        ibEmptyBGView.updateUI()
        AppSession.manager.validSession ? ibEmptyBGView.startActivityIndicator(with: "Fetching Properties...") : ibEmptyBGView.updateErrorText()

        getAbuseList()
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "AbuseCell", bundle: nil), forCellWithReuseIdentifier: "abuseCellID")

        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.itemSize = CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)

        ibCollectionView.collectionViewLayout = layout
    }
}

// MARK: - API Calls
extension AbuseViewController {
    private func getAbuseList() {
        guard AppSession.manager.validSession else { ibCollectionView.isHidden = true; ibEmptyBGView.isHidden = false; return }

        viewModel.getAbuseList { [weak self] isListEmpty in
            self?.ibCollectionView.isHidden = isListEmpty
            self?.ibEmptyBGView.isHidden = !isListEmpty

            self?.ibCollectionView.reloadData()
        } failureCallBack: { [weak self] errorStr in
            self?.ibCollectionView.isHidden = true
            self?.ibEmptyBGView.isHidden = false
            self?.ibEmptyBGView.updateErrorText()

            self?.showAlert(with: errorStr)
        }
    }
}

// MARK: - Alert View
extension AbuseViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension AbuseViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "abuseCellID", for: indexPath) as? AbuseCell else { return UICollectionViewCell() }

        cell.dataSource = viewModel[indexPath.item]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let propertyDetailsVC = PropertyDetailsViewController.instantiateSelf() else { return }

        propertyDetailsVC.viewModel.update(with: viewModel.getPropertyID(at: indexPath.row))

        navigationController?.pushViewController(propertyDetailsVC, animated: true)
    }
}

// MARK: - Init Self
extension AbuseViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .more
    }
}
