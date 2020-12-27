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
}

// MARK: - Push VCs
extension BaseViewController {
    private func presentLoginVC() {
        guard let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") as? LoginViewController else { return }

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
