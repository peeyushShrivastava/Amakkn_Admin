//
//  BaseViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 13/10/20.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        checkValidSession()
    }
}

// MARK: - Push VCs
extension BaseViewController: MainTabDelegate {
    @objc func scrollToTop() {
        // Override in Child VC
    }
}

// MARK: - Push VCs
extension BaseViewController {
    private func presentLoginVC() {
        guard let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") as? LoginViewController else { return }

        loginVC.delegate = self

        let navigationVC = UINavigationController(rootViewController: loginVC)
        navigationVC.modalPresentationStyle = .fullScreen

        present(navigationVC, animated: true, completion: nil)
    }
}

// MARK: - EmptyBGView Delegate
extension BaseViewController: EmptyBGViewDelegate {
    @objc func didSelectRefresh() {
        // Override in Child VC
    }
    
    func didSelectLogin() {
        presentLoginVC()
    }
}

// MARK: - Login Delegate
extension BaseViewController: LoginDelegate {
    @objc func loginSuccess() {
        // Override in Child VC
    }
}

// MARK: - Present Login VC
extension BaseViewController {
    private func checkValidSession() {
        guard !AppSession.manager.validSession else { return }

        presentLoginVC()
    }
}
