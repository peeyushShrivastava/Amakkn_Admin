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
}

// MARK: - Notification Thread Identifiers
struct NotifThreadIDs {
    static let inbox = "Amakkn_Inbox_ID"
}

// MARK: - Notification Summary Arguments
struct NotifSummaryArgs {
    static let inbox = "Inbox"
}

class NotificationHandler {
    static let manager = NotificationHandler()

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
        }
    }
}
