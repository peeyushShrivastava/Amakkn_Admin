//
//  TicketsFilterViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/10/21.
//

import UIKit

class TicketsFilterViewController: UIViewController {
    @IBOutlet weak var ibTableView: UITableView!
    @IBOutlet weak var ibStatusLabel: UILabel!
    @IBOutlet weak var ibSubjectLabel: UILabel!
    @IBOutlet weak var ibResetButton: UIBarButtonItem!

    @IBOutlet weak var ibStatusHolder: UIView!
    @IBOutlet weak var ibSubjectHolder: UIView!

    let viewModel = TicketsFilterViewModel()
    weak var delegate: TicketsFilterDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        viewModel.getStatusList()
        updateResetButton(with: !viewModel.disableReset)

        registerCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true
    }

    private func registerCell() {
        ibTableView.register(UINib(nibName: "ChangeUserTypeCell", bundle: nil), forCellReuseIdentifier: "userTypeCellID")
    }

    private func updateResetButton(with state: Bool) {
        ibResetButton.isEnabled = state
    }
}

// MARK: - Button Actions
extension TicketsFilterViewController {
    @IBAction func statusButtonTapped(_ sender: UIButton) {
        viewModel.filterType = .status

        ibStatusHolder.backgroundColor = UIColor(red: 43.0/255.0, green: 78.0/255.0, blue: 86.0/255.0, alpha: 1.0)
        ibSubjectHolder.backgroundColor = AppColors.lightViewBGColor
        ibStatusLabel.textColor = .white
        ibSubjectLabel.textColor = AppColors.selectedTitleTextColor

        ibTableView.reloadData()
    }

    @IBAction func subjectButtonTapped(_ sender: UIButton) {
        viewModel.filterType = .subject

        ibSubjectHolder.backgroundColor = UIColor(red: 43.0/255.0, green: 78.0/255.0, blue: 86.0/255.0, alpha: 1.0)
        ibStatusHolder.backgroundColor = AppColors.lightViewBGColor
        ibSubjectLabel.textColor = .white
        ibStatusLabel.textColor = AppColors.selectedTitleTextColor

        ibTableView.reloadData()
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        delegate?.updateList(with: viewModel.selectedStatus, and: viewModel.selectedSubject)

        navigationController?.popViewController(animated: true)
    }

    @IBAction func resetButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.resetData()
        viewModel.filterType = .status

        ibStatusHolder.backgroundColor = UIColor(red: 43.0/255.0, green: 78.0/255.0, blue: 86.0/255.0, alpha: 1.0)
        ibSubjectHolder.backgroundColor = AppColors.lightViewBGColor
        ibStatusLabel.textColor = .white
        ibSubjectLabel.textColor = AppColors.selectedTitleTextColor

        let statusStr = viewModel.selectedStatus?.statusName
        ibStatusLabel.text = statusStr == "NA" ? "All" : statusStr
        ibSubjectLabel.text = viewModel.selectedSubject?.subject

        updateResetButton(with: false)
        ibTableView.reloadData()
    }
}

// MARK: - UITableView Delegate / DataSource
extension TicketsFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userTypeCellID") as? ChangeUserTypeCell else { return UITableViewCell() }

        let title = viewModel.getTitle(at: indexPath.row)
        cell.ibTitleLabel.text = title == "NA" ? "All" : title
        cell.ibTick.isHidden = !viewModel.canShowTick(for: title)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.updateSelected(title: viewModel.getTitle(at: indexPath.row)) { [weak self] in
            DispatchQueue.main.async {
                let statusStr = self?.viewModel.selectedStatus?.statusName
                self?.ibStatusLabel.text = statusStr == "NA" ? "All" : statusStr
                self?.ibSubjectLabel.text = self?.viewModel.selectedSubject?.subject
                self?.updateResetButton(with: true)

                self?.ibTableView.reloadData()
            }
        }
    }
}

// MARK: - UIAlertView
extension TicketsFilterViewController {
    private func showAlert(for errorStr: String?) {
        let alertController = UIAlertController(title: errorStr, message: nil, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - TicketList Delegate
extension TicketsFilterViewController: TicketsListDelegate {
    func success() {
        let statusStr = viewModel.selectedStatus?.statusName
        ibStatusLabel.text = statusStr == "NA" ? "All" : statusStr
        ibSubjectLabel.text = viewModel.selectedSubject?.subject

        ibTableView.reloadData()
    }

    func failed(with errorStr: String?) {
        showAlert(for: errorStr)
    }
}
