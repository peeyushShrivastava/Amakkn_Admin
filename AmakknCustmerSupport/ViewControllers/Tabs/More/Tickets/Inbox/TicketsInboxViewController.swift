//
//  TicketsInboxViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import UIKit

class TicketsInboxViewController: UIViewController {
    @IBOutlet weak var ibCollectionView: UICollectionView!
    @IBOutlet weak var ibCreateButton: UIButton!
    @IBOutlet weak var ibStatusHolder: UIView!
    @IBOutlet weak var ibStatusLabel: UILabel!
    @IBOutlet var ibSearchBar: UISearchBar!
    @IBOutlet weak var ibSearchbarHeight: NSLayoutConstraint!
    
    var refreshControl = UIRefreshControl()

    let viewModel = TicketsInboxViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        viewModel.getStatusList()

        updateUI()
        registerCell()
        updateRefresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        ibSearchbarHeight.constant = viewModel.vUserID != nil ? 0.0 : 44.0
        ibSearchBar.isHidden = viewModel.vUserID != nil

        /// Get List of Tickets created
        viewModel.resetPage()
        viewModel.getTickets()
    }

    private func updateUI() {
        ibCreateButton.layer.masksToBounds = true
        ibCreateButton.layer.borderColor = UIColor.white.cgColor
        ibCreateButton.layer.borderWidth = 0.5

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
        viewModel.getTickets()
    }
}

// MARK: - Button Action
extension TicketsInboxViewController {
    @IBAction func moreTapped(_ sender: UIBarButtonItem) {
        guard viewModel.vUserID == nil else { return }
        guard let barButtonItem = navigationItem.rightBarButtonItem else { return }
        guard let buttonItemView = barButtonItem.value(forKey: "view") as? UIView else { return }

        let moreMenu = UIAlertController(title: "Filter Tickets", message: nil, preferredStyle: .actionSheet)

        viewModel.statusList?.forEach({ status in
            let title = status.statusName == "NA" ? "All" : status.statusName
            moreMenu.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.ibStatusLabel.text = title?.capitalized

                    let status = status.statusName == "NA" ? "-5" : status.statusID
                    self?.viewModel.ticketStatus = status ?? "-5"
                    self?.viewModel.resetPage()
                    self?.viewModel.getTickets()
                }
            }))
        })

        moreMenu.addAction(UIAlertAction(title: "Alert_Cancel".localized(), style: .cancel, handler: nil))

        /// Applicable for iPad
        moreMenu.popoverPresentationController?.sourceRect = buttonItemView.bounds
        moreMenu.popoverPresentationController?.sourceView = buttonItemView

        present(moreMenu, animated: true, completion: nil)
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
                viewModel.getTickets()
            }

            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "multiTicketCellID", for: indexPath) as? MultiTicketInboxCell else { return UICollectionViewCell() }

        cell.ticketModel = model
        cell.delegate = self

        if viewModel.apiCallIndex == indexPath.row, viewModel.isMoreDataAvailable, viewModel.searchQuery != nil {
            viewModel.apiCallIndex += 50
            viewModel.getTickets()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard viewModel[indexPath.item]?.children?.count == 0 else { return }

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
extension TicketsInboxViewController: TicketsListDelegate {
    func success() {
        ibStatusHolder.isHidden = viewModel.vUserID != nil
        ibCollectionView.reloadData()
        refreshControl.endRefreshing()
    }

    func failed(with errorStr: String?) {
        ibStatusHolder.isHidden = viewModel.vUserID != nil
        showAlert(for: errorStr)
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
        viewModel.getTickets()
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
            viewModel.getTickets()

            DispatchQueue.main.async {
                self.ibSearchBar.resignFirstResponder()
                self.view.endEditing(true)
            }
        }
    }
}

// MARK: - MultiTicketCell Delegate
extension TicketsInboxViewController: MultiTicketCellDelegate {
    func didSelectTicket(with model: TicketsModel?, for tag: Int) {
        performSegue(withIdentifier: "detailsSegueID", sender: (model, tag))
    }
}
