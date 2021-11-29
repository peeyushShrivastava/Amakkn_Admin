//
//  OTPViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 02/09/21.
//

import UIKit

class OTPViewController: UIViewController {
    @IBOutlet weak var ibOTPTextField: UITextField!
    @IBOutlet weak var ibCounterLabel: UILabel!
    @IBOutlet weak var ibCounterSubLabel: UILabel!

    private var timer = Timer()
    private var counter = 120

    let viewModel = OTPViewModel()
    var delegate: LoginDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        ibOTPTextField.becomeFirstResponder()

        startTimer()
    }

    private func startTimer() {
        timer.invalidate()

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }

    @objc func timerAction() {
        counter -= 1

        ibCounterLabel.text = counter == 0 ? "OTP expired. Please resend the OTP." : "\(counter)"
        ibCounterSubLabel.text = counter == 0 ? "" : " sec(s) left..."

        let textColor = counter == 0 ?
            UIColor(red: 130.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0) :
            AppColors.selectedTitleTextColor
        ibCounterLabel.textColor = textColor

        if counter == 0 {
            timer.invalidate()
            counter = 120
        }
    }
}

// MARK: - Button Actions
extension OTPViewController {
    @IBAction func resendButtonTapped(_ sender: UIButton) {
        viewModel.login { [weak self] in
            DispatchQueue.main.async {
                self?.ibCounterLabel.text = "OTP sent successfully."
                self?.ibCounterLabel.textColor = AppColors.selectedTitleTextColor

                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    self?.startTimer()
                }
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.showAlert(with: errorStr)
            }
        }
    }
}

// MARK: - UITextField Delegate
extension OTPViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)

            if updatedText.count == 6 {
                verify(with: updatedText)
            }
        }

        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        ibOTPTextField.text = nil

        return true
    }
}

// MARK: - Login API Call
extension OTPViewController {
    private func verify(with otp: String) {
        ibOTPTextField.resignFirstResponder()

        viewModel.verify(OTP: otp) { [weak self] in
            // SocketIO Establish Connection
            SocketIOManager.sharedInstance.establishConnection()
            self?.delegate?.loginSuccess()

            self?.navigationController?.popViewController(animated: false)
        } failureCallBack: { (errorStr) in
            self.showAlert(with: errorStr)
        }
    }

    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}
