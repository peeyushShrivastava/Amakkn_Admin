//
//  TicketListModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import Foundation

struct TicketListModel: Codable {
    let tickets: [TicketsModel]?

    private enum CodingKeys: String, CodingKey {
        case tickets = "subjectArray"
    }
}

struct TicketsModel: Codable {
    let ticketID: String?
    let userID: String?
    let propertyID: String?

    let status: String?
    let title: String?
    let statusName: String?

    let createdDate: String?
    let updatedDate: String?

    private enum CodingKeys: String, CodingKey {
        case ticketID = "id"
        case userID = "userId"
        case propertyID = "propertyId"

        case createdDate = "createdAt"
        case updatedDate = "updatedAt"

        case status, title, statusName
    }
}

struct SubListModel: Codable {
    let subjects: [SubjectModel]?

    private enum CodingKeys: String, CodingKey {
        case subjects = "ticketSubjectArray"
    }
}

struct SubjectModel: Codable {
    let subjectID: String?
    let subject: String?

    private enum CodingKeys: String, CodingKey {
        case subjectID = "subjectId"

        case subject
    }
}

struct StatusListModel: Codable {
    let statusList: [StatusModel]?

    private enum CodingKeys: String, CodingKey {
        case statusList = "ticketStatusArray"
    }
}

struct StatusModel: Codable {
    let statusID: String?
    let statusName: String?

    private enum CodingKeys: String, CodingKey {
        case statusID = "status"
        case statusName = "name"
    }
}

struct TicketDetails: Codable {
    let userId: String?
    let statusId: String?
    let status: String?
    let statusName: String?
    let isActive: String?

    let images: [DetailsImage]?
    let comments: [DetailsComment]?

    let createdAt: String?
}

struct DetailsImage: Codable {
    let userID: String?
    let image: String?
    let createdDate: String?

    private enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case createdDate = "createdAt"
        case image
    }
}

struct DetailsComment: Codable {
    let userID: String?
    let text: String?
    let createdDate: String?

    private enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case createdDate = "createdAt"
        case text
    }
}
