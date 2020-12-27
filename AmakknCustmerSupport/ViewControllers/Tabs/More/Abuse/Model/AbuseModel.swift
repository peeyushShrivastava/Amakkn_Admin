//
//  AbuseModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 16/12/20.
//

import Foundation

struct AbuseModel: Codable {
    let userID: String?
    let propertyID: String?
    let description: String?

    let createdAt: String?
    let updatedAt: String?

    private enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case propertyID = "propertyId"
        case description, createdAt, updatedAt
    }
}
