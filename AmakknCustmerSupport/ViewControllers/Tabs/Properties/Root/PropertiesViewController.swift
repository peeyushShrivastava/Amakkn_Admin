//
//  PropertiesViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import UIKit

class PropertiesViewController: BaseViewController {
    @IBOutlet weak var ibCollectionView: UICollectionView!
    @IBOutlet weak var ibEmptyBGView: EmptyBGView!
    @IBOutlet weak var ibFilterButton: UIBarButtonItem!

    var refreshControl = UIRefreshControl()

    let viewModel = PropertiesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        ibEmptyBGView.delegate = self

        registerCell()
        updateRefresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = false

        ibEmptyBGView.updateUI()
        ibFilterButton.isEnabled = AppSession.manager.validSession
        AppSession.manager.validSession ? ibEmptyBGView.startActivityIndicator(with: "Fetching Properties...") : ibEmptyBGView.updateErrorText()

        getProperties()
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "PropertyCardCell", bundle: nil), forCellWithReuseIdentifier: "propertyCardCellID")
        ibCollectionView.register(UINib(nibName: "LoaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "LoaderView")

        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.itemSize = CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)

        ibCollectionView.collectionViewLayout = layout
    }

    private func updateRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh!!")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        ibCollectionView.addSubview(refreshControl)
    }

    @objc func refresh(_ sender: AnyObject) {
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading data...")

        viewModel.resetPage()
        getProperties()
    }
}

// MARK: - Navigation
extension PropertiesViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "propertyFilterSegueID",
            let destinationVC = segue.destination as? PropertiesFilterViewController {

            destinationVC.delegate = self
        }
    }
}

// MARK: - Button Action
extension PropertiesViewController {
    @IBAction func filterButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "propertyFilterSegueID", sender: nil)
    }
}

// MARK: - API Calls
extension PropertiesViewController {
    private func getProperties() {
        guard AppSession.manager.validSession else { ibCollectionView.isHidden = true; ibEmptyBGView.isHidden = false; return }

        viewModel.getProperties { [weak self] isListEmpty in
            guard self?.viewModel.isFirstPage ?? true else { self?.ibCollectionView.reloadData(); return }

            self?.ibCollectionView.isHidden = isListEmpty
            self?.ibEmptyBGView.isHidden = !isListEmpty

            self?.ibCollectionView.reloadData()
            self?.refreshControl.endRefreshing()
        } failureCallBack: { [weak self] errorStr in
            self?.ibCollectionView.isHidden = true
            self?.ibEmptyBGView.isHidden = false
            self?.ibEmptyBGView.updateErrorText()

            self?.showAlert(with: errorStr)
            self?.refreshControl.endRefreshing()
        }
    }
}

// MARK: - Alert View
extension PropertiesViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension PropertiesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "propertyCardCellID", for: indexPath) as? PropertyCardCell else { return UICollectionViewCell() }

        cell.dataSource = viewModel[indexPath.item]

        if viewModel.apiCallIndex == indexPath.row, viewModel.isMoreDataAvailable {
            viewModel.apiCallIndex += 10
            getProperties()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let propertyDetailsVC = PropertyDetailsViewController.instantiateSelf() else { return }

        propertyDetailsVC.viewModel.update(with: viewModel[indexPath.item]?.propertyID)

        navigationController?.pushViewController(propertyDetailsVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter, viewModel.isMoreDataAvailable  else { return UICollectionReusableView() }

        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoaderView", for: indexPath)

        return footerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard viewModel.isMoreDataAvailable  else { return CGSize.zero }

        return .init(width: viewModel.cellWidth, height: 40.0)
    }
}

// MARK: - EmptyBGView Delegate
extension PropertiesViewController {
    override func didSelectRefresh() {
        viewModel.resetPage()

        getProperties()
    }
}

// MARK: - UsersFilter Delegate
extension PropertiesViewController: UserFilterDelegate {
    func didUpdateFilter(with dataSource: [String : String]) {
        viewModel.updateFilter(dataSource)

        ibEmptyBGView.startActivityIndicator(with: "Fetching Properties...")
        ibEmptyBGView.isHidden = false
        ibCollectionView.isHidden = true

        getProperties()
    }
}
