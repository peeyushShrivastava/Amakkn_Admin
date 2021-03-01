//
//  ChatViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import UIKit
import CoreData
import SDWebImage

class ChatViewController: UIViewController {
    @IBOutlet weak var ibChatCollectionView: UICollectionView!
    @IBOutlet var ibBottomView: ChatReplyView!
    @IBOutlet weak var ibPropertyInfoView: PropertyInfoView!

    @IBOutlet weak var ibCollectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var ibBotomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ibPropertyInfoViewHeight: NSLayoutConstraint!

    @IBOutlet var ibNavView: ChatNavView!
    var ibNavBarTitleView: UIView?
    var ibStatusLabel: UILabel?

    /// Private Constants
    private let maxWidth: CGFloat = 255.0
    private let maxHeight: CGFloat = 1000.0
    private let fontSize: CGFloat = 15.0
    private let heightCostraint: CGFloat = 45.0

    private var lastContentOffset: CGFloat = 0.0

    var subject = ""

    let viewModel = ChatViewModel()

    lazy var fetchedResultsController: NSFetchedResultsController<ChatAPIModel> = {
        let fetchRequest = NSFetchRequest<ChatAPIModel>(entityName:"ChatAPIModel")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "channelID", ascending: false)]

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: SocketIOManager.sharedInstance.dataProvider.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self

        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        /// Add Notifications for Background / Foreground update
        addNotifications()

        viewModel.delegate = self

        /// Update Bottom View Initial Data
        ibBottomView.delegate = self
        ibBottomView.channelID = viewModel.channelID

        updateInfoView()
        registerCell()
        updateNavUI()

        getChats()
        callAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil

        updateForRemoteNotif(state: true)

        SocketIOManager.sharedInstance.delegate = self

        SocketIOManager.sharedInstance.openSockets(with: viewModel.receiverID ?? "")
        SocketIOManager.sharedInstance.send(chatDict: ["text": "", "channelId": viewModel.channelID ?? "", "chatID": AppSession.manager.userID ?? ""])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        updateForRemoteNotif(state: false)
        removeNotification()
        ibNavView.stopTimer()

        /// Update isTyping State to false
        ibBottomView.reset()

        /// Disconnect Channel Socket
        SocketIOManager.sharedInstance.offChannelSocket()
    }

    /// Register ChatCell
    private func registerCell() {
        ibChatCollectionView.register(UINib(nibName: "ChatCell", bundle: nil), forCellWithReuseIdentifier: viewModel.cellID)
        ibChatCollectionView.register(UINib(nibName: "ChatSectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "chatSectionHeaderID")

        /// Stickey Header
        guard let layout = ibChatCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.sectionHeadersPinToVisibleBounds = true

        ibChatCollectionView.alwaysBounceVertical = true
//        ibChatCollectionView.keyboardDismissMode = .interactive
    }

    private func updateInfoView() {
        ibPropertyInfoView.isHidden = true
        ibPropertyInfoViewHeight.constant = 0.0
    }

    private func updateNewChat(with chatDict: [String: Any]?) {
        guard let chatDict = chatDict else { return }

        let chatModel = ChatAPIModel(context: fetchedResultsController.managedObjectContext)

        /// Update ChatModel with Context
        do {
            try chatModel.update(with: chatDict)
        } catch {
            // Error
        }

        /// Save Context
        do {
            try fetchedResultsController.managedObjectContext.save()
        } catch {
            // Error
        }
    }

    private func updateForRemoteNotif(state: Bool) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//
//        appDelegate.isChatOpen = state
    }
}

// MARK: - Get Chats
extension ChatViewController {
    private func getChats() {
        guard let channelID = viewModel.channelID else { return }

        let predicate = NSPredicate(format: "channelID = %@", channelID)
        fetchedResultsController.fetchRequest.predicate = predicate

        let results = fetchedResultsController.fetchedObjects?.filter({ $0.channelID == channelID })

        self.viewModel.update(chatList: results) { [weak self] in
            DispatchQueue.main.async {
                self?.ibChatCollectionView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.scrollCollectionToBottom()
            }
        }
    }

    private func scrollToBottomFrame() {
        let section = self.viewModel.sectionCount - 1
        guard section >= 0 else { return }

        let row = self.viewModel.cellCount(for: section) - 1
        let indexPath = IndexPath(item: row, section: section)

        guard let rect = self.ibChatCollectionView.layoutAttributesForItem(at: indexPath)?.frame else { return }

        self.ibChatCollectionView.scrollRectToVisible(rect, animated: false)
    }

    private func callAPI() {
        guard let channelID = viewModel.channelID else { return }

        SocketIOManager.sharedInstance.dataProvider.fetchChats(with: channelID) { [weak self] _ in
            DispatchQueue.main.async {
                self?.ibChatCollectionView.reloadData()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                
                self?.scrollCollectionToBottom()
            }
        }
    }

    private func scrollCollectionToBottom() {
        let section = viewModel.sectionCount - 1
        guard section >= 0 else { return }

        let row = viewModel.cellCount(for: section) - 1
        let indexPath = IndexPath(item: row, section: section)
        
        self.ibChatCollectionView.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.ibChatCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
}

// MARK: - Notification Center
extension ChatViewController {
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    private func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func didEnterBackground() {
        SocketIOManager.sharedInstance.offChannelSocket()
    }

    @objc func willEnterForeground() {
        SocketIOManager.sharedInstance.openSockets(with: viewModel.receiverID ?? "")
        SocketIOManager.sharedInstance.send(chatDict: ["text": "", "channelId": viewModel.channelID ?? "", "chatID": AppSession.manager.userID ?? ""])
    }
}

// MARK: - UICollectionView Delegate / Data Source
extension ChatViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sectionCount
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount(for: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let chatCell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.cellID, for: indexPath) as? ChatCell else { return UICollectionViewCell() }

        chatCell.chatModel = viewModel.getChatModel(at: indexPath)
        chatCell.updateCell(for: view.frame.width)

        return chatCell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "chatSectionHeaderID", for: indexPath) as? ChatSectionHeader else { return UICollectionReusableView() }

            /// Update Header Title
            headerView.update(title: viewModel.getSectionTitle(for: indexPath.section))

            return headerView
        default:
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return CGSize(width: collectionView.frame.width, height: viewModel.sectionHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ibBottomView.ibReplyTextView.resignFirstResponder()
        ibCollectionBottomConstraint.constant = 0.0
        ibBotomViewHeight.constant = 55.0
    }
}

// MARK: - UICollectionView FlowLayout Delegate
extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let model = viewModel.getChatModel(at: indexPath), let chatText = model.chatText else { return CGSize.zero }

        let size = CGSize(width: maxWidth, height: maxHeight)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: chatText).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], context: nil)

        return CGSize(width: view.frame.width, height: estimatedFrame.height + heightCostraint)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20.0, left: 0.0, bottom: 20.0, right: 0.0)
    }
}

// MARK: - Chat Reply Delegate
extension ChatViewController: ChatReplyDelegate {
    func sendDidTapped(with chatText: String?) {
        let _ = viewModel.sendMessage(with: chatText)
        self.ibChatCollectionView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollCollectionToBottom()
        }
    }

    func updateAccessoryView(with height: CGFloat) {
        ibBottomView.frame = CGRect(x: ibBottomView.frame.origin.x, y: ibBottomView.frame.origin.y, width: ibBottomView.frame.width, height: (ibBottomView.frame.height + height))
        ibBottomView.layoutIfNeeded()
    }

    func didShowKeyboard() {
        ibBotomViewHeight.constant = 35.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollCollectionToBottom()
        }
    }

    func update(_ isTyping: Bool) {
        viewModel.updateTyping(isTyping)
    }

    func keyboardWillChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        // Get duration of keyboard appearance/ disappearance animation
        let animationCurve = UIView.AnimationCurve(rawValue: (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 0)
        let animationOptions = UIView.AnimationOptions(rawValue: UInt(animationCurve?.rawValue ?? 0 | ((animationCurve?.rawValue ?? 0) << 16))) // Convert animation curve to animation option
        let animationDuration = TimeInterval((userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0)

        // Get the final size of the keyboard
        let keyboardEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect

        // Calculate the new bottom constraint, which is equal to the size of the keyboard
        let screen = UIScreen.main.bounds
        let newBottomConstraint = screen.size.height - (keyboardEndFrame?.origin.y ?? 0.0)

        // Keep old y content offset and height before they change
        let oldYContentOffset = ibChatCollectionView.contentOffset.y
        let oldCollectionViewHeight = ibChatCollectionView.bounds.size.height

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) { [weak self] in
            // Set the new bottom constraint
            if self?.ibCollectionBottomConstraint != nil {
                self?.ibCollectionBottomConstraint.constant = newBottomConstraint
            }
            // Request layout with the new bottom constraint
            self?.view.layoutIfNeeded()

            // Calculate the new y content offset
            let newCollectionViewHeight = self?.ibChatCollectionView.bounds.size.height
            let contentSizeHeight = self?.ibChatCollectionView.contentSize.height
            var newYContentOffset = oldYContentOffset - (newCollectionViewHeight ?? 0.0) + oldCollectionViewHeight

            // Prevent new y content offset from exceeding max, i.e. the bottommost part of the UICollectionView
            let possibleBottommostYContentOffset = (contentSizeHeight ?? 0.0) - (newCollectionViewHeight ?? 0.0)
            newYContentOffset = CGFloat(min(newYContentOffset, possibleBottommostYContentOffset))

            // Prevent new y content offset from exceeding min, i.e. the topmost part of the UITableView
            let possibleTopmostYContentOffset: CGFloat = 0
            newYContentOffset = max(possibleTopmostYContentOffset, newYContentOffset)

            // Create new content offset
            let newTableViewContentOffset = CGPoint(x: self?.ibChatCollectionView.contentOffset.x ?? 0.0, y: newYContentOffset)
            self?.ibChatCollectionView.contentOffset = newTableViewContentOffset
        } completion: { _ in }
    }
}

// MARK: - Custom TitleView
extension ChatViewController {
    private func updateNavUI() {
        if navigationItem.titleView == nil {
            ibNavBarTitleView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 50.0))
            ibNavBarTitleView?.backgroundColor = .clear

            navigationItem.titleView = ibNavBarTitleView

            ibNavBarTitleView?.addSubview(getView())
        }
    }

    private func getView() -> UIView {
        ibNavView.frame = ibNavBarTitleView?.bounds ?? .zero
        ibNavView.backgroundColor = .clear

        ibNavView.updateUI(with: viewModel.avatarURL, and: viewModel.title)
        ibNavView.update(receiverID: viewModel.receiverID)
        ibNavView.update(verified: viewModel.isUserVerified)
        ibNavView.delegate = self

        return ibNavView
    }
}

// MARK: - SocketIOManager Delegate
extension ChatViewController: SocketIOManagerDelegate {
    func receiver(isTyping: Bool) {
        ibNavView.updateStatus(isTyping)
    }

    func receiver(online status: Bool) {
        ibNavView.updateStatus(for: status)
    }

    func senderDidReceive(chatDict: [String: Any]) {
        updateNewChat(with: chatDict)
    }

    func updateSeen(for chatDict: [String : Any]) {
        guard let mID = chatDict["mId"] as? String else { return }

        let object = fetchedResultsController.fetchedObjects?.filter({ $0.mId == mID }).first

        object?.seen = MessageSeenType.seen.rawValue

        saveContext(with: object)
    }

    func updateSentTime(for chatDict: [String : Any]) {
        guard let mID = chatDict["mId"] as? String, let updatedDate = chatDict["updatedDate"] as? String else { return }

        let object = fetchedResultsController.fetchedObjects?.filter({ $0.mId == mID }).first

        object?.updatedDate = updatedDate

        saveContext(with: object)
    }

    func updateAllSeen() {
        guard let userID = AppSession.manager.userID, let channelID = viewModel.channelID else { return }
        guard let channelMsgs = fetchedResultsController.fetchedObjects?.filter({ $0.channelID == channelID }) else { return }

        let sentMsgs = channelMsgs.filter({ $0.chatID == userID })
        guard !sentMsgs.isEmpty else { return }

        let notSeenMsgs = sentMsgs.filter({ $0.seen != MessageSeenType.seen.rawValue })
        guard !notSeenMsgs.isEmpty else { return }

        let _ = notSeenMsgs.map { (model) -> ChatAPIModel? in
            /// Update context model with seen
            model.seen = MessageSeenType.seen.rawValue

            /// Update UI with seen
            self.viewModel.updateData(model) {
                DispatchQueue.main.async {
                    self.ibChatCollectionView.reloadData()
                }
            }

            return nil
        }

        /// Save Context
        do {
            try fetchedResultsController.managedObjectContext.save()
        } catch {
            // Error
        }
    }

    private func saveContext(with object: ChatAPIModel?) {
        do {
            try fetchedResultsController.managedObjectContext.save()
        } catch {
            // Error
        }

        viewModel.updateData(object) { [weak self] in
            self?.ibChatCollectionView.reloadData()
        }
    }
}

// MARK: - ViewModel Delegate
extension ChatViewController: ChatViewModelDelgate {
    func getChatData() -> [ChatAPIModel]? {
        return fetchedResultsController.fetchedObjects
    }
}

// MARK: - NSFetchedResults Controller Delegate
extension ChatViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                guard let model = anObject as? ChatAPIModel, !viewModel.isAvailable(model) else { return }

                viewModel.updateList(with: model) {
                    DispatchQueue.main.async {
                        self.ibChatCollectionView.reloadData()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.scrollCollectionToBottom()
                    }
                }
            default:
                // Do nothing
                break
        }
    }
}

// MARK: - NavView Delegate
extension ChatViewController: ChatNavViewDelegate {
    func userDidTapped() {
        guard let userProfileVC = UserDetailsViewController.instantiateSelf() else { return }

        userProfileVC.viewModel.userID = viewModel.receiverID
        userProfileVC.viewModel.updateDataSource(with: nil)

        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
}

// MARK: - Init Self
extension ChatViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .chat
    }
}
