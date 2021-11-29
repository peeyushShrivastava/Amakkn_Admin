//
//  LoginViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 13/10/20.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var ibNoHolderView: UIView!
    @IBOutlet weak var ibPasswordHolderView: UIView!
    @IBOutlet var ibPickerHolderView: UIView!
    @IBOutlet var ibAccessoryView: UIView!

    @IBOutlet weak var ibCountryCodeTextField: UITextField!
    @IBOutlet weak var ibPhoneTextField: UITextField!
    @IBOutlet weak var ibPasswordTextField: UITextField!

    @IBOutlet weak var ibLoginButton: UIButton!
    @IBOutlet weak var ibNextButton: UIButton!

    @IBOutlet weak var ibPickerView: UIPickerView!

    var countryCodeList: [String] = [String]()
    var countryCodeDisplayList: [String] = [String]()
    var selectedCountryCode: String?
    var currentSelectedrow: Int  = 0
    var countryShortNameAndCode: [String] = [String]()

    private let viewModel = LoginViewModel()
    var delegate: LoginDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        updateLoginButton()
        updateDomainLists()
    }

    private func updateUI() {
        ibCountryCodeTextField.inputView = ibPickerHolderView
        ibCountryCodeTextField.inputAccessoryView = ibAccessoryView
        ibPhoneTextField.inputAccessoryView = ibAccessoryView
        ibPasswordTextField.inputAccessoryView = ibAccessoryView

        ibNoHolderView.semanticContentAttribute = .forceLeftToRight
    }

    private func updateLoginButton() {
        if !(ibCountryCodeTextField.text?.isEmpty ?? true),
           !(ibPasswordTextField.text?.isEmpty ?? true),
           !(ibPhoneTextField.text?.isEmpty ?? true) {
            ibLoginButton.isUserInteractionEnabled = true
            ibLoginButton.alpha = 1.0
        } else {
            ibLoginButton.isUserInteractionEnabled = false
            ibLoginButton.alpha = 0.5
        }
    }

    private func updateDomainLists() {
        guard let domains = AppUserDefaults.manager.getDomains() else { return }

        let _ = domains.map { domain -> Bool in
            let displayCodeText = "(\(domain.countryCode ?? "")) \(domain.countryName ?? "")"
            countryCodeDisplayList.append(displayCodeText)

            let shortNameText = "\(domain.countryShortCode ?? "") (\(domain.countryCode ?? ""))"
            countryShortNameAndCode.append(shortNameText)

            let codeText = "\(domain.countryCode ?? "")"
            countryCodeList.append(codeText)

            return true
        }

        selectedCountryCode = countryCodeList.first
        ibCountryCodeTextField.text = countryShortNameAndCode.first
    }
}

// MARK: - Navigation
extension LoginViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "otpSegueID",
            let destinationVC = segue.destination as? OTPViewController {

            destinationVC.delegate = self
            destinationVC.viewModel.updateData((phone: ibPhoneTextField.text, countryCode: selectedCountryCode, password:ibPasswordTextField.text))
        }
    }
}

// MARK: - Button Ation
extension LoginViewController {
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
//        dismiss(animated: true, completion: nil)
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        ibPhoneTextField.resignFirstResponder()
        ibPasswordTextField.becomeFirstResponder()
    }

    @IBAction func keyPadDismiss(_ sender: UIButton) {
        ibPhoneTextField.resignFirstResponder()
        ibPasswordTextField.resignFirstResponder()
        ibCountryCodeTextField.resignFirstResponder()
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        login()
    }
}

// MARK: - UIPickerView Delegate / DataSource
extension LoginViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryCodeDisplayList.count
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width - 40, height: 30))
        var rowString = String()
        rowString = countryCodeDisplayList[row]
        let myLabel = UILabel(frame: CGRect(x: 10, y: 0, width: pickerView.bounds.width - 90, height: 30))
        myLabel.font = UIFont(name:"System-Medium", size: 16.0)
        myLabel.textColor = UIColor(red: 88/255, green: 114/255, blue: 119/255, alpha: 1.0)
        myLabel.text = rowString
        myView.addSubview(myLabel)
        return myView
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ibCountryCodeTextField.text = countryShortNameAndCode[row]
        currentSelectedrow = row
        selectedCountryCode = countryCodeList[row]
    }
}

// MARK: - UITextField Delegate
extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            if textField == ibPasswordTextField {
                _ = text.replacingCharacters(in: textRange, with: string).trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                let updatedText = text.replacingCharacters(in: textRange, with: string).components(separatedBy: CharacterSet(charactersIn: "0123456789").inverted).joined(separator: "")
                guard updatedText.count < 13 else { return false }
            }
        }

        updateLoginButton()

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ibPasswordTextField {
            login()
        } else if textField == ibPhoneTextField {
            ibPhoneTextField.resignFirstResponder()
            ibPasswordTextField.becomeFirstResponder()
        }

        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == ibCountryCodeTextField {
//            self.getDomains()
        } else if textField == ibPasswordTextField {
            ibPasswordTextField.text = ""
        }

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField){
        animateViewMoving(up: true, moveValue: 58.0)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 58.0)
    }

    private func animateViewMoving(up: Bool, moveValue: CGFloat) {
        guard view.frame.size.height <= 568.0 else { return }

        let movement = up ? -moveValue : moveValue

        UIView.animate(withDuration: 0.3) { [weak self] in
            if let offSet = self?.view.frame.offsetBy(dx: 0.0, dy: movement) {
                self?.view.frame = offSet
            }
        }
    }
}

// MARK: - Login API Call
extension LoginViewController {
    private func login() {
        ibCountryCodeTextField.resignFirstResponder()
        ibPhoneTextField.resignFirstResponder()
        ibPasswordTextField.resignFirstResponder()

        guard let countryCode = selectedCountryCode, let phone = ibPhoneTextField.text, let pwd = ibPasswordTextField.text else { return }

        viewModel.login(with: countryCode, phone, and: pwd) { [weak self] in
            self?.performSegue(withIdentifier: "otpSegueID", sender: nil)
        } failureCallBack: { [weak self] (errorStr) in
            self?.showAlert(with: errorStr)
        }

//        viewModel.loginOld(with: countryCode, phone, and: pwd) { [weak self] in
//            // SocketIO Establish Connection
//            SocketIOManager.sharedInstance.establishConnection()
//            self?.loginSuccess()
//        } failureCallBack: { [weak self] (errorStr) in
//            self?.showAlert(with: errorStr)
//        }
    }

    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Login Delegate
extension LoginViewController: LoginDelegate {
    func loginSuccess() {
        delegate?.loginSuccess()
        dismiss(animated: true, completion: nil)
    }
}
