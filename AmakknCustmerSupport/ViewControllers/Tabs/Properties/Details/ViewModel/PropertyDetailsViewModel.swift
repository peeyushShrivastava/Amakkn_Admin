//
//  PropertyDetailsViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 25/10/20.
//

import Foundation
import UIKit

// MARK: - Details Cell Typealias
typealias descriptionCell = CollectionCellConfigurator<DescriptionCell, String?>
typealias overviewCell = CollectionCellConfigurator<OverviewCell, DetailsOverViewModel?>
typealias amenityCell = CollectionCellConfigurator<AmenitiesCell, DetailsAmenityModel?>
typealias rentOptionsCell = CollectionCellConfigurator<RentOptionsCell, DetailsRentOptionsModel?>
typealias locationCell = CollectionCellConfigurator<LocationCell, DetailsLocationModel?>
typealias visitingHrsCell = CollectionCellConfigurator<VisitingHoursCell, DetailsVisitingHrsModel?>
typealias floorPlansCell = CollectionCellConfigurator<FloorPlansCell, DetailsFloorPlansModel?>
typealias hostInfoCell = CollectionCellConfigurator<UserInfoCell, DetailsHostModel?>
typealias complaintsCell = CollectionCellConfigurator<ComplaintsCell, [ComplaintModel]?>

// MARK: - Details Cell Height
enum DetailsCellsHeight: CGFloat {
    case description = 80.0
    case overview = 45.01
    case amenity = 44.0
    case rentOptions = 45.02
    case location = 350.0
    case visitingHrs = 160.0
    case floorPlan = 126.0
    case hostInfo = 185.0
    case complaints = 154.0
}

class PropertyDetailsViewModel {
    private var propertyID: String?
    private var propertyDetails: PropertyDetails?
    private var complaints: [ComplaintModel]?
    private var detailsDataSource: DetailsDataSource?
    private var cellsDataSource = [CellConfigurator]()
    private var cellsHeight = [CGFloat]()
    private var publishStatus: String?

    var cellCount: Int {
        return cellsDataSource.count
    }

    var cellHeight: CGFloat {
        return 80.0
    }

    var navBarHeight: CGFloat {
        return Utility.shared.hasNotch ? 89.0 : 64.0
    }

    var navBarBackButtonImage: UIImage? {
        return Utility.shared.selectedLanguage == .english ? UIImage(named: "icBack") : UIImage(named: "icBackInarabic")
    }

    var detailsMortgageData: PropertyDetailsData? {
        return PropertyDetailsData(details: propertyDetails)
    }

    var shareURLStr: String {
        return "https://amakkn.com/#!/propertyDescription/\(propertyID ?? "")"
    }

    var subjectID: String {
        return "4" // Can be changed according to backend
    }

    private func update() {
        detailsDataSource = DetailsDataSource(propertyDetails)

        updateCellsDataSource()
    }

    private func updateCellsDataSource() {
        if let description = detailsDataSource?.description, !description.isEmpty {
            cellsDataSource.append(descriptionCell(item: description))

            cellsHeight.append(DetailsCellsHeight.description.rawValue)
        }

        if let overview = detailsDataSource?.overviewDataSource, !(overview.dataSource.isEmpty) {
            cellsDataSource.append(overviewCell(item: overview))

            let height: CGFloat = CGFloat(overview.dataSource.count + 1) * DetailsCellsHeight.overview.rawValue
            cellsHeight.append(height)
        }

        if let amenity = detailsDataSource?.amenityDataSource, !(amenity.dataSource?.isEmpty ?? true) {
            cellsDataSource.append(amenityCell(item: amenity))

            let rows: CGFloat = CGFloat((amenity.dataSource?.count ?? 0) + 1)/2
            let updatedRows = rows > 1.5 ? rows : 1.0
            let height = (updatedRows * DetailsCellsHeight.amenity.rawValue) + 70.0

            cellsHeight.append(height)
        }

        if let rentOptions = detailsDataSource?.rentOptionDataSource, !(rentOptions.dataSource?.isEmpty ?? true) {
            cellsDataSource.append(rentOptionsCell(item: rentOptions))

            let height: CGFloat = CGFloat((rentOptions.dataSource?.count ?? 0) + 1) * DetailsCellsHeight.rentOptions.rawValue
            cellsHeight.append(height)
        }

        if let location = detailsDataSource?.locationDataSource {
            cellsDataSource.append(locationCell(item: location))

            cellsHeight.append(DetailsCellsHeight.location.rawValue)
        }

        if let visitingHrs = detailsDataSource?.visitingHrsDataSource, !(propertyDetails?.visitingHours?.isEmpty ?? true) {
            cellsDataSource.append(visitingHrsCell(item: visitingHrs))

            cellsHeight.append(DetailsCellsHeight.visitingHrs.rawValue)
        }

        if let floorPlan = detailsDataSource?.floorPlanDataSource, !(floorPlan.dataSource?.first?.isEmpty ?? true) {
            cellsDataSource.append(floorPlansCell(item: floorPlan))

            let rows: CGFloat = CGFloat((floorPlan.dataSource?.count ?? 0) + 1)/3
            let updatedRows = rows > 1 ? rows : 1.0
            let height = (updatedRows * DetailsCellsHeight.floorPlan.rawValue) + 80.0
            cellsHeight.append(height)
        }

        if var hostInfo = detailsDataSource?.hostDataSource {
            hostInfo.propertyStatus = publishStatus
            cellsDataSource.append(hostInfoCell(item: hostInfo))

            cellsHeight.append(DetailsCellsHeight.hostInfo.rawValue)
        }

        if let complaints = complaints, AppSession.manager.validSession, !complaints.isEmpty {
            cellsDataSource.append(complaintsCell(item: complaints))

            let rows: CGFloat = CGFloat(complaints.count + 1)
            let updatedRows = rows > 1 ? rows : 1.0
            let height = (updatedRows * DetailsCellsHeight.complaints.rawValue)

            cellsHeight.append(height)
        }
    }

    private func updateLikes(for status: Bool) {
        guard let likesCount = Int(detailsDataSource?.headerDataSource?.likes ?? "0") else { return }

        detailsDataSource?.headerDataSource?.likes = status ? "\(likesCount+1)" : "\(likesCount-1)"
    }
}

// MARK: - Public Methods
extension PropertyDetailsViewModel {
    subscript (_ index: Int) -> CellConfigurator {
        return cellsDataSource[index]
    }

    func height(for row: Int) -> CGFloat {
        return cellsHeight[row]
    }

    func update(with propertyID: String?, and publishStatus: String? = nil) {
        self.publishStatus = publishStatus
        self.propertyID = propertyID
    }

    func headerDataSource() -> DetailsHeaderModel? {
        detailsDataSource?.headerDataSource?.propertyID = propertyID

        return detailsDataSource?.headerDataSource
    }

    func getPhotos(with images: [String]?) -> (photos: [String], titles: [String]) {
        guard let images = images else { return ([""], [""]) }

        var photos = [String]()
        var titles = [String]()

        for imageURLStr in images {
            if imageURLStr.contains("#") {
                let imageArr = imageURLStr.split(separator: "#")
                photos.append(String(imageArr.first ?? ""))

                if imageArr.count > 1 {
                   titles.append(String(imageArr.last ?? ""))
                } else {
                    titles.append("")
                }
            } else {
                photos.append(imageURLStr)
                titles.append("")
            }
        }

        return (photos, titles)
    }
}

// MARK: - API Calls
extension PropertyDetailsViewModel {
    func getPropertyDetails(successCallBack: @escaping() -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        guard let propertyID = propertyID, let userID = AppSession.manager.userID else { return }
        
        AppNetworkManager.shared.getPropertyDetails(for: userID, and: propertyID, successCallBack: { [weak self] responseModel in
            self?.propertyDetails = responseModel
            self?.update()

            successCallBack()
        }, failureCallBack: { errorStr in
            failureCallBack(errorStr)
        })
    }

    func publishProperty(successCallBack: @escaping() -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        guard let propertyID = propertyID, let userID = AppSession.manager.userID, let publishStatus = publishStatus else { return }

//        NetworkManager.shared.publishProperty(propertyID: propertyID, userID: userID, isPublish: publishStatus, completion: { (_, error) in
//            if let error = error {
//                failureCallBack(error.logDescription())
//            } else {
//                successCallBack()
//            }
//        })
    }

    func getcomplaints(callBack: @escaping() -> Void) {
        guard let propertyID = propertyID else { return }

        AbusesNetworkManager.shared.getComplaints(for: propertyID) { [weak self] responseModel in
            self?.complaints = responseModel?.complaints

            callBack()
        } failureCallBack: { _ in }
    }

    func resolveComplaint(id: String?) {
        guard let id = id else { return }

        AbusesNetworkManager.shared.resolveComplaints(for: id)
    }
}

// MARK: - Call Action
extension PropertyDetailsViewModel {
    func call(with phone: String?, _ countryCode: String?, callBack: @escaping(_ errorStr: String?) -> Void) {
        guard let phone = phone, let countryCode = countryCode else { return }

        if AppGeneral.shared.isSimAvialbale() || AppGeneral.shared.isESimAvialable() {
            AppGeneral.shared.callingAction(phoneNumber: "\(countryCode)\(phone)")
        } else {
            callBack("Sim is not avialbale")
        }
    }
}

// MARK: - Chat
extension PropertyDetailsViewModel {
    func getChatModel(at index: Int, successCallBack: @escaping (_ chatModel: ChatInboxModel?) -> Void, failureCallBack: @escaping (_ errorStr: String?) -> Void)  {
        guard let complaint = complaints?[index] else { return }
        guard let  senderID = AppSession.manager.userID, let receiverID = complaint.userID else { return }

        AppNetworkManager.shared.initChat(for: senderID, receiverID, subjectID) { [weak self] channelID in
            guard let channelID = channelID else { return }

            successCallBack(self?.chatModel(for: channelID, complaint))
        } failureCallBack: { (errorStr) in
            failureCallBack(errorStr)
        }
    }

    private func chatModel(for channelID: String?, _ complaint: ComplaintModel) -> ChatInboxModel? {
        guard let  senderID = AppSession.manager.userID, let receiverID = complaint.userID,
              let senderName = AppSession.manager.userName,
              let senderAvatar = AppSession.manager.userAvatar,let receiverAvatar = complaint.avatar else { return nil }

        let model = ChatInboxModel(senderID: senderID, receiverID: receiverID, channelID: channelID, propertyID: subjectID, chatID: senderID,
                                   senderName: senderName, receiverName: complaint.userName, senderAvatar: senderAvatar, receiverAvatar: receiverAvatar, isVerified: complaint.isVerified,
                                   category: nil, propertyType: nil, propertyTypeName: nil, listedFor: nil,
                                   unreadCount: nil, lastMessage: nil, time: nil,
                                   photos: nil, defaultPrice: nil, address: nil, senderUserType: nil, receiverUserType: nil)

        return model
    }
}
