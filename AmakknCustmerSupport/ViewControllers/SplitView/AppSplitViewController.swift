//
//  AppSplitViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 03/10/21.
//

import UIKit

class AppSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        preferredDisplayMode = .secondaryOnly
    }
}

// MARK: - UISplitViewController
extension AppSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
            return .primary
      }
}
