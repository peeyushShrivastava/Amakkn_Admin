//
//  FeedbackModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 31/12/20.
//

import Foundation

struct FeedbackResponseModel: Codable {
    let feedbackArray: [FeedbackModel]?
    let totalCount: Int?
}

struct FeedbackModel: Codable {
    let feedbackID: String?
    let subjectID: String?
    let userID: String?
    let email: String?
    let name: String?
    let message: String?
    let subject: String?
    let status: String?
    let createdDate: String?
    

    private enum CodingKeys: String, CodingKey {
        case feedbackID = "id"
        case subjectID = "subjectId"
        case userID = "userId"
        case createdDate = "createdAt"
        case email, name, message, status, subject
    }
}
