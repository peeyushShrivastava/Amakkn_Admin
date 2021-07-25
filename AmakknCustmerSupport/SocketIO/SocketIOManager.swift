//
//  SocketIOManager.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import Foundation
import SocketIO

// MARK: - SocketIO Delegate
protocol SocketIOManagerDelegate {
    func receiver(isTyping: Bool)
    func receiver(online status: Bool)
    func senderDidReceive(chatDict: [String: Any])
    func updateSeen(for chatDict: [String: Any])
    func updateSentTime(for chatDict: [String: Any])
    func updateAllSeen()
}

// MARK: - Enum for Seen update
enum MessageSeenType: String {
    case sent = "0"
    case received = "1"
    case seen = "2"
}

class SocketIOManager {
    private let chatChannelID = "chat message"
    private let statusOnChannelID = "connectUser"
    private let statusOffChannelID = "disconnectUser"
    let startTypingID = "D@]44vaJ@FM2xYG(Fu7v8fNt8raG]wm."
    let stopTypingID = "4sVpfb393M>]tWR@LiqEZ,8[3UTZcht)"

    static let sharedInstance = SocketIOManager()

    let manager = SocketManager(socketURL: URL(string: "https://prodchat.amakkn.com")!)
    var socket: SocketIOClient?
    var dataProvider: ChatDataProvider!
    var isUserOnline = false

    var delegate: SocketIOManagerDelegate?

    private init() {
        dataProvider = ChatDataProvider(persistentContainer: CoreDataStack.shared.persistentContainer, repository: ChatAPIRepository.shared)
    }

    func establishConnection() {
        guard AppSession.manager.validSession else { return }

        if socket == nil {
            socket = manager.defaultSocket
        }

        updateConnection()
    }

    func closeConnection() {
        emitUserStatusOff()

        socket?.disconnect()
    }

    func openSockets(with receiverID: String) {
        updateConnection()
        openChatMessageChannel(with: receiverID)
        emitUserStatusOn()
    }

    func send(chatDict: [String: Any]?) {
        emit(chatDict)
    }

    func offChannelSocket() {
        socket?.off(chatChannelID)
    }
}

// MARK: - Check Connection
extension SocketIOManager {
    private func updateConnection() {
        guard let status = socket?.status else { return }

        switch status {
        case .disconnected, .notConnected:
                socket?.connect(timeoutAfter: 600, withHandler: nil)

                emitUserStatusOn()
            default:
                emitUserStatusOn()
        }
    }
}

// MARK: - SocketIO Open Chat Channel
extension SocketIOManager {
    private func openChatMessageChannel(with receiverID: String) {
        socket?.on(chatChannelID, callback: { [weak self] (dataArray, ack) in
            DispatchQueue.main.async {
                guard let dataDict = dataArray.first as? [String: Any], let text = dataDict["text"] as? String, let chatID = dataDict["chatID"] as? String else { return }

                /// Update all sender messages as Seen to Internal DB
                if chatID != AppSession.manager.userID, text == "" {
                    self?.delegate?.updateAllSeen()

                    return
                }

                guard text != "" else { return }

                if let seen = dataDict["seen"] as? String, let seenType = MessageSeenType(rawValue: seen) {
                    if chatID == AppSession.manager.userID, seenType == .seen {
                        /// Update Seen as Sender
                        var chatDict = dataDict
                        chatDict["seen"] = MessageSeenType.seen.rawValue

                        self?.delegate?.updateSeen(for: chatDict)

                        return
                    }

                    if chatID == AppSession.manager.userID, seenType == .sent, text != self?.startTypingID, text != self?.stopTypingID {
                        /// Message sent to server  (single tick)
                        // Update Intenal DB with updated time from Server

                        self?.delegate?.senderDidReceive(chatDict: dataDict)
                        self?.delegate?.updateSentTime(for: dataDict)

                        return
                    }

                    /// As Receiver
                    guard chatID != AppSession.manager.userID  else { return }

                    if text == self?.startTypingID, chatID == receiverID  {
                        self?.isUserOnline = true
                        self?.delegate?.receiver(isTyping: true)

                        return
                    }

                    if text == self?.stopTypingID, chatID == receiverID {
                        self?.delegate?.receiver(online: self?.isUserOnline ?? false)

                        return
                    }

                    if seenType != .seen {
                        var chatDict = dataDict
                        chatDict["seen"] = MessageSeenType.seen.rawValue

                        self?.send(chatDict: chatDict)
                        self?.delegate?.senderDidReceive(chatDict: chatDict)

                        AppAudio.manager.play("Msg_Recvd")
                    }
                }

            }
        })
    }
}

// MARK: - SocketIO Open Status Channel
extension SocketIOManager {
    private func openStatusOnChannel(with receiverID: String?) {
        socket?.on(statusOnChannelID, callback: { [weak self] (dataArray, ack) in
            DispatchQueue.main.async {
                guard let dataDict = dataArray.first as? [String: String], let loggedInUserID = AppSession.manager.userID else { return }

                guard let userID = dataDict["userId"], let isOnline = dataDict["isOnline"] else { return }

                if userID != loggedInUserID, receiverID == userID {
                    self?.isUserOnline = (isOnline == "1")
                    self?.delegate?.receiver(online: (isOnline == "1"))
                }
            }
        })
    }
}

// MARK: - SocketIO Emit Chat
extension SocketIOManager {
    private func emit(_ chatDict: [String: Any]?) {
        updateConnection()

        guard let chatDict = chatDict else { return }

        socket?.emit(chatChannelID, chatDict)
    }

    private func emitUserStatusOn() {
        ChatNetworkManager.shared.saveOnline(state: "1")
    }

    private func emitUserStatusOff() {
        ChatNetworkManager.shared.saveOnline(state: "0")
    }
}
