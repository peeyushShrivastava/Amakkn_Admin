//
//  ChatAPIModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import Foundation
import CoreData

class ChatAPIModel: NSManagedObject {
    @NSManaged var chatID: String
    @NSManaged var channelID: String
    @NSManaged var userName: String
    @NSManaged var updatedDate: String
    @NSManaged var receiverUID: String
    @NSManaged var seen: String
    @NSManaged var receiver: String
    @NSManaged var text: String
    @NSManaged var mId: String

    func update(with jsonDictionary: [String: Any]) throws {
        guard let chatID = jsonDictionary["chatID"] as? String,
            let channelID = jsonDictionary["channelId"] as? String,
            let receiverUID = jsonDictionary["receiverUid"] as? String,
            let receiver = jsonDictionary["receiver"] as? String,
            let userName = jsonDictionary["userName"] as? String,
            let text = jsonDictionary["text"] as? String,
            let seen = jsonDictionary["seen"] as? String,
            let mID = jsonDictionary["mId"] as? String,
            let updatedDate = jsonDictionary["updatedDate"] as? String
            else {
                throw NSError(domain: "", code: 100, userInfo: nil)
            }

        self.chatID = chatID
        self.channelID = channelID
        self.receiverUID = receiverUID
        self.receiver = receiver
        self.userName = userName
        self.text = text
        self.updatedDate = updatedDate
        self.seen = seen
        self.mId = mID
    }
}
