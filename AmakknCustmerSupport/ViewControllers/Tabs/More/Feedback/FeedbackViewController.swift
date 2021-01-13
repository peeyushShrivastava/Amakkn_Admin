//
//  FeedbackViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 31/12/20.
//

import UIKit
import MessageUI

class FeedbackViewController: BaseViewController {
    @IBOutlet weak var ibTableView: UITableView!
    @IBOutlet weak var ibSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ibEmptyBGView: EmptyBGView!

    let viewModel = FeedbackViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        ibEmptyBGView.delegate = self

        registerCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true

        ibEmptyBGView.updateUI()
        AppSession.manager.validSession ? ibEmptyBGView.startActivityIndicator(with: "Fetching Feedbacks...") : ibEmptyBGView.updateErrorText()

        getFeedbackList()
    }

    private func registerCell() {
        ibTableView.register(UINib(nibName: "FeedbackCell", bundle: nil), forCellReuseIdentifier: "feedbackCellID")
    }
}

// MARK: - Navigation
extension FeedbackViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feedBackDetailsSegueID",
            let destinationVC = segue.destination as? FeedbackDetailsViewController,
            let index = sender as? Int {

            destinationVC.feedback = viewModel.getFeedbackText(at: index)
        }
    }
}

// MARK: - Segment Control
extension FeedbackViewController {
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        viewModel.reset { [weak self] in
            self?.ibTableView.isHidden = true

            switch sender.selectedSegmentIndex {
                case 0: self?.viewModel.status = "0"
                case 1: self?.viewModel.status = "1"
                default: self?.viewModel.status = "2"
            }

            self?.ibTableView.isHidden = true
            self?.ibEmptyBGView.isHidden = false
            self?.ibEmptyBGView.startActivityIndicator(with: "Fetching Feedbacks...")
            self?.getFeedbackList()
        }
    }
}

// MARK: - API Calls
extension FeedbackViewController {
    private func getFeedbackList() {
        guard AppSession.manager.validSession else { ibTableView.isHidden = true; ibEmptyBGView.isHidden = false; return }

        viewModel.getFeedbackList { [weak self] isListEmpty in
            self?.ibTableView.isHidden = isListEmpty
            self?.ibEmptyBGView.isHidden = !isListEmpty
            self?.ibEmptyBGView.updateErrorText()

            self?.ibTableView.reloadData()
        } failureCallBack: { [weak self] errorStr in
            self?.ibTableView.isHidden = true
            self?.ibEmptyBGView.isHidden = false
            self?.ibEmptyBGView.updateErrorText()

            self?.showAlert(with: errorStr)
        }
    }
}

// MARK: - Alert View
extension FeedbackViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension FeedbackViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedbackCellID") as? FeedbackCell else { return UITableViewCell() }

        cell.dataSource = viewModel[indexPath.row]
        cell.delegate = self

        if viewModel.apiCallIndex == indexPath.row, viewModel.isMoreDataAvailable {
            viewModel.apiCallIndex += 50
            getFeedbackList()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "feedBackDetailsSegueID", sender: indexPath.item)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let feedbackID = viewModel[indexPath.row]?.feedbackID else { return nil }

        switch viewModel.status {
        case "0":
            let starAction = UIContextualAction(style: .normal, title: "Star") { [weak self] (_, _, _) in
                self?.viewModel.changeFeedback("2", for: feedbackID) {
                    DispatchQueue.main.async {
                        self?.ibTableView.reloadData()
                    }
                }
            }
            starAction.backgroundColor = UIColor.systemTeal

            let reviewedAction = UIContextualAction(style: .normal, title: "Reviewed") { [weak self] (_, _, _) in
                self?.viewModel.changeFeedback("1", for: feedbackID) {
                    DispatchQueue.main.async {
                        self?.ibTableView.reloadData()
                    }
                }
            }
            reviewedAction.backgroundColor = UIColor.systemPurple

            let configuration = UISwipeActionsConfiguration(actions: [starAction, reviewedAction])
            configuration.performsFirstActionWithFullSwipe = false

            return configuration
        case "1":
            let starAction = UIContextualAction(style: .normal, title: "Star") { [weak self] (_, _, _) in
                self?.viewModel.changeFeedback("2", for: feedbackID) {
                    DispatchQueue.main.async {
                        self?.ibTableView.reloadData()
                    }
                }
            }
            starAction.backgroundColor = UIColor.systemTeal

            let configuration = UISwipeActionsConfiguration(actions: [starAction])
            configuration.performsFirstActionWithFullSwipe = false

            return configuration
        default:
            let reviewedAction = UIContextualAction(style: .normal, title: "Reviewed") { [weak self] (_, _, _) in
                self?.viewModel.changeFeedback("1", for: feedbackID) {
                    DispatchQueue.main.async {
                        self?.ibTableView.reloadData()
                    }
                }
            }
            reviewedAction.backgroundColor = UIColor.systemPurple

            let configuration = UISwipeActionsConfiguration(actions: [reviewedAction])
            configuration.performsFirstActionWithFullSwipe = false

            return configuration
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard viewModel.isMoreDataAvailable else { return 0.1 }

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

// MARK: - Feedback Delegate
extension FeedbackViewController: FeedbackDelegate {
    func didSelect(userID: String?) {
        guard let userProfileVC = UserDetailsViewController.instantiateSelf() else { return }

        userProfileVC.viewModel.userID = userID
        userProfileVC.viewModel.updateDataSource(with: nil)

        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }

    func didSelect(email: String?) {
        guard let email = email else { return }

        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()

            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setMessageBody("<p></p>", isHTML: true)

            present(mail, animated: true)
        } else {
            
        }
    }
}

// MARK: - Feedback Delegate
extension FeedbackViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
