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

        viewModel.delegate = self
        ibEmptyBGView.delegate = self

        updateRefresh()
        registerCells()
        getAbuses()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = false

        ibEmptyBGView.updateUI()
        updateMainTabDelegate()
        AppSession.manager.validSession ? ibEmptyBGView.startActivityIndicator(with: "Fetching Properties...") : ibEmptyBGView.updateErrorText()
    }

    private func registerCells() {
        ibTableView.register(UINib(nibName: "AbusesCell", bundle: nil), forCellReuseIdentifier: "abusesCellID")
    }

    private func updateRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh!!")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        ibTableView.addSubview(refreshControl)
    }

    private func updateMainTabDelegate() {
        guard let window = UIApplication.shared.windows.first else { return }
        guard let tabBarController = window.rootViewController as? MainTabBarController else { return }

        tabBarController.tabDelegate = self
    }

    @objc func refresh(_ sender: AnyObject) {
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading data...")

        viewModel.resetPage()
        getAbuses()
    }
}

// MARK: - Button Actions
extension AbusesViewController {
    @IBAction func sortButtonTapped(_ sender: UIBarButtonItem) {
        guard let popOverVC = PopoverViewController.instantiateSelf() else { return }

        popOverVC.view.frame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 300.0)
        popOverVC.modalPresentationStyle = .popover
        popOverVC.titleList = viewModel.getSortOrders()
        popOverVC.selectedTitle = viewModel.selectedOrder
        popOverVC.delegate = self

        let popOver = popOverVC.popoverPresentationController
        popOver?.barButtonItem = sender
        popOver?.sourceRect = CGRect(x:0.0, y: 0.0, width: 315, height: 230)
        popOver?.delegate = self

        present(popOverVC, animated: true, completion:nil)
    }
}

// MARK: - UIPopover Delegate
extension AbusesViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - API Call
extension AbusesViewController {
    private func getAbuses() {
        guard AppSession.manager.validSession else { ibTableView.isHidden = true; ibEmptyBGView.isHidden = false; return }

        viewModel.getAbuses()
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
            viewModel.apiCallIndex += 15
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
        propertyDetailsVC.delegate = self

        navigationController?.pushViewController(propertyDetailsVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard viewModel.isMoreDataAvailable else { return 1.0 }

        return 50.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard viewModel.isMoreDataAvailable else { return UIView(frame: .zero) }

        return getFooterView()
    }

    private func getFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: 40.0))
        footerView.backgroundColor = .clear
        
        let loader = UIActivityIndicatorView(style: .medium)
        loader.tintColor = .white
        loader.hidesWhenStopped = true
        loader.startAnimating()
        loader.center = footerView.center
        
        footerView.addSubview(loader)
        
        return footerView
    }
}

// MARK: - AbuseView Delegate
extension AbusesViewController: AbusesViewDelegate {
    func reloadView(_ isListEmpty: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard self?.viewModel.isFirstPage ?? true else { self?.ibTableView.reloadData(); return }

            self?.ibTableView.isHidden = isListEmpty
            self?.ibEmptyBGView.isHidden = !isListEmpty

            if isListEmpty {
                self?.ibEmptyBGView.updateErrorText()
            }

            self?.ibTableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }

    func showError(_ errorStr: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.ibTableView.isHidden = true
            self?.ibEmptyBGView.isHidden = false
            self?.ibEmptyBGView.updateErrorText()

            self?.showAlert(with: errorStr)
            self?.refreshControl.endRefreshing()
        }
    }
}

// MARK: - Popover Delegate
extension AbusesViewController: AppPopoverDelegate {
    func didSelectCell(with title: String?) {
        guard let title = title else { return }

        ibEmptyBGView.startActivityIndicator(with: "Fetching Properties...")
        ibTableView.isHidden = true
        ibEmptyBGView.isHidden = false

        viewModel.resetPage()
        viewModel.selectedOrder = title
        getAbuses()
    }
}

// MARK: - MainTab Delegate
extension AbusesViewController {
    override func scrollToTop() {
        DispatchQueue.main.async {
            self.ibTableView.setContentOffset(CGPoint(x: 0, y: self.ibTableView.contentInset.top), animated: true)
        }
    }
}

// MARK: - EmptyBGView Delegate
extension AbusesViewController {
    override func didSelectRefresh() {
        viewModel.resetPage()

        getAbuses()
    }
}

// MARK: - Login Delegate
extension AbusesViewController {
    override func loginSuccess() {
        viewModel.resetPage()

        getAbuses()
    }
}

// MARK: - PropertyDetails Delegate
extension AbusesViewController: PropertyDetailsDelegate {
    func updateComplaint(for propertyID: String?) {
        viewModel.updateComplaint(for: propertyID)
    }

    func updateAllComplaints(for propertyID: String?) {
        viewModel.updateAllComplaints(for: propertyID)
    }
}
