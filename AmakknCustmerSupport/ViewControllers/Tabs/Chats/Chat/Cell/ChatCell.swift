//
//  ChatCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import UIKit

class ChatCell: UICollectionViewCell {
    @IBOutlet weak var ibBubbleView: UIView!
    @IBOutlet weak var ibTextlabel: UILabel!

    @IBOutlet weak var ibSenderDateLabel: UILabel!
    @IBOutlet weak var ibReceiverDateLabel: UILabel!

    /// Private Constants
    private let maxWidth: CGFloat = 255.0
    private let maxHeight: CGFloat = 1000.0
    private let fontSize: CGFloat = 15.0
    private let widthCostraint: CGFloat = 8.0
    private let heightCostraint: CGFloat = 20.0
    private let cornerRadius: CGFloat = 15.0
    private let bubbleColor: UIColor = UIColor(red: 124.0/255.0, green: 139.0/255.0, blue: 206.0/255.0, alpha: 1.0)

    /// Chat Model
    var chatModel: ChatModel? {
        didSet {
            updateChatText()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func updateChatText() {
        ibTextlabel.text = chatModel?.chatText
        ibTextlabel.numberOfLines = 0
    }
}

// MARK: - Update Chat Cell
extension ChatCell {
    func updateCell(for viewWidth: CGFloat) {
        guard let model = chatModel, let chatText = model.chatText else { return }

        /// Calculate estimated frame for Chat Bubble / Text label
        let size = CGSize(width: maxWidth, height: maxHeight)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: chatText).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], context: nil)

        /// Update Frames
        updateLabelFrame(for: viewWidth, with: estimatedFrame)
        updateBubbleFrame(for: viewWidth, with: estimatedFrame)

        updateDates()
    }

    private func updateLabelFrame(for viewWidth: CGFloat, with estimatedFrame: CGRect) {
        guard let model = chatModel else { return }

        var labelAxisX: CGFloat = 0.0
        var labelWidth: CGFloat = 0.0

        labelAxisX = model.hasSent ? (viewWidth - estimatedFrame.width - (4*widthCostraint)) : (3*widthCostraint)
        labelWidth = model.hasSent ? (estimatedFrame.width + (2*widthCostraint)) : (estimatedFrame.width + (2*widthCostraint))

        if Utility.shared.selectedLanguage == .english {
            labelAxisX = model.hasSent ? (viewWidth - estimatedFrame.width - (4*widthCostraint)) : (3*widthCostraint)
            labelWidth = model.hasSent ? (estimatedFrame.width + (2*widthCostraint)) : (estimatedFrame.width + (2*widthCostraint))
        } else {
            labelAxisX = !model.hasSent ? (viewWidth - estimatedFrame.width - (4*widthCostraint)) : (3*widthCostraint)
            labelWidth = !model.hasSent ? (estimatedFrame.width + (2*widthCostraint)) : (estimatedFrame.width + (2*widthCostraint))
        }

        ibTextlabel.textColor = .white
        ibTextlabel.textAlignment = Utility.shared.selectedLanguage == .english ? .natural : .left
        ibTextlabel.frame = CGRect(x: labelAxisX, y: 0.0, width: labelWidth, height: estimatedFrame.height + heightCostraint)
    }

    private func updateBubbleFrame(for viewWidth: CGFloat, with estimatedFrame: CGRect) {
        guard let model = chatModel else { return }

        var bubbleAxisX: CGFloat = 0.0
        var bubbleWidth: CGFloat = 0.0
        var maskedCorners: CACornerMask = [.layerMaxXMaxYCorner]
        var bubbleBGColor: UIColor = .clear

        if Utility.shared.selectedLanguage == .english {
            bubbleAxisX = model.hasSent ? (viewWidth - estimatedFrame.width - (5*widthCostraint)) : (2*widthCostraint)
            bubbleWidth = model.hasSent ? (estimatedFrame.width + (3*widthCostraint)) : (estimatedFrame.width + (3*widthCostraint))
            maskedCorners = model.hasSent ? [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner] : [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
            bubbleBGColor = model.hasSent ? bubbleColor : .lightGray
        } else {
            bubbleAxisX = !model.hasSent ? (viewWidth - estimatedFrame.width - (5*widthCostraint)) : (2*widthCostraint)
            bubbleWidth = !model.hasSent ? (estimatedFrame.width + (3*widthCostraint)) : (estimatedFrame.width + (2*widthCostraint))
            maskedCorners = !model.hasSent ? [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner] : [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
            bubbleBGColor = model.hasSent ? bubbleColor : .lightGray
        }

        ibBubbleView.frame = CGRect(x: bubbleAxisX, y: 0.0, width: bubbleWidth, height: estimatedFrame.height + heightCostraint)
        ibBubbleView.updateCornerRadius(forMaskedCorners: maskedCorners, withRadius: cornerRadius)
        ibBubbleView.backgroundColor = bubbleBGColor
    }

    private func updateDates() {
        guard let model = chatModel else { return }

        ibReceiverDateLabel.isHidden = model.hasSent
        ibSenderDateLabel.isHidden = !model.hasSent

        ibReceiverDateLabel.text = model.hasSent ? "" : model.sentTime

        let dateText = model.seenType == .seen ? "\("Chat_Read".localized())\(model.sentTime)" : "\("Chat_Delivered".localized())\(model.sentTime)"
        ibSenderDateLabel.text = model.hasSent ? dateText : ""
    }
}

// MARK: UIView Extension
extension UIView {
    func updateCornerRadius(forMaskedCorners corners: CACornerMask, withRadius radius: CGFloat ) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = corners
    }
}
