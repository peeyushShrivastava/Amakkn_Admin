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

    let viewModel = UsersViewModel()
    var searchQuery: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        ibEmptyBGView.delegate = self

        registerCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = false
        navigationItem.titleView = ibSearchBar

        ibEmptyBGView.updateUI()
        AppSession.manager.validSession ? ibEmptyBGView.update(message: "Search Users with UserId, User Name, User Type etc.") : ibEmptyBGView.updateErrorText()
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
}

// MARK: - Navigation
extension UsersViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterSegueID",
            let destinationVC = segue.destination as? UserFilterViewController {

            destinationVC.delegate = self
        } else if segue.identifier == "userDetailsSegueID",
            let destinationVC = segue.destination as? UserDetailsViewController, let row = sender as? Int {

            let userID = viewModel[row]?.userID
            destinationVC.viewModel.userID = userID
            destinationVC.viewModel.updateDataSource(with: nil)
        }
    }
}

// MARK: - API Calls
extension UsersViewController {
    private func getUsers() {
        guard AppSession.manager.validSession else { ibCollectionView.isHidden = true; ibEmptyBGView.isHidden = false; return }

        viewModel.getSearchedUserList(searchQuery, successCallBack: { [weak self] isListEmpty in
            DispatchQueue.main.async {
                guard self?.viewModel.isFirstPage ?? true else { self?.ibCollectionView.reloadData(); return }

                self?.ibCollectionView.isHidden = isListEmpty
                self?.ibEmptyBGView.isHidden = !isListEmpty

                if isListEmpty {
                    self?.ibEmptyBGView.updateText()
                }

                self?.ibCollectionView.reloadData()
            }
        }, failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.ibCollectionView.isHidden = true
                self?.ibEmptyBGView.isHidden = false
                self?.ibEmptyBGView.updateErrorText()

                self?.showAlert(with: errorStr)
            }
        })
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

        if viewModel.apiCallIndex == indexPath.row, viewModel.isMoreDataAvailable {
            viewModel.apiCallIndex += 10
            getUsers()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "userDetailsSegueID", sender: indexPath.row)
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
extension UsersViewController {
    override func didSelectRefresh() {
        viewModel.resetPage()

        getUsers()
    }
}

// MARK: - UsersFilter Delegate
extension UsersViewController: UserFilterDelegate {
    func didUpdateFilter(with dataSource: [String : String]) {
        viewModel.updateFilter(dataSource)

        ibEmptyBGView.startActivityIndicator(with: "Fetching Users...")
        ibEmptyBGView.isHidden = false
        ibCollectionView.isHidden = true

        getUsers()
    }
}

// MARK: - Search Delegate
extension UsersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        ibSearchBar.resignFirstResponder()

        viewModel.updateLast(searchQuery)
        ibCollectionView.reloadData()
        updateUsersList()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard searchQuery != viewModel.getLastSearchedStr() else {
            viewModel.resetPage()
            ibCollectionView.isHidden = true
            ibEmptyBGView.isHidden = false
            ibEmptyBGView.update(message: "Search Users with UserId, User Name, User Type etc.")

            ibSearchBar.text = nil

            return
        }
        searchQuery = viewModel.getLastSearchedStr()
        ibSearchBar.text = searchQuery

        guard !(searchQuery?.isEmpty ?? true) else {
            viewModel.resetPage()
            ibCollectionView.isHidden = true
            ibEmptyBGView.isHidden = false
            ibEmptyBGView.update(message: "Search Users with UserId, User Name, User Type etc.")

            return
        }

        updateUsersList()
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else { return true }

        if let searchStr = searchBar.text, let textRange = Range(range, in: searchStr) {
            searchQuery = searchStr.replacingCharacters(in: textRange, with: text)

            viewModel.updateLatest(searchQuery)
        }
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            ibCollectionView.isHidden = true
            ibEmptyBGView.isHidden = false
            ibEmptyBGView.update(message: "Search Users with UserId, User Name, User Type etc.")

            viewModel.resetPage()
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
