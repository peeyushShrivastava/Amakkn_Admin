//
//  TDSubmitFeedback.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 03/08/21.
//

import UIKit

class TDSubmitFeedback: UIView {
    @IBOutlet weak var ibLikeButton: UIButton!
    @IBOutlet weak var ibDislikeButton: UIButton!
    @IBOutlet weak var ibSubmitBUtton: UIButton!

    @IBOutlet weak var ibLikeImageView: UIImageView!
    @IBOutlet weak var ibDislikeImageView: UIImageView!
    
    @IBOutlet weak var ibCommentTitle: UILabel!
    @IBOutlet weak var ibCommentHolder: UIView!
    @IBOutlet weak var ibCommentTextView: UITextView!

    var feedback: TFeedbackModel? {
        didSet {
            updateUI()
            updateData()
        }
    }

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    func updateUI() {
        ibCommentHolder.layer.masksToBounds = true
        ibCommentHolder.layer.borderColor = AppColors.borderColor?.cgColor
        ibCommentHolder.layer.borderWidth = 0.5

        ibLikeImageView.image = UIImage(named: "likeInactive")
        ibDislikeImageView.image = UIImage(named: "dislikeInactive")

        ibCommentTextView.isUserInteractionEnabled = false
    }

    private func updateData() {
        guard let feedback = feedback, let status = feedback.isUserHappy else { return }

        switch status {
            case "0":
                ibDislikeImageView.image = UIImage(named: "dislikeActive")
                ibCommentTextView.text = feedback.feedbackText
            case "1":
                ibLikeImageView.image = UIImage(named: "likeActiveImage")
                ibCommentTextView.text = feedback.feedbackText
            default:
                // Do nothing
                break;
        }
    }
}
