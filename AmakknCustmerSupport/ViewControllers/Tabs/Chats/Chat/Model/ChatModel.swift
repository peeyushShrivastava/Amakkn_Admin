//
//  ChatModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import Foundation

struct UserStatusModel: Codable {
    let state: String?
    let lastSeen: String?
}

struct ChatModel {
    let mID: String?
    let chatText: String?
    var headerTime = ""
    var sentTime = ""
    var timeStamp = ""
    let seenType: MessageSeenType?
    var hasSent = true

    init(_ chatAPIModel: ChatAPIModel?) {
        mID = chatAPIModel?.mId
        chatText = chatAPIModel?.text.trimmingCharacters(in: .newlines)
        seenType = MessageSeenType(rawValue: chatAPIModel?.seen ?? "0")
        hasSent = hasChatSent(for: chatAPIModel?.chatID ?? "")

        convertDates(for: chatAPIModel?.updatedDate)

        if let updatedTime = chatAPIModel?.updatedDate {
            timeStamp =  updatedTime
        }
    }

    /// Get Sent / Received Chat wrt chatID
    /// Condition: - If chatID is same as logged in UserID
    private func hasChatSent(for chatID: String) -> Bool {
        guard chatID == AppSession.manager.userID else { return false }

        return true
    }

    private mutating func convertDates(for timeStamp: String?) {
        guard let timeStamp = timeStamp else { return }

        let dateFormatter = DateFormatter()

        let date = Utility.shared.milliSecsToDate(from: timeStamp)

        if Calendar.current.isDateInToday(date) {
            dateFormatter.dateFormat = Utility.shared.isFormat24Hrs() ? "HH:mm" : "h:mm a"
            sentTime = dateFormatter.string(from: date)
            headerTime = "Chat_Today".localized()
        } else if Calendar.current.isDateInYesterday(date) {
            dateFormatter.dateFormat = Utility.shared.isFormat24Hrs() ? "HH:mm" : "h:mm a"
            sentTime = dateFormatter.string(from: date)
            headerTime = "Chat_yesterday".localized()
        } else if dateFallsInCurrentWeek(date: date) {
            dateFormatter.dateFormat = Utility.shared.isFormat24Hrs() ? "HH:mm" : "h:mm a"
            sentTime = dateFormatter.string(from: date)

            dateFormatter.dateFormat = "EEEE"
            headerTime = dateFormatter.string(from: date)
        } else if dateFallsInCurrentYear(date: date) {
            dateFormatter.dateFormat = Utility.shared.isFormat24Hrs() ? "HH:mm" : "h:mm a"
            sentTime = dateFormatter.string(from: date)

            dateFormatter.dateFormat = "EEE, dd MMM"
            headerTime = dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = Utility.shared.isFormat24Hrs() ? "HH:mm" : "h:mm a"
            sentTime = dateFormatter.string(from: date)

            dateFormatter.dateFormat = "dd MMM yyyy"
            headerTime = dateFormatter.string(from: date)
        }
    }

    private func dateFallsInCurrentWeek(date: Date) -> Bool {
        let currentWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: Date())
        let datesWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: date)

        return (currentWeek == datesWeek)
    }

    private func dateFallsInCurrentYear(date: Date) -> Bool {
        let currentYear = Calendar.current.component(Calendar.Component.year, from: Date())
        let datesYear = Calendar.current.component(Calendar.Component.year, from: date)

        return (currentYear == datesYear)
    }
}

struct ChatSectionModel {
    let title: String?
    let timeStamp: Date?
}

struct ChatResponseModel: Codable {
    let resCode: Int
    let response: ChatListModel?
    let resStr: String?
}

struct ChatListModel: Codable {
    let chatArray: [ChatInboxModel]?
    let totalCount: String?
}

struct ChatInboxModel: Codable {
    let senderID: String?
    let receiverID: String?
    let channelID: String?
    let propertyID: String?
    let chatID: String?

    let senderName: String?
    let receiverName: String?

    let senderAvatar: String?
    let receiverAvatar: String?
    let isVerified: String?

    let category: String?
    let propertyType: String?
    let propertyTypeName: String?
    let listedFor: String?

    let unreadCount: String?
    let lastMessage: String?
    let time: String?

    let photos: String?
    let defaultPrice: String?
    let address: String?

    let senderUserType: String?
    let receiverUserType: String?

    private enum CodingKeys: String, CodingKey {
        case senderID = "userId1"
        case receiverID = "userId2"
        case channelID = "channelId"
        case propertyID = "propertyId"
        case chatID = "chatId"

        case senderName = "userName1"
        case receiverName = "userName2"

        case senderAvatar = "userAvatar1"
        case receiverAvatar = "userAvatar2"
        case time = "updatedAt"

        case listedFor, unreadCount, isVerified
        case category, propertyType, propertyTypeName
        case photos, defaultPrice, address, lastMessage
        case senderUserType, receiverUserType
    }
}

// MARK: - Array Extension to get unique data list
extension Array {
    func unique<T: Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }

        return arrayOrdered
    }
}
