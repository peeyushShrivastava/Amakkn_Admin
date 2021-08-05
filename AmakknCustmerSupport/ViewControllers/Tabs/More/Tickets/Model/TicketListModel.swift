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
        case tickets = "ticketArray"
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
    let lastMessage: String?

    let children: [TicketsModel]?
    let violation: TViolationModel?
    let feedback: TFeedbackModel?

    private enum CodingKeys: String, CodingKey {
        case ticketID = "id"
        case userID = "userId"
        case propertyID = "propertyId"

        case createdDate = "createdAt"
        case updatedDate = "updatedAt"

        case status, title, statusName, lastMessage
        case children, violation, feedback
    }
}

struct TViolationModel: Codable {
    let hasViolation: String?
    let violationText: String?
}

struct TFeedbackModel: Codable {
    let isUserHappy: String?
    let feedbackText: String?
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

struct TicketDetailsModel: Codable {
    let property: PropertyDetails?
    let details: [TicketDetails]?
    let userInfo: UserInfo?
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

struct UserInfo: Codable {
    var userID: String?
    var userName: String?
    var userPhone: String?
    var cCode: String?

    private enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userName = "createdAt"
        case cCode = "countryCode"
        case userPhone = "phone"
    }
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

struct ViolationModel: Codable {
    let userID: String?
    let userAvatar: String?
    let userName: String?

    let cCode: String?
    let phone: String?
    let violationCount: String?

    private enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userAvatar = "avatar"
        case userName = "name"

        case cCode = "countryCode"
        case violationCount = "count"

        case phone
    }
}

struct PropertyInfo {
    let imageURL: String?
    let type: String?
    let price: String?
    let address: String?
    let placeHolderStr: String?

    let propertyID: String?
    var userID: String?
    var cCode: String?
    var phone: String?
}

struct ImageTypeModel {
    let fileURL: String
    let format: String
}
