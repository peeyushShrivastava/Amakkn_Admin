//
//  ChangeTypeViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 03/10/21.
//

import UIKit

class ChangeTypeViewController: UIViewController {
    @IBOutlet weak var ibTableView: UITableView!
    @IBOutlet weak var ibSaveButton: UIBarButtonItem!

    var userTypeChanged: (() -> Void)?

    let viewModel = ChangeTypeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
        updateSave(with: false)
    }

    private func registerCell() {
        ibTableView.register(UINib(nibName: "ChangeUserTypeCell", bundle: nil), forCellReuseIdentifier: "userTypeCellID")
    }

    private func updateSave(with status: Bool) {
        ibSaveButton.isEnabled = status
    }
}

// MARK: - Show Alert
private extension ChangeTypeViewController {
    func showAlert(with errorStr: String?) {
        let alert = UIAlertController(title: errorStr, message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Button Actions
extension ChangeTypeViewController {
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure you want to change user type of this User to \(viewModel.getUserType())?", message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
            self?.changeUserType()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - API Call
extension ChangeTypeViewController {
    private func changeUserType() {
        viewModel.changeUserType { [weak self] in
            if let userTypeChanged = self?.userTypeChanged {
                userTypeChanged()

                self?.navigationController?.popViewController(animated: true)
            }
        } failureCallBack: { [weak self] errorStr in
            self?.showAlert(with: errorStr)
        }
    }
}

// MARK: - UITableViewCell Delegate / DataSource
extension ChangeTypeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userTypeCellID") as? ChangeUserTypeCell else { return UITableViewCell() }

        cell.data = viewModel[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.updateUser(with: viewModel[indexPath.row].model?.type)
        updateSave(with: true)

        ibTableView.reloadData()
    }
}
