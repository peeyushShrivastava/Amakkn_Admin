//
//  AbusesViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/12/20.
//

import UIKit

class AbusesViewController: BaseViewController {
    @IBOutlet weak var ibTableView: UITableView!
    @IBOutlet weak var ibEmptyBGView: EmptyBGView!

    var refreshControl = UIRefreshControl()

    let viewModel = AbusesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        ibEmptyBGView.delegate = self

        updateRefresh()
        registerCells()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = false

        ibEmptyBGView.updateUI()
        AppSession.manager.validSession ? ibEmptyBGView.startActivityIndicator(with: "Fetching Properties...") : ibEmptyBGView.updateErrorText()

        viewModel.resetPage()
        getAbuses()
    }

    private func registerCells() {
        ibTableView.register(UINib(nibName: "AbusesCell", bundle: nil), forCellReuseIdentifier: "abusesCellID")
    }

    private func updateRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh!!")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        ibTableView.addSubview(refreshControl)
    }

    @objc func refresh(_ sender: AnyObject) {
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading data...")

        viewModel.resetPage()
        getAbuses()
    }
}

// MARK: - API Call
extension AbusesViewController {
    private func getAbuses() {
        guard AppSession.manager.validSession else { ibTableView.isHidden = true; ibEmptyBGView.isHidden = false; return }

        viewModel.getAbuses { [weak self] isListEmpty in
            guard self?.viewModel.isFirstPage ?? true else { self?.ibTableView.reloadData(); return }

            self?.ibTableView.isHidden = isListEmpty
            self?.ibEmptyBGView.isHidden = !isListEmpty

            self?.ibTableView.reloadData()
            self?.refreshControl.endRefreshing()
        } failureCallBack: { [weak self] errorStr in
            self?.ibTableView.isHidden = true
            self?.ibEmptyBGView.isHidden = false
            self?.ibEmptyBGView.updateErrorText()

            self?.showAlert(with: errorStr)
            self?.refreshControl.endRefreshing()
        }
    }
}

// MARK: - Alert View
extension AbusesViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableView Delegate / DataSource
extension AbusesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "abusesCellID") as? AbusesCell else { return UITableViewCell() }

        cell.dataSource = viewModel[indexPath.row]

        if viewModel.apiCallIndex == indexPath.row, viewModel.isMoreDataAvailable {
            viewModel.apiCallIndex += 10
            getAbuses()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let propertyDetailsVC = PropertyDetailsViewController.instantiateSelf() else { return }

        propertyDetailsVC.viewModel.update(with: viewModel[indexPath.item]?.propertyID)

        navigationController?.pushViewController(propertyDetailsVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
}

// MARK: - EmptyBGView Delegate
extension AbusesViewController {
    override func didSelectRefresh() {
        viewModel.resetPage()

        getAbuses()
    }
}
