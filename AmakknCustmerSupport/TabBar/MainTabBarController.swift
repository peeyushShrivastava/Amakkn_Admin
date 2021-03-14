//
//  MainTabBarController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 17/12/20.
//

import UIKit

// MARK: - Main Tab Delegate
protocol MainTabDelegate {
    func scrollToTop()
}

class MainTabBarController: UITabBarController {

    var tabDelegate: MainTabDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - TabbarController delegate Methods
extension MainTabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if tabBar.selectedItem?.tag == Utility.shared.getSelectedTab() {
            tabDelegate?.scrollToTop()
        }
        Utility.shared.updateSelectedTab(with: tabBar.selectedItem?.tag)
    }
}
