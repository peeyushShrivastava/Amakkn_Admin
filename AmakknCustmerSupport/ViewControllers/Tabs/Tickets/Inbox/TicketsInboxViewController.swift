//
//  TicketsInboxViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import UIKit

class TicketsInboxViewController: BaseViewController {
    @IBOutlet weak var ibCollectionView: UICollectionView!
    @IBOutlet weak var ibMoreButton: UIButton!
    @IBOutlet weak var ibStatusHolder: UIView!
    @IBOutlet weak var ibStatusLabel: UILabel!
    @IBOutlet var ibSearchBar: UISearchBar!
    @IBOutlet weak var ibSearchbarHeight: NSLayoutConstraint!
    @IBOutlet weak var ibEmptyBGView: EmptyBGView!
    
    var refreshControl = UIRefreshControl()

    let viewModel = TicketsInboxViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        ibEmptyBGView.delegate = self

        updateUI()
        registerCell()
        updateRefresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationHandler.manager.delegate = self
        tabBarController?.tabBar.isHidden = viewModel.showTabBar
        ibSearchbarHeight.constant = viewModel.vUserID != nil ? 0.0 : 44.0
        ibSearchBar.isHidden = viewModel.vUserID != nil
        ibMoreButton.isHidden = viewModel.vUserID != nil

        navigationItem.titleView = viewModel.showTabBar ? nil : ibSearchBar

        /// Get List of Tickets created
        viewModel.resetPage()
        getTickets(isNextPage: false)

        ibEmptyBGView.updateUI()
        AppSession.manager.validSession ? ibEmptyBGView.startActivityIndicator(with: "Fetching Tickets...") : ibEmptyBGView.updateErrorText()
        ibSearchBar.isHidden = !AppSession.manager.validSession
        ibMoreButton.isHidden = !AppSession.manager.validSession
        ibStatusHolder.isHidden = !AppSession.manager.validSession
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationHandler.manager.delegate = nil
    }

    private func updateUI() {
        ibMoreButton.layer.masksToBounds = true
        ibMoreButton.layer.borderColor = UIColor.white.cgColor
        ibMoreButton.layer.borderWidth = 0.5

        ibStatusHolder.layer.masksToBounds = true
        ibStatusHolder.layer.borderColor = UIColor.lightGray.cgColor
        ibStatusHolder.layer.borderWidth = 1.0
    }

    private func updateRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh!!")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        ibCollectionView.addSubview(refreshControl)
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "TicketInboxCell", bundle: nil), forCellWithReuseIdentifier: "ticketInboxICellD")
        ibCollectionView.register(UINib(nibName: "MultiTicketInboxCell", bundle: nil), forCellWithReuseIdentifier: "multiTicketCellID")
        ibCollectionView.register(UINib(nibName: "LoaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "LoaderView")
        
        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 15.0, left: 16.0, bottom: 15.0, right: 16.0)

        ibCollectionView.collectionViewLayout = layout
        ibCollectionView.keyboardDismissMode = .interactive
    }

    @objc func refresh(_ sender: AnyObject) {
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading data...")

        viewModel.resetPage()
        getTickets(isNextPage: false)
    }

    private func getTickets(isNextPage: Bool) {
        guard AppSession.manager.validSession else { ibCollectionView.isHidden = true; ibEmptyBGView.isHidden = false; return }

        viewModel.getTickets(isNextPage)
    }
}

// MARK: - UIPopover Delegate
extension TicketsInboxViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - Navigation
extension TicketsInboxViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsSegueID" {
            guard let data = sender as? (TicketsModel, Int) else { return }
            guard let detailsVC =  segue.destination as? TicketDetailsViewController else { return }

            detailsVC.viewModel.updateTicket(data.1 == 0 ? data.0.ticketID : data.0.children?.last?.ticketID)
            detailsVC.viewModel.updateUserID(data.1 == 0 ? data.0.userID : data.0.children?.last?.userID)
            detailsVC.viewModel.updateFeedbackModel(data.1 == 0 ? data.0.feedback : data.0.children?.last?.feedback)
            detailsVC.viewModel.updateParentTicketID(data.1 == 0 ? data.0.ticketID : data.0.children?.last?.ticketID)
            detailsVC.viewModel.title = (data.1 == 0 ? data.0.title : data.0.children?.last?.title) ?? ""
            detailsVC.viewModel.updateViolation(data.1 == 0 ? data.0.violation : data.0.children?.last?.violation)
        } else if segue.identifier == "ticketsFilterSegueID" {
            guard let filterVC =  segue.destination as? TicketsFilterViewController else { return }

            filterVC.delegate = self
            filterVC.viewModel.updateData(viewModel.ticketStatusModel, and: viewModel.ticketSubjectModel)
        }
    }
}

// MARK: - UIAlertView
extension TicketsInboxViewController {
    private func showAlert(for errorStr: String?) {
        let alertController = UIAlertController(title: errorStr, message: nil, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - AppNotification Delegate
extension TicketsInboxViewController: AppNotificationDelegate {
    func didReceiveNotification(for ticketID: String?) {
        viewModel.resetPage()
        getTickets(isNextPage: true)
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension TicketsInboxViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = viewModel[indexPath.item]

        if model?.children?.count == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ticketInboxICellD", for: indexPath) as? TicketInboxCell else { return UICollectionViewCell() }

            cell.ticketModel = model

            if viewModel.apiCallIndex == indexPath.row, viewModel.isMoreDataAvailable, viewModel.searchQuery != nil {
                viewModel.apiCallIndex += 50
                getTickets(isNextPage: true)
            }

            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "multiTicketCellID", for: indexPath) as? MultiTicketInboxCell else { return UICollectionViewCell() }

        cell.ticketModel = model
        cell.delegate = self

        if viewModel.apiCallIndex == indexPath.row, viewModel.isMoreDataAvailable, viewModel.searchQuery != nil {
            viewModel.apiCallIndex += 50
            getTickets(isNextPage: true)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard viewModel[indexPath.item]?.children?.count == 0 else { return }

        viewModel.updateUnreadCount(at: indexPath.row)
        ibCollectionView.reloadItems(at: [indexPath])

        performSegue(withIdentifier: "detailsSegueID", sender: (viewModel[indexPath.item], 0))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: viewModel.cellWidth, height: viewModel.getCellHeight(at: indexPath.row))
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

// MARK: - TicketList Delegate
extension TicketsInboxViewController: AbusesViewDelegate {
    func reloadView(_ isListEmpty: Bool) {
        guard viewModel.isFirstPage else { ibCollectionView.reloadData(); return }

        ibStatusHolder.isHidden = isListEmpty
        ibCollectionView.isHidden = isListEmpty
        ibEmptyBGView.isHidden = !isListEmpty

        if isListEmpty {
            ibEmptyBGView.updateErrorText()
        }

        ibStatusHolder.isHidden = viewModel.vUserID != nil
        ibCollectionView.reloadData()
        refreshControl.endRefreshing()
    }

    func showError(_ errorStr: String?) {
        ibStatusHolder.isHidden = true
        ibCollectionView.isHidden = true
        ibEmptyBGView.isHidden = false

        ibEmptyBGView.updateErrorText()

        if errorStr != "No tickets available." {
            showAlert(for: errorStr)
        }

        ibCollectionView.reloadData()
        refreshControl.endRefreshing()
    }
}

// MARK: - Search Delegate
extension TicketsInboxViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        ibSearchBar.resignFirstResponder()

        guard searchBar.text?.count ?? 0 > 0 else { return }

        viewModel.resetPage()
        getTickets(isNextPage: false)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.ibSearchBar.text = nil
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
            viewModel.updateSearch(with: nil)
            viewModel.resetPage()
            getTickets(isNextPage: false)

            DispatchQueue.main.async {
                self.ibSearchBar.resignFirstResponder()
                self.view.endEditing(true)
            }
        }
    }
}

// MARK: - EmptyBGView Delegate
extension TicketsInboxViewController {
    override func didSelectRefresh() {
        viewModel.resetPage()

        getTickets(isNextPage: false)
    }
}

// MARK: - TicketsFilter Delegate
extension TicketsInboxViewController: TicketsFilterDelegate {
    func updateList(with status: StatusModel?, and subject: SubjectModel?) {
        let title = status?.statusName == "NA" ? "All" : status?.statusName
        let statusID = status?.statusName == "NA" ? "-5" : status?.statusID
        viewModel.ticketStatus = statusID ?? "-5"
        viewModel.subjectStatus = subject?.subjectID ?? ""
        viewModel.ticketStr = title ?? "All"
        viewModel.ticketStatusModel = status
        viewModel.ticketSubjectModel = subject
    }
}


// MARK: - MultiTicketCell Delegate
extension TicketsInboxViewController: MultiTicketCellDelegate {
    func didSelectTicket(with model: TicketsModel?, for tag: Int) {
        performSegue(withIdentifier: "detailsSegueID", sender: (model, tag))
    }
}

// MARK: - Init Self
extension TicketsInboxViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .ticket
    }
}
