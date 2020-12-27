//
//  ChatNavView.swift
//  Amakkn
//
//  Created by Peeyush Shrivastava on 01/08/20.
//  Copyright © 2020 Amakkn.com. All rights reserved.
//

import UIKit
import Firebase

// MARK: - Chat Nav Delegate
protocol ChatNavViewDelegate {
    func userDidTapped()
}

class ChatNavView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ibAvatar: UIImageView!
    @IBOutlet weak var ibVerified: UIImageView!

    @IBOutlet weak var ibUserNameLabel: UILabel!
    @IBOutlet weak var ibTypingLabel: UILabel!
    @IBOutlet weak var ibNameInitialLabel: UILabel!

    private var receiverID: String?
    private weak var timer: Timer?
    private var userStatus: UserStatusModel? {
        didSet {
            updateStatusText()
        }
    }

    var delegate: ChatNavViewDelegate?

    // MARK: Init Method
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        addContentView()
    }
    
    // MARK: - Init Content View
    private func addContentView() {
        Bundle.main.loadNibNamed("ChatNavView", owner: self, options: nil)
        addSubview(contentView)

        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = .clear

        updateAvatarView()
    }

    
    private func updateAvatarView() {
        ibAvatar.layer.masksToBounds = true
        ibAvatar.layer.cornerRadius = 17.5
        ibAvatar.layer.borderColor = AppColors.borderColor?.cgColor
        ibAvatar.layer.borderWidth = 1.0
    }
}

// MARK: - Actions
extension ChatNavView {
    @IBAction func userTapped(_ sender: UIButton) {
        delegate?.userDidTapped()
    }
}

// MARK: - Public Methods
extension ChatNavView {
    func updateUI(with urlStr: String?, and name: String?) {
        ibUserNameLabel.text = name?.capitalized

        guard let urlStr = urlStr, let url = URL(string: urlStr) else {
            ibNameInitialLabel.isHidden = false
            ibNameInitialLabel.text = name?.first?.uppercased()

            return
        }

        ibAvatar.sd_setImage(with: url, placeholderImage: nil)
    }

    func update(verified: Bool) {
        ibVerified.isHidden = !verified
    }

    func update(receiverID: String?) {
        self.receiverID = receiverID

        getStatus()
    }

    func updateStatus(_ isTyping: Bool) {
        ibTypingLabel.text = isTyping ? "Chat_Typing".localized() : (SocketIOManager.sharedInstance.isUserOnline ? "Chat_Online".localized() : "\("Chat_last_Seen".localized()) \(userStatus?.lastSeen ?? "")")
    }

    func updateStatus(for online: Bool) {
        guard ibTypingLabel?.text != "Chat_Typing".localized() else { return }

        ibTypingLabel?.text = online ? "Chat_Online".localized() : "\("Chat_last_Seen".localized()) \(userStatus?.lastSeen ?? "")"
    }
}

// MARK: - Online Status
extension ChatNavView {
    func getStatus() {
        guard let receiverID = receiverID else { return }

        ChatNetworkManager.shared.getOnlineStatus(for: receiverID) { [weak self] statusModel in
            self?.userStatus = statusModel

            self?.startTimer()
        }
    }

    private func updateStatusText() {
        guard let statusModel = userStatus, let state = statusModel.state else { ibTypingLabel.text = "offline"; return }

        ibTypingLabel?.text = state == "1" ? "Chat_Online".localized() : "\("Chat_last_Seen".localized()) \(Utility.shared.convertDates(for: statusModel.lastSeen) ?? "")"
    }
}

// MARK: - ViewModel Delegate
extension ChatNavView {
    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.updateState()
        }
    }

    func stopTimer() {
        timer?.invalidate()
    }

    private func updateState() {
        getStatus()
    }
}
// MARK: - Configure Typing
extension ChatNavView {
    func configureTyping(for channelID: String?, and receiverID: String?) {
        
    }
}
