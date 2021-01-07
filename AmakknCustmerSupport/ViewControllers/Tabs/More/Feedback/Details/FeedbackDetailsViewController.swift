//
//  FeedbackDetailsViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 07/01/21.
//

import UIKit

class FeedbackDetailsViewController: UIViewController {
    @IBOutlet weak var ibTextView: UITextView!

    var feedback: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        ibTextView.text = feedback
    }
}
