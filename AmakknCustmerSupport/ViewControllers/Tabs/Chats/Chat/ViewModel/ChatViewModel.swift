//
//  ChatViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import Foundation
import UIKit

// MARK: ChatViewModel Delegate
protocol ChatViewModelDelgate {
    func getChatData() -> [ChatAPIModel]?
}

class ChatViewModel {
    private var chatInboxModel: ChatInboxModel?
    private var chatModelList: [ChatModel]?
    private var sectionModelList: [ChatSectionModel]?
    private var sectionDataList = [String: [ChatModel]?]()

    var delegate: ChatViewModelDelgate?

    var cellID: String {
        return "chatCellID"
    }

    var sectionCount: Int {
        return sectionModelList?.count ?? 0
    }

    var sectionHeight: CGFloat {
        return 30.0
    }

    var channelID: String? {
        return chatInboxModel?.channelID
    }

    var propertyID: String? {
        return chatInboxModel?.propertyID
    }

    var totalChatsCount: Int {
        return chatModelList?.count ?? 0
    }

    var userName: String? {
        guard AppSession.manager.userID == chatInboxModel?.senderID else { return chatInboxModel?.receiverName }

        return chatInboxModel?.senderName
    }

    var title: String? {
        guard AppSession.manager.userID == chatInboxModel?.senderID else { return chatInboxModel?.senderName }

        return chatInboxModel?.receiverName
    }

    var avatarURL: String? {
        guard AppSession.manager.userID == chatInboxModel?.senderID else { return chatInboxModel?.senderAvatar }

        return chatInboxModel?.receiverAvatar
    }

    var receiverID: String? {
        guard AppSession.manager.userID == chatInboxModel?.senderID else { return chatInboxModel?.senderID }

        return chatInboxModel?.receiverID
    }

    var receiverUserType: String? {
        guard AppSession.manager.userID == chatInboxModel?.senderID else { return chatInboxModel?.senderUserType }

        return chatInboxModel?.receiverUserType
    }

    var isUserVerified: Bool {
        return chatInboxModel?.isVerified == "2"
    }

    var propertyInfo: (imageURL: String?, type: String?, price: String?, address: String?, placeHolderStr: String)? {
        guard let category = chatInboxModel?.category, let type = chatInboxModel?.propertyType else { return nil }

        let propertyInfo = (imageURL: chatInboxModel?.photos, type: chatInboxModel?.propertyTypeName, price: chatInboxModel?.defaultPrice, address: chatInboxModel?.address, placeHolderStr: "PlaceHolder_\(category)_\(type)")

        return propertyInfo
    }

    func getSectionTitle(for section: Int ) -> String? {
        return sectionModelList?[section].title
    }

    func getChatModel(at indexPath: IndexPath) -> ChatModel? {
        guard let title = sectionModelList?[indexPath.section].title, let models = sectionDataList[title] else { return nil }

        return models?[indexPath.item]
    }

    func cellCount(for section: Int) -> Int {
        guard let dataList = sectionDataList[sectionModelList?[section].title ?? ""] else { return 0 }

        return dataList?.count ?? 0
    }

    /// To be called from VC from where ChatVC is been called
    func update(chatInboxModel: ChatInboxModel?) {
        self.chatInboxModel = chatInboxModel
    }

    func update(chatList: [ChatAPIModel]?, callBack: @escaping () -> Void) {
        chatModelList = chatList?.compactMap({ ChatModel($0) })

        self.updateSectionTitle()

        callBack()
    }

    func deleteList(at index: Int, callBack: @escaping () -> Void) {
        guard chatModelList?.indices.contains(index) ?? false else {  return }
        
        chatModelList?.remove(at: index)

        self.updateSectionTitle()

        callBack()
    }

    func isAvailable(_ model: ChatAPIModel) -> Bool {
        return chatModelList?.contains(where: { $0.mID == model.mId }) ?? false
    }

    func updateList(with model: ChatAPIModel, callBack: @escaping () -> Void) {
        chatModelList?.append(ChatModel(model))

        self.updateSectionTitle()

        callBack()
    }

    func updateData(_ model: ChatAPIModel?, callBack: @escaping () -> Void) {
        guard let model = model else { return }
        guard let index = chatModelList?.firstIndex(where: { $0.mID == model.mId }) else { return }

        chatModelList?[index] = ChatModel(model)

        self.updateSectionTitle()

        callBack()
    }
}

// MARK: - Update for Typing
extension ChatViewModel {
    func updateTyping(_ state: Bool) {
        guard let chatID = AppSession.manager.userID, let channelID = channelID else { return }

        let typingText = state ? SocketIOManager.sharedInstance.startTypingID : SocketIOManager.sharedInstance.stopTypingID

        let dataDict = [
            "text": typingText,
            "chatID": chatID,
            "channelId": channelID,
            "updatedDate": String(Utility.shared.currentDateInMilliSecs()),
            "seen": MessageSeenType.sent.rawValue,
            ] as [String: Any]

        SocketIOManager.sharedInstance.send(chatDict: dataDict)
    }
}

// MARK: - Update Section Titles
extension ChatViewModel {
    private func updateSectionTitle() {
        sectionModelList = chatModelList?.map { ChatSectionModel(title: $0.headerTime, timeStamp: Utility.shared.milliSecsToDate(from: $0.timeStamp)) }.unique{$0.title ?? ""}
        sectionModelList = sectionModelList?.sorted(by: { $0.timeStamp ?? Date() < $1.timeStamp  ?? Date() })

        let _ = sectionModelList?.map({ (section) -> Bool in
            let chatModel = chatModelList?.filter({ $0.headerTime == section.title }).sorted(by: { Utility.shared.milliSecsToDate(from: $0.timeStamp) < Utility.shared.milliSecsToDate(from: $1.timeStamp) })
            sectionDataList[section.title ?? ""] = chatModel

            return true
        })
    }
}

// MARK: - Send Message
extension ChatViewModel {
    func sendMessage(with chatText: String?) -> [String: Any]? {
        guard let chatText = chatText else { return nil }

        let chatDict = getNewChatModel(with: chatText, hasSent: true)

        SocketIOManager.sharedInstance.send(chatDict: chatDict)

        sendNotification(for: chatText)

        return chatDict
    }

    private func getNewChatModel(with chatText: String?, hasSent: Bool) -> [String: Any] {
        guard let chatID = AppSession.manager.userID, let receiverID = receiverID, let userName = userName, let receiverName = title, let channelID = channelID else { return [:] }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"

        let currentDateStr = dateFormatter.string(from: Date())
        let mID = Utility.shared.getHashedID(for: [currentDateStr: channelID])

        let chatData = [
            "receiverUid": receiverID,
            "text": chatText ?? "",
            "userName": userName,
            "receiver": receiverName,
            "chatID": chatID,
            "channelId": channelID,
            "updatedDate": String(Utility.shared.currentDateInMilliSecs()),
            "mId": mID ?? "",
            "seen": MessageSeenType.sent.rawValue,
            "inbox": "0",
            ] as [String: Any]

        return chatData
    }
}

// MARK: - Send Notification for Last Sent Message
extension ChatViewModel {
    private func sendNotification(for lastMessage: String) {
        saveSupport(lastMessage)
    }

    private func saveSupport(_ lastMessage: String) {
        guard let senderID = AppSession.manager.userID, let receiverID = receiverID, let propertyID = chatInboxModel?.propertyID else { return }

        /// Play Sent Audio
        AppAudio.manager.play("Msg_Sent")

        AppNetworkManager.shared.saveLastMessage(for: senderID, receiverID, propertyID, lastMessage, successCallBack: { }, failureCallBack: { _ in })
    }
}
