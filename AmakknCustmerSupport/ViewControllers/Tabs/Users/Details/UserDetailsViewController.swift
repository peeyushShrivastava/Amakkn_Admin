//
//  UserDetailsViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/10/20.
//

import UIKit

// MARK: - User Change Status Enum
enum UserChangeStatus: String {
    case created = "0"
    case activate = "1"
    case delete = "-1"
    case suspend = "-2"
}

class UserDetailsViewController: UIViewController {
    @IBOutlet weak var ibDetailsTableView: UITableView!
    @IBOutlet weak var ibTableViewWidth: NSLayoutConstraint!

    var headerView: UserDetailsHeaderView?

    let viewModel = UserDetailsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        registerCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true
    }

    private func registerCell() {
        ibDetailsTableView.register(UINib(nibName: "UserDetailsProfileCell", bundle: nil), forCellReuseIdentifier: "userDetailsProfileCellID")
        ibDetailsTableView.register(UINib(nibName: "UserDetailsDataCell", bundle: nil), forCellReuseIdentifier: "userDetailsDataCellID")
        ibDetailsTableView.register(UINib(nibName: "UserDetailsDataViewerCell", bundle: nil), forCellReuseIdentifier: "dataViewerCellID")

        ibTableViewWidth.constant = viewModel.cellWidth
    }
}

// MARK: - Navigation
extension UserDetailsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "propertyListSegueID",
            let destinationVC = segue.destination as? UserPropertiesViewController {
            guard let propertyIDs = sender as? String else { return }

            destinationVC.viewModel.update(propertyIDs)
        } else if segue.identifier == "notificationSegueID",
                  let destinationVC = segue.destination as? SendUserViewController {
            destinationVC.userID = viewModel.userID
        }
    }
}

// MARK: - Button Actions
extension UserDetailsViewController {
    @IBAction func moreButtonTapped(_ sender: UIBarButtonItem) {
        guard let barButtonItem = navigationItem.rightBarButtonItem else { return }
        guard let buttonItemView = barButtonItem.value(forKey: "view") as? UIView else { return }

        let moreMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let suspend = UIAlertAction(title: "User_Suspend".localized(), style: .default, handler: { [weak self] _ in
            self?.showActionAlert(for: UserChangeStatus.suspend.rawValue)
        })
        let notification = UIAlertAction(title: "Send_Notif".localized(), style: .default, handler: { [weak self] _ in
            self?.performSegue(withIdentifier: "notificationSegueID", sender: nil)
        })
        let ticket = UIAlertAction(title: "Create Ticket", style: .default, handler: { [weak self] _ in
            guard let createTicketVC = CreateTicketViewController.instantiateSelf() else { return }

            let profileModel = self?.viewModel.getProfileData()
            createTicketVC.viewModel.updateUserID(Utility.shared.getHashedUserID(for: profileModel?.userID, createdAt: profileModel?.createdAt))

            self?.navigationController?.pushViewController(createTicketVC, animated: true)
        })
        let active = UIAlertAction(title: "User_Active".localized(), style: .default, handler: { [weak self] _ in
            self?.showActionAlert(for: UserChangeStatus.activate.rawValue)
        })
        let delete = UIAlertAction(title: "User_Delete".localized(), style: .destructive, handler: { [weak self] (alert: UIAlertAction) in
            self?.showActionAlert(for: UserChangeStatus.delete.rawValue)
        })
        let cancelAction = UIAlertAction(title: "Alert_Cancel".localized(), style: .cancel, handler: nil)

        /// Add Actions
        guard let userStatus = viewModel.userStatus, let status = UserChangeStatus(rawValue: userStatus) else { return }

        switch status {
            case .activate:
                moreMenu.addAction(suspend)
                moreMenu.addAction(notification)
                moreMenu.addAction(ticket)
                moreMenu.addAction(delete)
            case .delete:
                moreMenu.addAction(notification)
                moreMenu.addAction(ticket)
            case .suspend:
                moreMenu.addAction(active)
                moreMenu.addAction(notification)
                moreMenu.addAction(ticket)
                moreMenu.addAction(delete)
            case .created:
                moreMenu.addAction(suspend)
                moreMenu.addAction(active)
                moreMenu.addAction(notification)
                moreMenu.addAction(ticket)
                moreMenu.addAction(delete)
        }

        moreMenu.addAction(cancelAction)

        /// Applicable for iPad
        moreMenu.popoverPresentationController?.sourceRect = buttonItemView.bounds
        moreMenu.popoverPresentationController?.sourceView = buttonItemView

        present(moreMenu, animated: true, completion: nil)
    }
}

// MARK: - UITableView Delegate / DataSource
extension UserDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = UserDetailsSection(rawValue: indexPath.section) else { return UITableViewCell() }

        switch sectionType {
        case .profile:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userDetailsProfileCellID", for: indexPath) as? UserDetailsProfileCell else { return UITableViewCell() }

            cell.profileModel = viewModel.getProfileData()
            cell.delegate = self

            return cell
        default:
            let models = viewModel.getData(at: indexPath.section)
            let model = models?.detailsData?[indexPath.row]

            if !(model?.propertyIDs.isEmpty ?? true) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "dataViewerCellID", for: indexPath) as? UserDetailsDataViewerCell else { return UITableViewCell() }

                cell.model = model
                cell.updateUI(for: viewModel.isLastCell(at: indexPath))

                return cell
            }

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userDetailsDataCellID", for: indexPath) as? UserDetailsDataCell else { return UITableViewCell() }

            cell.model = model
            cell.updateUI(for: viewModel.isLastCell(at: indexPath))

            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.getCellHeight(at: indexPath.section)
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section != 0 else { return UIView() }

        /// Create Header View
        headerView = Bundle.main.loadNibNamed("UserDetailsHeaderView", owner: self, options: nil)?.last as? UserDetailsHeaderView

        headerView?.backgroundColor = AppColors.lightViewBGColor
        headerView?.update(viewModel.getData(at: section)?.detailsTitle, at: section)
        headerView?.updateUI(for: viewModel.getData(at: section)?.isExpanded ?? false)

        headerView?.delegate = self

        return headerView
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section != 0 else { return 0.0 }

        return viewModel.headerHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionType = UserDetailsSection(rawValue: indexPath.section) else { return }
        guard sectionType != .profile else { return }
        guard let models = viewModel.getData(at: indexPath.section), let model = models.detailsData?[indexPath.row] else { return }
        guard !model.propertyIDs.isEmpty, model.propertyIDs != "0" else { return }

        performSegue(withIdentifier: "propertyListSegueID", sender: model.propertyIDs)
    }
}

// MARK: - UserDetailsHeader Delegate
extension UserDetailsViewController: UserDetailsHeaderDelegate {
    func expandCell(at section: Int) {
        viewModel.updateExpand(at: section)

        if let data = viewModel.getData(at: section), let filterData = data.detailsData {
            var indexPaths = [IndexPath]()

            for row in filterData.indices {
                indexPaths.append(IndexPath(row: row, section: section))
            }

            data.isExpanded ? ibDetailsTableView.insertRows(at: indexPaths, with: .fade) :  ibDetailsTableView.deleteRows(at: indexPaths, with: .fade)

            ibDetailsTableView.reloadSections([section], with: .none)
        }
    }
}

// MARK: - Change Status
extension UserDetailsViewController {
    private func showActionAlert(for status: String) {
        guard let status = UserChangeStatus(rawValue: status) else { return }

        var msgStr = ""
        switch status {
            case .activate: msgStr = "Do you want to activate this User?"
            case .delete: msgStr = "Do you want to delete this User?"
            case .suspend: msgStr = "Do you want to suspend this User?"
            case .created: break
        }

        let alertController = UIAlertController(title: nil, message: msgStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Alert_Cancel".localized(), style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "alert_Yes".localized(), style: .default, handler: { [weak self] _ in
            self?.change(status: status.rawValue)
        }))

        present(alertController, animated: true, completion: nil)
    }

    private func change(status: String) {
        viewModel.changeUser(status) {
            guard let status = UserChangeStatus(rawValue: status) else { return }

            var msgStr = ""
            switch status {
                case .activate: msgStr = "User has been activated successfully!!"
                case .delete: msgStr = "User has been deleted successfully!!"
                case .suspend: msgStr = "User has been suspended successfully!!"
                case .created: break
            }
            self.showPopUp(with: msgStr)
        } failureCallBack: { [weak self] errorStr in
            self?.showAlert(with: errorStr)
        }
    }
}

// MARK: - Alert View
extension UserDetailsViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    private func showPopUp(with msg: String?) {
        let alertController = UIAlertController(title: nil, message: msg, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UserDetails Delegate
extension UserDetailsViewController: UserDetailsDelegate {
    func updateData() {
        DispatchQueue.main.async { [weak self] in
            self?.ibDetailsTableView.reloadData()
        }
    }
}

// MARK: - UserDetailsProfile Delegate
extension UserDetailsViewController: UserDetailsProfileDelegate {
    func callDidTapped(with phone: String?, _ countryCode: String?) {
        viewModel.call(with: phone, countryCode) { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.showAlert(with: errorStr)
            }
        }
    }

    func chatDidTapped(with userID: String?) {
        viewModel.getChatModel(for: userID) { [weak self] chatModel in
            DispatchQueue.main.async {
                self?.pushChatVC(with: chatModel)
            }
        } failureCallBack: { [weak self] errorStr in
            self?.showAlert(with: errorStr)
        }
    }
}

// MARK: - Push Chat VC
extension UserDetailsViewController {
    private func pushChatVC(with chatModel: ChatInboxModel?) {
        guard let chatVC = ChatViewController.instantiateSelf() else { return }

        chatVC.viewModel.update(chatInboxModel: chatModel)
        chatVC.subject = viewModel.subjectID

        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - Init Self
extension UserDetailsViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .users
    }
}
