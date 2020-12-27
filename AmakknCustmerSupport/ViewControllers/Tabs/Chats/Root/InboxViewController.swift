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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = false

        ibEmptyBGView.updateUI()
        ibFilterButton.isEnabled = AppSession.manager.validSession
        AppSession.manager.validSession ? ibEmptyBGView.startActivityIndicator(with: "Fetching Chats...") : ibEmptyBGView.updateErrorText()

        viewModel.resetPage()
        getChats()
    }

    private func registerCell() {
        ibChatTableView.register(UINib(nibName: "InboxCell", bundle: nil), forCellReuseIdentifier: "inboxCellID")
    }

    private func updateRefresh() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh!!")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        ibChatTableView.addSubview(refreshControl)
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCellID") as? InboxCell else { return UITableViewCell() }

        cell.inboxModel = viewModel[indexPath.section]

        if viewModel.apiCallIndex == indexPath.section, viewModel.isMoreDataAvailable {
            viewModel.apiCallIndex += 10
            getChats()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chat = viewModel[indexPath.section] else { return }

        pushChatVC(for: chat)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section != 0 else { return 10.0 }

        return 10.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }

//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
////            viewModel.deleteObject(at: indexPath.section)
//            ibChatTableView.reloadData()
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
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

// MARK: - EmptyBGView Delegate
extension InboxViewController {
    override func didSelectRefresh() {
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
