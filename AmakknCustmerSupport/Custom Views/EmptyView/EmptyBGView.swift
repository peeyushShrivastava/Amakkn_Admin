//
//  EmptyBGView.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 13/10/20.
//

import UIKit

// MARK: - EmptyBGView Delegate
protocol EmptyBGViewDelegate {
    func didSelectLogin()
    func didSelectRefresh()
}

class EmptyBGView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var ibErrorTextLabel: UILabel!
    @IBOutlet weak var ibActionButton: UIButton!
    @IBOutlet weak var ibActivityIndicator: UIActivityIndicatorView!
    
    var delegate: EmptyBGViewDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        addContentView()
    }

    // MARK: - Init Content View
    private func addContentView() {
        Bundle.main.loadNibNamed("EmptyBGView", owner: self, options: nil)
        addSubview(contentView)

        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = .clear
    }

    func updateUI() {
        let actionButtonText = AppSession.manager.validSession ? "Refresh" : "Login"
        ibActionButton.setTitle(actionButtonText, for: .normal)

        if !AppSession.manager.validSession {
            stopActivityIndicator()
        }
    }

    func updateErrorText() {
        ibActionButton.isHidden = false

        ibActivityIndicator.stopAnimating()

        ibErrorTextLabel.text = AppSession.manager.validSession ? "Data not available" : "You are not Logged-In."
    }

    func updateText() {
        ibActionButton.isHidden = true

        ibActivityIndicator.stopAnimating()

        ibErrorTextLabel.text = "Data not available"
    }

    func startActivityIndicator(with text: String?) {
        ibActionButton.isHidden = true

        ibErrorTextLabel.text = text

        ibActivityIndicator.startAnimating()
    }

    func stopActivityIndicator() {
        ibActivityIndicator.stopAnimating()
    }

    func update(message: String?) {
        ibActionButton.isHidden = true

        ibErrorTextLabel.text = message

        ibActivityIndicator.stopAnimating()
    }
}

// MARK: - Button Action
extension EmptyBGView {
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        AppSession.manager.validSession ? delegate?.didSelectRefresh() : delegate?.didSelectLogin()
    }
}
