//
//  ChatReplyView.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import UIKit

// MARK: - Chat Reply Delegate
protocol ChatReplyDelegate {
    func sendDidTapped(with chatText: String?)
    func updateAccessoryView(with height: CGFloat)
    func didShowKeyboard()
    func update(_ isTyping: Bool)
    func keyboardWillChange(_ notification: Notification)
}

class ChatReplyView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ibTextViewBGView: UIView!

    @IBOutlet weak var ibReplyTextView: UITextView!
    @IBOutlet weak var ibSendButton: UIButton!
    @IBOutlet weak var ibTopSendButton: UIButton!
    @IBOutlet weak var ibPlaceholderLabel: UILabel!

    @IBOutlet weak var ibTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ibTextViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var ibsendBottomConstraints: NSLayoutConstraint!
    
    private var prevTextViewRect: CGRect = CGRect.zero
    private let updateHeight: CGFloat = 20.0
    private var minTextViewHeight: CGFloat = 0.0
    private var maxTextViewHeight: CGFloat = 0.0

    var delegate: ChatReplyDelegate?
    var channelID: String?

    // MARK: - Init Method
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        addContentView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc func keyboardWillChange(notification: Notification) {
        delegate?.keyboardWillChange(notification)
    }

    // MARK: - Init Content View
    private func addContentView() {
        Bundle.main.loadNibNamed("ChatReplyView", owner: self, options: nil)
        addSubview(contentView)

        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = .clear

        ibReplyTextView.delegate = self
        /// Maximum height of TextView would be for 4 lines
        maxTextViewHeight = ibTextViewHeight.constant + 3*updateHeight
        minTextViewHeight = ibTextViewHeight.constant

        ibPlaceholderLabel.text = "Chat_Reply".localized()
        ibTextViewBottomConstraint.constant = Utility.shared.hasNotch ? 0.0 : -18.0
        ibsendBottomConstraints.constant = Utility.shared.hasNotch ? 0.0 : -18.0

        updateUI()
        updateSendButton(isEnable: false)
    }

    private func updateUI() {
        ibTextViewBGView.layer.masksToBounds = true
        ibTextViewBGView.layer.cornerRadius = 17.5
        ibTextViewBGView.layer.borderColor = UIColor.lightGray.cgColor
        ibTextViewBGView.layer.borderWidth = 1.0

        ibSendButton.layer.masksToBounds = true
        ibSendButton.layer.cornerRadius = 12.5
    }

    private func updateSendButton(isEnable status: Bool) {
        ibSendButton.isEnabled = status
        ibSendButton.alpha = status ? 1.0 : 0.3

        ibTopSendButton.isEnabled = status
        ibTopSendButton.alpha = status ? 1.0 : 0.3
    }
}

// MARK: - Action
extension ChatReplyView {
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.sendDidTapped(with: self?.ibReplyTextView.text.trimmingCharacters(in: .newlines))

            self?.ibReplyTextView.text = nil
            self?.updateSendButton(isEnable: false)
            self?.ibTextViewHeight.constant = self?.minTextViewHeight ?? 0.0
        }
    }
}

// MARK: - UITextViewDelegate
extension ChatReplyView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        ibTextViewBottomConstraint.constant = Utility.shared.hasNotch ? 0.0 : -18.0
        ibsendBottomConstraints.constant = Utility.shared.hasNotch ? 0.0 : -18.0

        delegate?.didShowKeyboard()
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let string = textView.text, let textRange = Range(range, in: string) {
            let updatedTextCount = string.replacingCharacters(in: textRange, with: text).count

            if updatedTextCount > 0, string.replacingCharacters(in: textRange, with: text) == " " {
                return false
            }
            if updatedTextCount > 0, string.replacingCharacters(in: textRange, with: text) == "\n" {
                return false
            }

            updateSendButton(isEnable: (updatedTextCount > 0))
            update(isTyping: (updatedTextCount > 0))
            ibPlaceholderLabel.isHidden = (updatedTextCount > 0)
        }

        resetTyping(after: 1.0)

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        let sizeToFitIn = CGSize(width: ibReplyTextView.bounds.size.width, height: ibReplyTextView.bounds.size.height)
        let newSize = ibReplyTextView.sizeThatFits(sizeToFitIn)

        if newSize.height <= maxTextViewHeight {
            ibReplyTextView.isScrollEnabled = false
            ibTextViewHeight.constant = newSize.height

            delegate?.updateAccessoryView(with: newSize.height)
        } else if newSize.height > 85.0 {
            ibReplyTextView.isScrollEnabled = true
            ibTextViewHeight.constant = maxTextViewHeight
        } else {
            ibReplyTextView.isScrollEnabled = true
        }
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        ibTextViewBottomConstraint.constant = Utility.shared.hasNotch ? 0.0 : -18.0
        ibsendBottomConstraints.constant = Utility.shared.hasNotch ? 0.0 : -18.0

        return true
    }
}

// MARK: - Update isTyping
extension ChatReplyView {
    private func resetTyping(after time: Double) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reset), object: nil)

        self.perform(#selector(reset), with: nil, afterDelay: time)
    }

    @objc func reset() {
        update(isTyping: false)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    private func update(isTyping: Bool) {
        delegate?.update(isTyping)
    }
}
