//
//  FeedbackModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 31/12/20.
//

import Foundation

struct FeedbackResponseModel: Codable {
    let feedbackArray: [FeedbackModel]?
    let totalCount: String?
}

struct FeedbackModel: Codable {
    let feedbackID: String?
    let subjectID: String?
    let email: String?
    let name: String?
    let message: String?

    private enum CodingKeys: String, CodingKey {
        case feedbackID = "id"
        case subjectID = "subjectId"
        case email, name, message
    }
}
