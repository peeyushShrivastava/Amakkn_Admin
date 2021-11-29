//
//  CreateViolationViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 01/08/21.
//

import UIKit

class CreateViolationViewController: UIViewController {
    @IBOutlet weak var ibUserHolder: UIView!
    @IBOutlet weak var ibUserSelectButton: UIButton!
    @IBOutlet weak var ibCreateViolationButton: UIButton!

    @IBOutlet weak var ibMessageHolder: UIView!
    @IBOutlet weak var ibMessageTextView: UITextView!
    @IBOutlet weak var ibInfoButton: UIBarButtonItem!
    
    private let maxCharCount = 100

    let viewModel = CreateViolationViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        updateUI()
        updateCreateButton(for: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateUserData()
    }

    private func updateUI() {
        ibUserHolder.layer.masksToBounds = true
        ibMessageHolder.layer.masksToBounds = true

        ibUserHolder.layer.borderWidth = 1.0
        ibMessageHolder.layer.borderWidth = 1.0

        ibUserHolder.layer.borderColor = AppColors.borderColor?.cgColor
        ibMessageHolder.layer.borderColor = AppColors.borderColor?.cgColor
    }

    private func updateCreateButton(for state: Bool) {
        ibCreateViolationButton.isUserInteractionEnabled = state
        ibCreateViolationButton.alpha = state ? 1.0 : 0.5
    }

    private func update(user: SearchedUserModel?) {
        guard let user = user else { return }

        let title = "\(user.countryCode ?? "")-\(user.userPhone ?? "") (UserId: \(user.userID ?? ""))"
        ibUserSelectButton.setTitle(title, for: .normal)

        updateCreateButton(for: (ibMessageTextView.text.count > 0 && ibUserSelectButton.titleLabel?.text != nil))
    }

    func updateUserData() {
        ibUserSelectButton.setTitle(viewModel.userData, for: .normal)
    }
}

// MARK: - Button Actions
extension CreateViolationViewController {
    @IBAction func createViolationTapped(_ sender: UIButton) {
        viewModel.createViolation(with: ibMessageTextView.text)
    }

    @IBAction func selectUserTapped(_ sender: UIButton) {
        guard let usersVC = UsersViewController.instantiateSelf() else { return }

        usersVC.viewModel.isFromViolation = true
        usersVC.getUser = { [weak self] user in
            DispatchQueue.main.async {
                self?.update(user: user)
                self?.viewModel.update(user)
            }
        }

        navigationController?.pushViewController(usersVC, animated: true)
    }

    @IBAction func infoButtonTapped(_ sender: UIBarButtonItem) {
        guard let userDetailsVC = UserDetailsViewController.instantiateSelf() else { return }

        userDetailsVC.viewModel.userID = viewModel.userID
        userDetailsVC.viewModel.updateDataSource(with: nil)

        navigationController?.pushViewController(userDetailsVC, animated: true)
    }
}

// MARK: - UIAlertView
extension CreateViolationViewController {
    private func showAlert(for errorStr: String?) {
        let alertController = UIAlertController(title: errorStr, message: nil, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .cancel, handler: { [weak self] _ in
            guard self?.viewModel.isViolationCreated ?? false else { return }

            self?.navigationController?.popViewController(animated: true)
        }))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - ViewModel Delegate
extension CreateViolationViewController: TicketsListDelegate {
    func success() {
        showAlert(for: "A violation has been created successfully against User: \(viewModel.userID ?? "")")
    }

    func failed(with errorStr: String?) {
        showAlert(for: errorStr)
    }
}

// MARK: - UITextView Delegate Methods
extension CreateViolationViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else { ibMessageHolder.endEditing(true); return false }

        if let string = textView.text, let textRange = Range(range, in: string) {
            let updatedTextCount = string.replacingCharacters(in: textRange, with: text).count

            if updatedTextCount > maxCharCount {
                return false
            }
            if updatedTextCount > 0, string.replacingCharacters(in: textRange, with: text) == " " {
                return false
            }

            updateCreateButton(for: (updatedTextCount > 0 && ibUserSelectButton.titleLabel?.text != nil))
        }

        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
}

// MARK: - Init Self
extension CreateViolationViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .more
    }
}
