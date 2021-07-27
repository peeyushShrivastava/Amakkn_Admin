//
//  TDCustomView.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import UIKit

// MARK: - TDCustomView Delegate
protocol TDCustomViewDelegate {
    func sendDidTapped(with comment: String?, for statusID: String?)
    func addImage(for sender: UIButton, and statusID: String?)
    func viewImage(for images: [String]?)
    func changeStatusDidTapped(for status: String?, and statusID: String?)
}

class TDCustomView: UIView {
    @IBOutlet weak var ibStatusTick: UIImageView!
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibCommentHolder: UIView!
    @IBOutlet weak var ibAllCommentsHolder: UIView!

    @IBOutlet weak var ibImage1View: UIImageView!
    @IBOutlet weak var ibImage2View: UIImageView!
    @IBOutlet weak var ibImage3View: UIImageView!
    @IBOutlet weak var ibImage4View: UIImageView!
    @IBOutlet weak var ibImage5View: UIImageView!

    @IBOutlet weak var imageHolderHeight: NSLayoutConstraint!
    @IBOutlet weak var ibCommentTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var ibImageHolder: UIView!
    @IBOutlet weak var ibPlaceHolder: UILabel!
    
    @IBOutlet weak var ibSendButton: UIButton!
    @IBOutlet weak var ibCommentTextView: UITextView!
    @IBOutlet weak var ibStatusChangeButton: UIButton!
    
    /// Private Constants
    private let maxWidth: CGFloat = 255.0
    private let maxHeight: CGFloat = 1000.0
    private let fontSize: CGFloat = 15.0
    private let widthCostraint: CGFloat = 8.0
    private let heightCostraint: CGFloat = 20.0
    private let cornerRadius: CGFloat = 15.0
    private let bubbleColor: UIColor = UIColor(red: 124.0/255.0, green: 139.0/255.0, blue: 206.0/255.0, alpha: 1.0)
    private var yAxix: CGFloat = 0.0
    private var prevHeight: CGFloat = 0.0

    private let maxCharCount = 100
    private var images: [String]?

    /// Ticket Model
    var ticketModel: TicketDetails? {
        didSet {
            updateUI()
        }
    }

    var delegate: TDCustomViewDelegate?

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    private func updateCommentView() {
        ibCommentHolder.semanticContentAttribute = .forceLeftToRight
        ibCommentHolder.isHidden = ticketModel?.isActive == "-1"
        ibStatusChangeButton.isHidden = ticketModel?.isActive == "-1"

        ibCommentHolder.layer.masksToBounds = true
        ibCommentHolder.layer.borderWidth = 1.0
        ibCommentHolder.layer.borderColor = AppColors.borderColor?.cgColor

        updateComments()
        updateSendButtonFor(state: false)
    }

    private func updateUI() {
        images = getImages()

        updateCommentView()
        updateImages()

        let dateInMilliSec = Utility.shared.dateStrInMilliSecs(dateStr: ticketModel?.createdAt)
        let dateStr = Utility.shared.convertDates(with: dateInMilliSec)
        ibTitleLabel.text = "\(ticketModel?.statusName ?? "") \(dateStr ?? "")"
        ibPlaceHolder.text = "Add comment"
    }

    private func getImages() -> [String]? {
        let images = ticketModel?.images?.compactMap({ $0.image })

        return images
    }

    @IBAction func statusChanged(_ sender: UIButton) {
        delegate?.changeStatusDidTapped(for: ticketModel?.status, and: ticketModel?.statusId)
    }
}

// MARK: - Send Comments
extension TDCustomView {
    private func updateSendButtonFor(state: Bool) {
        ibSendButton.isEnabled = state
        ibSendButton.alpha = state ? 1.0 : 0.5

        ibPlaceHolder.isHidden = state
    }

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard ibCommentTextView.text.count > 0 else { return }

        DispatchQueue.main.async { [weak self] in
            self?.delegate?.sendDidTapped(with: self?.ibCommentTextView.text.trimmingCharacters(in: .newlines), for: self?.ticketModel?.statusId)

            self?.ibCommentTextView.text = nil
            self?.updateSendButtonFor(state: false)
        }
    }
}

// MARK: - UITextView Delegate Methods
extension TDCustomView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else { ibCommentTextView.endEditing(true); return false }

        if let string = textView.text, let textRange = Range(range, in: string) {
            let updatedTextCount = string.replacingCharacters(in: textRange, with: text).count

            if updatedTextCount > maxCharCount {
                return false
            }
            if updatedTextCount > 0, string.replacingCharacters(in: textRange, with: text) == " " {
                return false
            }

            updateSendButtonFor(state: (updatedTextCount > 0))
        }

        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
}

// MARK: - Image Button Action
extension TDCustomView {
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        switch sender.tag {
            case 1:
                guard let image = ibImage1View.image else { return }
                image == UIImage(named: "icRoomsPlus") ? delegate?.addImage(for: sender, and: ticketModel?.statusId) : delegate?.viewImage(for: images)
            case 2:
                guard let image = ibImage2View.image else { return }
                image == UIImage(named: "icRoomsPlus") ? delegate?.addImage(for: sender, and: ticketModel?.statusId) : delegate?.viewImage(for: images)
            case 3:
                guard let image = ibImage3View.image else { return }
                image == UIImage(named: "icRoomsPlus") ? delegate?.addImage(for: sender, and: ticketModel?.statusId) : delegate?.viewImage(for: images)
            case 4:
                guard let image = ibImage4View.image else { return }
                image == UIImage(named: "icRoomsPlus") ? delegate?.addImage(for: sender, and: ticketModel?.statusId) : delegate?.viewImage(for: images)
            case 5:
                guard let image = ibImage5View.image else { return }
                image == UIImage(named: "icRoomsPlus") ? delegate?.addImage(for: sender, and: ticketModel?.statusId) : delegate?.viewImage(for: images)
            default:
                return
        }
    }
}

// MARK: - Comments UI
extension TDCustomView {
    private func updateComments() {
        guard let comments = ticketModel?.comments, comments.count > 0 else { return }

        for (index, comment) in comments.enumerated() {
            guard let text = comment.text else { return }

            /// Calculate estimated frame for Chat Bubble / Text label
            let size = CGSize(width: maxWidth, height: maxHeight)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], context: nil)

            /// Update Frames
            updateBubbleFrame(for: comment, with: estimatedFrame, at: index)
            updateLabelFrame(for: comment, with: estimatedFrame, at: index)
        }
    }

    private func updateLabelFrame(for comment: DetailsComment, with estimatedFrame: CGRect, at index: Int) {
        let hasSent = comment.userID == AppSession.manager.userID

        let viewWidth = ibAllCommentsHolder.frame.width
        var labelAxisX: CGFloat = 0.0
        var labelWidth: CGFloat = 0.0

        if Utility.shared.selectedLanguage == .english {
            labelAxisX = hasSent ? (viewWidth - estimatedFrame.width - (12*widthCostraint)) : widthCostraint
            labelWidth = hasSent ? (estimatedFrame.width) : (estimatedFrame.width + (2*widthCostraint))
        } else {
            labelAxisX = !hasSent ? (viewWidth - estimatedFrame.width - (12*widthCostraint)) : widthCostraint
            labelWidth = !hasSent ? (estimatedFrame.width) : (estimatedFrame.width + (2*widthCostraint))
        }

        let ibTextlabel = UILabel()
        ibTextlabel.numberOfLines = 0
        ibTextlabel.textColor = .white
        ibTextlabel.font = UIFont.systemFont(ofSize: 15.0)
        ibTextlabel.textAlignment = Utility.shared.selectedLanguage == .english ? .natural : .left

        ibTextlabel.frame = CGRect(x: labelAxisX, y: yAxix, width: labelWidth, height: estimatedFrame.height + heightCostraint)
        ibTextlabel.text = comment.text

        ibAllCommentsHolder.addSubview(ibTextlabel)
    }

    private func updateBubbleFrame(for comment: DetailsComment, with estimatedFrame: CGRect, at index: Int) {
        let hasSent = comment.userID == AppSession.manager.userID

        let viewWidth = ibAllCommentsHolder.frame.width
        var bubbleAxisX: CGFloat = 0.0
        var bubbleWidth: CGFloat = 0.0
        var maskedCorners: CACornerMask = [.layerMaxXMaxYCorner]
        var bubbleBGColor: UIColor = .clear

        if Utility.shared.selectedLanguage == .english {
            bubbleAxisX = hasSent ? (viewWidth - estimatedFrame.width - (13*widthCostraint)) : 0.0
            bubbleWidth = hasSent ? (estimatedFrame.width + (2*widthCostraint)) : (estimatedFrame.width + (3*widthCostraint))
            maskedCorners = hasSent ? [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner] : [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
            bubbleBGColor = hasSent ? bubbleColor : .lightGray
        } else {
            bubbleAxisX = !hasSent ? (viewWidth - estimatedFrame.width - (13*widthCostraint)) : 0.0
            bubbleWidth = !hasSent ? (estimatedFrame.width + (2*widthCostraint)) : (estimatedFrame.width + (2*widthCostraint))
            maskedCorners = !hasSent ? [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner] : [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
            bubbleBGColor = hasSent ? bubbleColor : .lightGray
        }

        let ibBubbleView = UIView()
        let axixY: CGFloat = index == 0 ? 0.0 : (yAxix + prevHeight + 40.0)
        yAxix = axixY
        prevHeight = estimatedFrame.height

        ibBubbleView.frame = CGRect(x: bubbleAxisX, y: yAxix, width: bubbleWidth, height: estimatedFrame.height + heightCostraint)
        ibBubbleView.updateCornerRadius(forMaskedCorners: maskedCorners, withRadius: cornerRadius)
        ibBubbleView.backgroundColor = bubbleBGColor

        if ticketModel?.isActive == "1" {
            ibCommentTopConstraints.constant = yAxix + ibBubbleView.frame.height + 20.0
        }

        ibAllCommentsHolder.addSubview(ibBubbleView)
    }
}

// MARK: - Images UI
extension TDCustomView {
    private func updateImages() {
        guard let images = ticketModel?.images else { return }

        imageHolderHeight.constant = ticketModel?.images?.count == 0 ? (ticketModel?.isActive == "-1" ? 0.0 : 50.0) : 50.0
        ibImageHolder.isHidden = (ticketModel?.images?.count == 0 && ticketModel?.isActive == "-1")

        for (index, image) in images.enumerated() {
            imagesUI(for: image, at: index)
        }

        if ticketModel?.isActive == "1" {
            imagesUI(for: nil, at: images.count)
        }
    }
    
    private func imagesUI(for image: DetailsImage?, at index: Int) {
        switch index {
            case 0:
                ibImage1View.image = nil
                ibImage1View.layer.masksToBounds = true
                ibImage1View.layer.borderWidth = 1.0
                ibImage1View.layer.borderColor = AppColors.borderColor?.cgColor

                if image == nil {
                    ibImage1View.image = UIImage(named: "icRoomsPlus")
                } else {
                    ibImage1View.sd_setImage(with: URL(string: image?.image ?? ""), placeholderImage: UIImage(named: "PropertyDetailFloorPlanImagePlaceHolder"))
                }
            case 1:
                ibImage2View.image = nil
                ibImage2View.layer.masksToBounds = true
                ibImage2View.layer.borderWidth = 1.0
                ibImage2View.layer.borderColor = AppColors.borderColor?.cgColor

                if image == nil {
                    ibImage2View.image = UIImage(named: "icRoomsPlus")
                } else {
                    ibImage2View.sd_setImage(with: URL(string: image?.image ?? ""), placeholderImage: UIImage(named: "PropertyDetailFloorPlanImagePlaceHolder"))
                }
            case 2:
                ibImage3View.image = nil
                ibImage3View.layer.masksToBounds = true
                ibImage3View.layer.borderWidth = 1.0
                ibImage3View.layer.borderColor = AppColors.borderColor?.cgColor

                if image == nil {
                    ibImage3View.image = UIImage(named: "icRoomsPlus")
                } else {
                    ibImage3View.sd_setImage(with: URL(string: image?.image ?? ""), placeholderImage: UIImage(named: "PropertyDetailFloorPlanImagePlaceHolder"))
                }
            case 3:
                ibImage4View.image = nil
                ibImage4View.layer.masksToBounds = true
                ibImage4View.layer.borderWidth = 1.0
                ibImage4View.layer.borderColor = AppColors.borderColor?.cgColor

                if image == nil {
                    ibImage4View.image = UIImage(named: "icRoomsPlus")
                } else {
                    ibImage4View.sd_setImage(with: URL(string: image?.image ?? ""), placeholderImage: UIImage(named: "PropertyDetailFloorPlanImagePlaceHolder"))
                }
            case 4:
                ibImage5View.image = nil
                ibImage5View.layer.masksToBounds = true
                ibImage5View.layer.borderWidth = 1.0
                ibImage5View.layer.borderColor = AppColors.borderColor?.cgColor

                if image == nil {
                    ibImage5View.image = UIImage(named: "icRoomsPlus")
                } else {
                    ibImage5View.sd_setImage(with: URL(string: image?.image ?? ""), placeholderImage: UIImage(named: "PropertyDetailFloorPlanImagePlaceHolder"))
                }
            default:
            /// Do nothing
            break
        }
    }
}
