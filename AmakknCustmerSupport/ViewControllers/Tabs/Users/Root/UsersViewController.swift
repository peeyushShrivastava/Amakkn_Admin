//
//  UsersViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import UIKit

class UsersViewController: BaseViewController {
    @IBOutlet weak var ibCollectionView: UICollectionView!
    @IBOutlet weak var ibEmptyBGView: EmptyBGView!
    @IBOutlet var ibSearchBar: UISearchBar!
    @IBOutlet weak var ibCountHolderView: UIView!
    @IBOutlet weak var ibCountLabel: UILabel!

    var refreshControl = UIRefreshControl()

    let viewModel = UsersViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        ibEmptyBGView.delegate = self

        registerCell()
        updateRefresh()
        getUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = viewModel.isFilterCalled
        navigationItem.titleView = viewModel.isFilterCalled ? nil: ibSearchBar

        ibEmptyBGView.updateUI()
        AppSession.manager.validSession ? ibEmptyBGView.startActivityIndicator(with: "Fetching Users...") : ibEmptyBGView.updateErrorText()
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "UserCell", bundle: nil), forCellWithReuseIdentifier: "userCellID")
        ibCollectionView.register(UINib(nibName: "LoaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "LoaderView")

        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.itemSize = CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)

        ibCollectionView.collectionViewLayout = layout
        ibCollectionView.keyboardDismissMode = .interactive
    }

    private func updateRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh!!")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        ibCollectionView.addSubview(refreshControl)
    }

    @objc func refresh(_ sender: AnyObject) {
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading data...")

        viewModel.resetPage()
        getUsers()
    }
}

// MARK: - Navigation
extension UsersViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userDetailsSegueID",
            let destinationVC = segue.destination as? UserDetailsViewController, let row = sender as? Int {

            let userID = viewModel.isFilterCalled ? viewModel[row]?.userId : viewModel[row]?.userID
            destinationVC.viewModel.userID = userID
            destinationVC.viewModel.updateDataSource(with: nil)
        }
    }
}

// MARK: - API Calls
extension UsersViewController {
    private func getUsers() {
        guard AppSession.manager.validSession else { ibCollectionView.isHidden = true; ibEmptyBGView.isHidden = false; return }

        viewModel.getSearchedUserList()
    }

    private func updateUsersList() {
        ibCollectionView.isHidden = true
        ibEmptyBGView.isHidden = false
        ibEmptyBGView.startActivityIndicator(with: "Fetching Users...")

        viewModel.resetPage()

        getUsers()
    }
}

// MARK: - Alert View
extension UsersViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension UsersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCellID", for: indexPath) as? UserCell else { return UICollectionViewCell() }

        cell.userModel = viewModel[indexPath.item]
        cell.cellIndex = indexPath.row
        cell.delegate = self

        if viewModel.apiCallIndex == indexPath.row, viewModel.isMoreDataAvailable, viewModel.searchQuery != nil {
            viewModel.apiCallIndex += 50
            getUsers()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "userDetailsSegueID", sender: indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter, viewModel.isMoreDataAvailable, viewModel.searchQuery != nil  else { return UICollectionReusableView() }

        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoaderView", for: indexPath)

        return footerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard viewModel.isMoreDataAvailable, viewModel.searchQuery != nil  else { return CGSize.zero }

        return .init(width: viewModel.cellWidth, height: 40.0)
    }
}

// MARK: - UIScrollView Delegate
extension UsersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ibCountHolderView.isHidden = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        ibCountHolderView.isHidden = false
    }
}

// MARK: - UsersView Delegate
extension UsersViewController: UsersViewDelegate {
    func reloadView(_ isListEmpty: Bool) {
        guard viewModel.isFirstPage else { ibCollectionView.reloadData(); return }

        ibCollectionView.isHidden = isListEmpty
        ibEmptyBGView.isHidden = !isListEmpty

        if isListEmpty {
            ibEmptyBGView.updateText()
        }

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
extension UsersViewController {
    override func didSelectRefresh() {
        viewModel.resetPage()

        getUsers()
    }
}

// MARK: - Search Delegate
extension UsersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        ibSearchBar.resignFirstResponder()

        viewModel.resetPage()
        ibCollectionView.reloadData()
        updateUsersList()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.updateSearch(with: nil)

        viewModel.resetPage()

        ibCollectionView.isHidden = true
        ibEmptyBGView.isHidden = false
        ibEmptyBGView.startActivityIndicator(with: "Fetching Properties...")

        ibSearchBar.text = nil

        updateUsersList()

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
            ibEmptyBGView.startActivityIndicator(with: "Fetching Users...")

            viewModel.updateSearch(with: nil)

            viewModel.resetPage()
            ibCollectionView.reloadData()
            getUsers()

            DispatchQueue.main.async {
                self.ibSearchBar.resignFirstResponder()
                self.view.endEditing(true)
            }
        }
    }
}

// MARK: - UserCell Delegate
extension UsersViewController: UserCellDelegate {
    func didSelectCall(with phone: String?, _ countryCode: String?) {
        ibSearchBar.resignFirstResponder()

        viewModel.call(with: phone, countryCode) { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.showAlert(with: errorStr)
            }
        }
    }

    func didSelectChat(at index: Int) {
        viewModel.getChatModel(at: index) { [weak self] chatModel in
            DispatchQueue.main.async {
                self?.pushChatVC(with: chatModel)
            }
        } failureCallBack: { [weak self] errorStr in
            self?.showAlert(with: errorStr)
        }
    }
}

// MARK: - Push Chat VC
extension UsersViewController {
    private func pushChatVC(with chatModel: ChatInboxModel?) {
        guard let chatVC = ChatViewController.instantiateSelf() else { return }

        chatVC.viewModel.update(chatInboxModel: chatModel)
        chatVC.subject = viewModel.subjectID

        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - Init Self
extension UsersViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .users
    }
}
