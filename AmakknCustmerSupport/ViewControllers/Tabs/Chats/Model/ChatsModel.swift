//
//  ChatsModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import Foundation

struct InboxResponseModel: Codable {
    let chatArray: [ChatInboxModel]?
    let totalCount: String?
}

struct ChatInboxModel: Codable {
    let chatID: String?
    let channelID: String?
    let subjectID: String?

    let userName1: String?
    let userName2: String?

    let userAvatar1: String?
    let userAvatar2: String?

    let readByUser1: String?
    let readByUser2: String?

    let userID1: String?
    let userID2: String?

    let userType1: String?
    let userType2: String?

    let userPhone1: String?
    let userPhone2: String?

    let lastMessage: String?
    let subject: String?

    let createdAt: String?
    let updatedAt: String?

    private enum CodingKeys: String, CodingKey {
        case channelID = "channelId"
        case subjectID = "subjectId"
        case chatID = "chatId"
        case userID1 = "userId1"
        case userID2 = "userId2"
        case userName1, userName2
        case userAvatar1, userAvatar2
        case readByUser1, readByUser2
        case userType1, userType2
        case userPhone1, userPhone2
        case lastMessage, subject
        case createdAt, updatedAt
    }
}

struct ChatSubjectModel: Codable {
    let subjectID: String?
    let adminID: String?
    let subject: String?

    private enum CodingKeys: String, CodingKey {
        case subjectID = "subjectId"
        case adminID = "adminId"
        case subject
    }
}
