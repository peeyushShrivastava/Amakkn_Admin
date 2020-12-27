//
//  MoreViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 19/10/20.
//

import UIKit

class MoreViewController: UIViewController {
    @IBOutlet weak var ibMoreTableView: UITableView!

    let viewModel = MoreViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = false

        if AppSession.manager.validSession {
            viewModel.updateData()
            ibMoreTableView.reloadData()
        }
    }

    private func registerCell() {
        ibMoreTableView.register(UINib(nibName: "MoreCell", bundle: nil), forCellReuseIdentifier: "moreCellID")
    }
}

// MARK: - UITableView Delegate / DataSource
extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "moreCellID", for: indexPath) as? MoreCell else { return UITableViewCell() }

        cell.titleText = viewModel.getText(at: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            case 1:
                AppSession.manager.validSession ? logoutAlert() : presentLoginVC()
            default:
                if indexPath.row == 1 {
                    performSegue(withIdentifier: "statsSegueID", sender: nil)
                }
        }
    }
}

// MARK: - Logout API Call
extension MoreViewController {
    private func logoutAlert() {
        let alertController = UIAlertController(title: nil, message: "More_Are_you_sure_Logout".localized(), preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Logout".localized(), style: .cancel, handler: { [weak self] _ in
            self?.logout()
        }))

        alertController.addAction(UIAlertAction(title: "Alert_Cancel".localized(), style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    private func logout() {
        viewModel.logout { [weak self] in
            DispatchQueue.main.async {
                self?.viewModel.updateData()
                self?.ibMoreTableView.reloadData()
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.showAlert(with: errorStr)
            }
        }
    }

    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Push VCs
extension MoreViewController {
    private func presentLoginVC() {
        guard let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") as? LoginViewController else { return }

        let navigationVC = UINavigationController(rootViewController: loginVC)
        navigationVC.modalPresentationStyle = .fullScreen

        present(navigationVC, animated: true, completion: nil)
    }
}
