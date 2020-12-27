//
//  SendUserViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 24/12/20.
//

import UIKit

class SendUserViewController: UIViewController {
    @IBOutlet weak var ibTitleTextField: UITextField!
    @IBOutlet weak var ibBodyTextField: UITextField!
    @IBOutlet weak var ibSendButton: UIButton!
    @IBOutlet weak var ibDoneButton: UIButton!
    @IBOutlet var ibAccessoryView: UIView!

    let maxCharLength = 100
    var userID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        updateSendButton(with: false)
        updateAccessoryView()
    }

    private func updateAccessoryView() {
        ibTitleTextField.inputAccessoryView = ibAccessoryView
        ibBodyTextField.inputAccessoryView = ibAccessoryView
    }

    private func updateSendButton(with status: Bool) {
        ibSendButton.isEnabled = status
        ibSendButton.alpha = status ? 1.0 : 0.5
    }
}

// MARK: - Button Actions
extension SendUserViewController {
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        ibTitleTextField.resignFirstResponder()
        ibBodyTextField.resignFirstResponder()

        sendNotification()
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        ibTitleTextField.resignFirstResponder()
        ibBodyTextField.resignFirstResponder()
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        if sender.tag == 1 {
            ibTitleTextField.resignFirstResponder()
            ibBodyTextField.becomeFirstResponder()
        } else {
            ibTitleTextField.resignFirstResponder()
            ibBodyTextField.resignFirstResponder()

            sendNotification()
        }
    }
}

// MARK: - UITextField Delegate
extension SendUserViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == ibTitleTextField {
            ibDoneButton.setTitle("Next", for: .normal)
            ibDoneButton.tag = 1

            ibBodyTextField.resignFirstResponder()
        } else {
            ibDoneButton.setTitle("Done", for: .normal)
            ibDoneButton.tag = 2

            ibTitleTextField.resignFirstResponder()
        }

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let textRange = Range(range, in: text) else { return false }

        let updatedString = text.replacingCharacters(in: textRange, with: string)

        updateSendButton(with: updatedString.count > 0)

        return updatedString.count <= maxCharLength
    }
}

// MARK: - API Call
extension SendUserViewController {
    private func sendNotification() {
        guard let userID = userID, let title = ibTitleTextField.text, let body = ibBodyTextField.text else { return }

        updateUI(with: false)

        UsersNetworkManager.shared.sendNotification(for: userID, title, body) { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI(with: true)
                self?.showPopUp(with: "Notification Send successfully!!")
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.updateUI(with: true)
                self?.showAlert(with: errorStr)
            }
        }
    }

    private func updateUI(with state: Bool) {
        ibSendButton.isEnabled = state
        ibSendButton.alpha = state ? 1.0 : 0.5

        let title = state ? "Send" : "Sending notification..."
        ibSendButton.setTitle(title, for: .normal)

        ibTitleTextField.text = nil
        ibBodyTextField.text = nil

        ibTitleTextField.isUserInteractionEnabled = state
        ibBodyTextField.isUserInteractionEnabled = state
    }
}

// MARK: - Alert View
extension SendUserViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    private func showPopUp(with msg: String?) {
        let alertController = UIAlertController(title: nil, message: msg, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))

        present(alertController, animated: true, completion: nil)
    }
}
