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

    var refreshControl = UIRefreshControl()

    private let viewModel = TicketsInboxViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        updateUI()
        registerCell()
        updateRefresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true

        /// Get List of Tickets created
        viewModel.getTickets()
    }

    private func updateUI() {
        ibCreateButton.layer.masksToBounds = true
        ibCreateButton.layer.borderColor = UIColor.white.cgColor
        ibCreateButton.layer.borderWidth = 0.5
    }

    private func updateRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh!!")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        ibCollectionView.addSubview(refreshControl)
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "TicketInboxCell", bundle: nil), forCellWithReuseIdentifier: "ticketInboxICellD")
        
        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 15.0, left: 16.0, bottom: 15.0, right: 16.0)
        layout.itemSize = CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)

        ibCollectionView.collectionViewLayout = layout
    }

    @objc func refresh(_ sender: AnyObject) {
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading data...")

        viewModel.getTickets()
    }
}

// MARK: - Navigation
extension TicketsInboxViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsSegueID" {
            guard let ticketModel = sender as? TicketsModel else { return }
            guard let detailsVC =  segue.destination as? TicketDetailsViewController else { return }

            detailsVC.viewModel.updateTicket(ticketModel.ticketID)
            detailsVC.viewModel.updateUserID(ticketModel.userID)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ticketInboxICellD", for: indexPath) as? TicketInboxCell else { return UICollectionViewCell() }

        cell.ticketModel = viewModel[indexPath.item]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailsSegueID", sender: viewModel[indexPath.item])
    }
}

// MARK: - TicketList Delegate
extension TicketsInboxViewController: TicketsListDelegate {
    func success() {
        ibCollectionView.reloadData()
        refreshControl.endRefreshing()
    }

    func failed(with errorStr: String?) {
        showAlert(for: errorStr)
        refreshControl.endRefreshing()
    }
}
