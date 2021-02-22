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
    @IBOutlet var ibSearchBar: UISearchBar!
    @IBOutlet weak var ibCountHolderView: UIView!
    @IBOutlet weak var ibCountLabel: UILabel!
    
    var refreshControl = UIRefreshControl()

    let viewModel = PropertiesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        ibEmptyBGView.delegate = self

        registerCell()
        updateRefresh()
        getProperties()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = viewModel.isFilterCalled
        navigationItem.titleView = viewModel.isFilterCalled ? nil: ibSearchBar

        ibEmptyBGView.updateUI()
        AppSession.manager.validSession ? ibEmptyBGView.startActivityIndicator(with: "Fetching Properties...") : ibEmptyBGView.updateErrorText()
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

        viewModel.getProperties()
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
            viewModel.apiCallIndex += 50
            getProperties()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let propertyDetailsVC = PropertyDetailsViewController.instantiateSelf() else { return }

        propertyDetailsVC.viewModel.update(with: viewModel[indexPath.item]?.propertyID)
        propertyDetailsVC.delegate = self

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

// MARK: - UIScrollView Delegate
extension PropertiesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ibCountHolderView.isHidden = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        ibCountHolderView.isHidden = false
    }
}

// MARK: - PropertiesView Delegate
extension PropertiesViewController: PropertiesViewDelegate {
    func reloadView(_ isListEmpty: Bool) {
        guard viewModel.isFirstPage else { ibCollectionView.reloadData(); return }

        ibCollectionView.isHidden = isListEmpty
        ibEmptyBGView.isHidden = !isListEmpty
        ibEmptyBGView.updateText()

        ibCollectionView.reloadData()
        refreshControl.endRefreshing()
    }

    func show(_ errorStr: String?) {
        ibCollectionView.isHidden = true
        ibEmptyBGView.isHidden = false
        ibEmptyBGView.updateErrorText()

        showAlert(with: errorStr)
        refreshControl.endRefreshing()
    }

    func updateProperty(count: String?) {
        ibCountHolderView.isHidden = false
        ibCountLabel.text = count
    }
}

// MARK: - EmptyBGView Delegate
extension PropertiesViewController {
    override func didSelectRefresh() {
        viewModel.resetPage()

        getProperties()
    }
}

// MARK: - Login Delegate
extension PropertiesViewController {
    override func loginSuccess() {
        viewModel.resetPage()

        getProperties()
    }
}

// MARK: - Search Delegate
extension PropertiesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        ibSearchBar.resignFirstResponder()

        viewModel.resetPage()
        ibCollectionView.reloadData()
        getProperties()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.updateSearch(with: nil)

        viewModel.resetPage()

        ibCollectionView.isHidden = true
        ibEmptyBGView.isHidden = false
        ibEmptyBGView.startActivityIndicator(with: "Fetching Properties...")

        ibSearchBar.text = nil

        getProperties()

        DispatchQueue.main.async {
            self.ibSearchBar.resignFirstResponder()
            self.view.endEditing(true)
        }
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else { return true }

        if let searchStr = searchBar.text, let textRange = Range(range, in: searchStr) {
            let searchQuery = searchStr.replacingCharacters(in: textRange, with: text)

            viewModel.updateSearch(with: searchQuery)
        }
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            ibCollectionView.isHidden = true
            ibEmptyBGView.isHidden = false
            ibEmptyBGView.startActivityIndicator(with: "Fetching Properties...")

            viewModel.updateSearch(with: nil)

            viewModel.resetPage()
            ibCollectionView.reloadData()
            getProperties()

            DispatchQueue.main.async {
                self.ibSearchBar.resignFirstResponder()
                self.view.endEditing(true)
            }
        }
    }
}

// MARK: - PropertyDetails Delegate
extension PropertiesViewController: PropertyDetailsDelegate {
    func update(status: String?, for propertyID: String?) {
        viewModel.change(status: status, for: propertyID) { [weak self] (index, isDeleted) in
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: index, section: 0)
                isDeleted ? self?.ibCollectionView.deselectItem(at: indexPath, animated: true): self?.ibCollectionView.reloadItems(at: [indexPath])
            }
        }
    }
}

// MARK: - Init Self
extension PropertiesViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .properties
    }
}
