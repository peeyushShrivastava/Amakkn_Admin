//
//  CreateTicketViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import Foundation

class CreateTicketViewModel {
    private var propertyID = ""
    private var subjectID: String?
    private var screenShots = [ImageTypeModel]()
    private var userID: String?
    private var parentTicketID = ""
    private var propertyInfoModel: PropertyInfo?
    private var userInfoModel: UserInfo?
    private var fileType = ""
    var isForCreate = false

    var delegate: TicketsListDelegate?

    var propertyInfo: (imageURL: String?, type: String?, price: String?, address: String?, placeHolderStr: String)? {
        guard let type = propertyInfoModel?.type, let address = propertyInfoModel?.address else { return nil }

        let propertyInfo = (imageURL: propertyInfoModel?.imageURL, type: type, price: propertyInfoModel?.price, address: address, placeHolderStr: "\(propertyInfoModel?.placeHolderStr ?? "")")

        return propertyInfo
    }

    var userData: String? {
        return "\(userInfoModel?.cCode ?? "")-\(userInfoModel?.userPhone ?? "") (UserId: \(userInfoModel?.userID ?? ""))"
    }

    private func updateScreenShots(with imgModel: ImageTypeModel) {
        screenShots.append(imgModel)
    }

    func updateSubjectID(_ subjectID: String?) {
        self.subjectID = subjectID
    }

    func getLastScreenShot() -> (ImageTypeModel?, Int) {
        return (screenShots.last, screenShots.count-1)
    }

    func getimageURL() -> [ImageTypeModel] {
        return screenShots
    }

    func updateUserID(_ hashedID: String?) {
        userID = hashedID
    }

    func updateParentTicketID(_ parentTicketID: String?) {
        self.parentTicketID = parentTicketID ?? ""
    }

    func updatePropertyID(_ propertyID: String) {
        self.propertyID = propertyID
    }

    func updatePropertyInfo(_ propertyInfo: PropertyInfo?) {
        propertyInfoModel = propertyInfo
        propertyID = propertyInfo?.propertyID ?? ""
    }

    func update(_ user: SearchedUserModel?) {
        userInfoModel?.userID = user?.userID
        userInfoModel?.userName = user?.userName
        userInfoModel?.cCode = user?.countryCode
        userInfoModel?.userPhone = user?.userPhone

        userID = user?.userID
    }

    func updateUserInfo(_ userInfo: UserInfo?) {
        userInfoModel = userInfo

        userID = userInfo?.userID
    }
}

// MARK: - API Calls
extension CreateTicketViewModel {
    func uploadToS3(imageData: Data, for ext: String) {
        TicketsNetworkManager.shared.uploadToS3(imageData: imageData, for: ext) { urlStr in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                let model = ImageTypeModel(fileURL: urlStr, format: ext)
                self?.updateScreenShots(with: model)
                self?.fileType = ext == "pdf" ? "PDF" : "image"

                self?.delegate?.success()
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }
    }

    func createTicket(with notes: String?) {
        guard let subjectID = subjectID, let userID = userID else { return }

        AppLoader.show()

        isForCreate = true
        let imagesStr = screenShots.map({$0.fileURL}).joined(separator: ",")

        TicketsNetworkManager.shared.createTicket(for: userID, parentTicketID, with: subjectID, notes ?? "", imagesStr, fileType, and: propertyID) { [weak self] in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.delegate?.success()
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }
    }
}
