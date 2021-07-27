//
//  NotificationHandler.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 28/12/20.
//

import Foundation
import UIKit

// MARK: - NotificationScreens Enum
enum NotificationScreen: String {
    case cs = "cs"
    case propertyDetails = "propertyAdded"
    case userDetails = "userAdded"
    case ticket = "ticket"
}

// MARK: - NotificationScreens Enum
enum AppTabs: Int {
    case inbox = 0
    case users
    case properties
    case abuse
    case more
}

// MARK: - Notification Thread Identifiers
struct NotifThreadIDs {
    static let inbox = "Amakkn_Inbox_ID"
}

// MARK: - Notification Summary Arguments
struct NotifSummaryArgs {
    static let inbox = "Inbox"
}

// MARK: - NotificationHandler Delegate
protocol AppNotificationDelegate {
    func didReceiveNotification(for ticketID: String?)
}

class NotificationHandler {
    static let manager = NotificationHandler()

    var delegate: AppNotificationDelegate?

    private init() { }
}

// MARK: - Handle Notification
extension NotificationHandler {
    func manageNotification(for notification: UNNotification) {
        let userInfo = notification.request.content.userInfo

        guard let aps = userInfo[AnyHashable("aps")] as? [AnyHashable: Any], let alert = aps[AnyHashable("alert")] as? [AnyHashable: Any] else { return }
        guard let title = alert[AnyHashable("")] as? String, let body = alert[AnyHashable("body")] as? String else { return }
        guard let screen = userInfo[AnyHashable("screen")] as? String, let screenType = NotificationScreen(rawValue: screen) else { return }

        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body

        switch screenType {
        case .cs:
            notificationContent.threadIdentifier = NotifThreadIDs.inbox
            notificationContent.summaryArgument = NotifSummaryArgs.inbox
        default: break
        }
    }

    func handleNotification(for response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo

        guard let aps = userInfo[AnyHashable("aps")] as? [AnyHashable: Any], let alert = aps[AnyHashable("alert")] as? [AnyHashable: Any] else { return }
        guard let _ = alert[AnyHashable("body")] as? String, let data = userInfo[AnyHashable("propertyOrUserId")] as? String else { return }
        guard let screen = userInfo[AnyHashable("screen")] as? String, let screenType = NotificationScreen(rawValue: screen) else { return }
        guard delegate == nil else { delegate?.didReceiveNotification(for: data); return }

        pushVCs(with: data, at: getTab(for: screenType))
    }

    private func getTab(for screenType: NotificationScreen) -> AppTabs {
        switch screenType {
            case .cs: return .inbox
            case .propertyDetails: return .properties
            case .userDetails: return .users
            case .ticket: return .more
        }
    }
}

// MARK: - Push to VCs
extension NotificationHandler {
    private func pushVCs(with data: String, at tab: AppTabs) {
        guard let window = UIApplication.shared.windows.first else { return }
        guard let tabBarController = window.rootViewController as? MainTabBarController else { return }

        tabBarController.selectedIndex = tab.rawValue

        guard let navController = tabBarController.viewControllers?[tab.rawValue] as? UINavigationController else { return }

        switch tab {
            case .inbox: break
            case .users: pushToUserDetailsVC(for: data, with: navController)
            case .properties: pushToPropertyDetailsVC(for: data, with: navController)
            case .abuse: break
            case .more: pushToTicketDetailsVC(for: data, with: navController)
        }
    }

    private func pushToPropertyDetailsVC(for propertyID: String, with navController: UINavigationController) {
        guard let rootController = navController.children.first as? PropertiesViewController else { return }
        guard let propertyDetailsVC = PropertyDetailsViewController.instantiateSelf() else { return }

        propertyDetailsVC.viewModel.update(with: propertyID)
        propertyDetailsVC.delegate = rootController

        rootController.navigationController?.pushViewController(propertyDetailsVC, animated: false)
    }

    private func pushToUserDetailsVC(for userID: String, with navController: UINavigationController) {
        guard let rootController = navController.children.first as? UsersViewController else { return }
        guard let userDetailsVC = UserDetailsViewController.instantiateSelf() else { return }

        userDetailsVC.viewModel.userID = userID
        userDetailsVC.viewModel.updateDataSource(with: nil)

        rootController.navigationController?.pushViewController(userDetailsVC, animated: false)
    }

    private func pushToTicketDetailsVC(for ticketID: String, with navController: UINavigationController) {
        guard let rootController = navController.children.first as? MoreViewController else { return }
        guard let ticketDetailsVC = TicketDetailsViewController.instantiateSelf() else { return }

        ticketDetailsVC.viewModel.updateTicket(ticketID)

        rootController.navigationController?.pushViewController(ticketDetailsVC, animated: false)
    }
}
