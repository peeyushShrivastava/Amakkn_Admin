//
//  InboxViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import UIKit

class InboxViewController: BaseViewController {
    @IBOutlet weak var ibChatTableView: UITableView!
    @IBOutlet weak var ibEmptyBGView: EmptyBGView!
    @IBOutlet weak var ibFilterButton: UIBarButtonItem!

    var refreshControl = UIRefreshControl()

    let viewModel = InboxViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        ibEmptyBGView.delegate = self

        updateRefresh()
        registerCell()
        viewModel.getSubjects()
        getChats()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = false

        ibEmptyBGView.updateUI()
        updateMainTabDelegate()
        ibFilterButton.isEnabled = AppSession.manager.validSession
        AppSession.manager.validSession ? ibEmptyBGView.startActivityIndicator(with: "Fetching Chats...") : ibEmptyBGView.updateErrorText()
    }

    private func registerCell() {
        ibChatTableView.register(UINib(nibName: "InboxCell", bundle: nil), forCellReuseIdentifier: "inboxCellID")
    }

    private func updateRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh!!")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        ibChatTableView.addSubview(refreshControl)
    }

    private func updateMainTabDelegate() {
        guard let window = UIApplication.shared.windows.first else { return }
        guard let tabBarController = window.rootViewController as? MainTabBarController else { return }

        tabBarController.tabDelegate = self
    }

    @objc func refresh(_ sender: AnyObject) {
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading data...")

        viewModel.resetPage()
        getChats()
    }
}

// MARK: - Button Actions
extension InboxViewController {
    @IBAction func filterBottonTapped(_ sender: UIBarButtonItem) {
        guard let popOverVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatSubjectsViewController") as? ChatSubjectsViewController else { return }

        popOverVC.modalPresentationStyle = .popover
        popOverVC.subjects = viewModel.chatSubjects
        popOverVC.selectedSubject = viewModel.subjectID
        popOverVC.delegate = self

        let popOver = popOverVC.popoverPresentationController
        popOver?.barButtonItem = sender
        popOver?.delegate = self

        present(popOverVC, animated: true, completion:nil)
    }
}

// MARK: - UIPopover Delegate
extension InboxViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - API Calls
extension InboxViewController {
    private func getChats() {
        guard AppSession.manager.validSession else { ibChatTableView.isHidden = true; ibEmptyBGView.isHidden = false; return }

        viewModel.getSupportChatList { [weak self] isListEmpty in
            guard self?.viewModel.isFirstPage ?? true else { self?.ibChatTableView.reloadData(); return }

            self?.ibChatTableView.isHidden = isListEmpty
            self?.ibEmptyBGView.isHidden = !isListEmpty

            self?.ibChatTableView.reloadData()
            self?.refreshControl.endRefreshing()
        } failureCallBack: { [weak self] errorStr in
            self?.ibChatTableView.isHidden = true
            self?.ibEmptyBGView.isHidden = false
            self?.ibEmptyBGView.updateErrorText()

            self?.showAlert(with: errorStr)
            self?.refreshControl.endRefreshing()
        }
    }
}

// MARK: - Alert View
extension InboxViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: "Amakkn_Alert_Text".localized(), message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewView Delegate / DataSource
extension InboxViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCellID") as? InboxCell else { return UITableViewCell() }

        cell.inboxModel = viewModel[indexPath.row]

        if viewModel.apiCallIndex == indexPath.row, viewModel.isMoreDataAvailable {
            viewModel.apiCallIndex += 50
            getChats()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chat = viewModel[indexPath.row] else { return }

        viewModel.resetUnreadCount(at: indexPath.row)
        ibChatTableView.reloadData()

        pushChatVC(for: chat)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section != 0 else { return 10.0 }

        return 1.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if viewModel.isMoreDataAvailable {
            return 50.0
        }
        return 1.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if viewModel.isMoreDataAvailable {
            return getFooterView()
        }
        return UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let closeAction = UIContextualAction(style: .normal, title: "Close") { [weak self] (_, _, _) in
            self?.viewModel.deleteObject(at: indexPath.row)
            self?.viewModel.closeChatThread(self?.viewModel.getChatID(at: indexPath.row)) {
                DispatchQueue.main.async {
                    self?.viewModel.deleteObject(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
        closeAction.backgroundColor = UIColor.systemPurple

        let configuration = UISwipeActionsConfiguration(actions: [closeAction])
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
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

// MARK: - Subjects Delegate
extension InboxViewController: SubjectsDelegate {
    func didSelectCell(with subjectID: String?) {
        guard let subjectID = subjectID else { return }

        ibEmptyBGView.startActivityIndicator(with: "Fetching Chats...")
        ibChatTableView.isHidden = true
        ibEmptyBGView.isHidden = false

        viewModel.resetPage()
        viewModel.subjectID = subjectID
        getChats()
    }
}

// MARK: - MainTab Delegate
extension InboxViewController {
    override func scrollToTop() {
        DispatchQueue.main.async {
            self.ibChatTableView.setContentOffset(CGPoint(x: 0, y: self.ibChatTableView.contentInset.top), animated: true)
        }
    }
}

// MARK: - EmptyBGView Delegate
extension InboxViewController {
    override func didSelectRefresh() {
        viewModel.resetPage()

        getChats()
    }
}

// MARK: - Login Delegate
extension InboxViewController {
    override func loginSuccess() {
        viewModel.resetPage()

        getChats()
    }
}

// MARK: - Push Chat VC
extension InboxViewController {
    private func pushChatVC(for chat: CSInboxModel) {
        guard let chatVC = ChatViewController.instantiateSelf() else { return }

        chatVC.viewModel.update(chatInboxModel: getChatModel(for: chat))
        chatVC.subject = chat.subject ?? ""
        
        chatVC.reloadChat = { [weak self] in
            DispatchQueue.main.async {
                self?.viewModel.resetPage()
                self?.getChats()
            }
        }

        navigationController?.pushViewController(chatVC, animated: true)
    }

    private func getChatModel(for chat: CSInboxModel) -> ChatInboxModel? {
        var senderID = ""
        var receiverID = ""
        var senderName = ""
        var receiverName = ""
        var senderAvatar = ""
        var receiverAvatar = ""

        if AppSession.manager.userID == chat.userID1 {
            senderID = chat.userID1 ?? ""
            receiverID = chat.userID2 ?? ""
            senderName = chat.userName1 ?? ""
            receiverName = chat.userName2 ?? ""
            senderAvatar = chat.userAvatar1 ?? ""
            receiverAvatar = chat.userAvatar2 ?? ""
        } else if AppSession.manager.userID == chat.userID2 {
            senderID = chat.userID2 ?? ""
            receiverID = chat.userID1 ?? ""
            senderName = chat.userName2 ?? ""
            receiverName = chat.userName1 ?? ""
            senderAvatar = chat.userAvatar2 ?? ""
            receiverAvatar = chat.userAvatar1 ?? ""
        }

        let model = ChatInboxModel(senderID: senderID, receiverID: receiverID, channelID: chat.channelID, propertyID: chat.subjectID, chatID: chat.chatID,
                                   senderName: senderName, receiverName: receiverName, senderAvatar: senderAvatar, receiverAvatar: receiverAvatar, isVerified: "",
                                   category: nil, propertyType: nil, propertyTypeName: nil, listedFor: nil,
                                   unreadCount: nil, lastMessage: chat.lastMessage, time: chat.updatedAt,
                                   photos: nil, defaultPrice: nil, address: nil, senderUserType: nil, receiverUserType: nil)

        return model
    }
}
