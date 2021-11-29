//
//  ViolationsViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 02/08/21.
//

import UIKit

class ViolationsViewController: UIViewController {
    @IBOutlet weak var ibCollectionView: UICollectionView!

    var refreshControl = UIRefreshControl()

    private let viewModel = ViolationsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        registerCell()
        updateRefresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true

        /// Get List of Tickets created
        viewModel.getViolations()
    }

    private func updateRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh!!")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        ibCollectionView.addSubview(refreshControl)
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "ViolationCell", bundle: nil), forCellWithReuseIdentifier: "violationCellID")

        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 15.0, left: 16.0, bottom: 15.0, right: 16.0)
        layout.itemSize = CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)

        ibCollectionView.collectionViewLayout = layout
    }

    @objc func refresh(_ sender: AnyObject) {
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading data...")

        viewModel.getViolations()
    }
}

// MARK: - UIAlertView
extension ViolationsViewController {
    private func showAlert(for errorStr: String?) {
        let alertController = UIAlertController(title: errorStr, message: nil, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension ViolationsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "violationCellID", for: indexPath) as? ViolationCell else { return UICollectionViewCell() }

        cell.violationModel = viewModel[indexPath.item]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let ticketInboxVC = TicketsInboxViewController.instantiateSelf() else { return }

        ticketInboxVC.viewModel.updateViolating(userID: viewModel[indexPath.item]?.userID)

        navigationController?.pushViewController(ticketInboxVC, animated: true)
    }
}

// MARK: - TicketList Delegate
extension ViolationsViewController: TicketsListDelegate {
    func success() {
        ibCollectionView.reloadData()
        refreshControl.endRefreshing()
    }

    func failed(with errorStr: String?) {
        showAlert(for: errorStr)
        refreshControl.endRefreshing()
    }
}
