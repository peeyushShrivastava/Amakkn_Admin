//
//  ChatAPIRepository.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 15/12/20.
//

import Foundation
import UIKit

class ChatAPIRepository {
    static let shared = ChatAPIRepository()

    private init() { }

    private let urlSession = URLSession.shared
    private let baseURL = URL(string: "https://prodchat.amakkn.com/getNewMessages/")!

    func getChats(with channelID: String, callBack: @escaping(_ chatssDict: [[String: Any]]?, _ error: Error?) -> Void) {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "post"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = createRequestBody(with: channelID)

        urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error { callBack(nil, error); return }

            guard let data = data else { callBack(nil, error); return }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDictionary = jsonObject as? [String: Any], let resultDict = jsonDictionary["response"] as? [String: Any] else { return }
                guard let result = resultDict["messages"] as? [[String: Any]] else { return }

                callBack(result, nil)
            } catch {
                callBack(nil, error)
            }
        }.resume()
    }

    private func createRequestBody(with channelID: String) -> Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: ["channelId": channelID, "userId": AppSession.manager.userID ?? ""], options: [])

            return data
        } catch _ {
            debugPrint("Invalid params")
        }

        return nil
    }
}
