//
//  CreateTicketViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import Foundation

class CreateTicketViewModel {
    private var propertyID = ""
    private var subject: String?
    private var screenShots = [String]()
    private var userID: String?
    var isForCreate = false

    var delegate: TicketsListDelegate?

    private func updateScreenShots(with urlStr: String) {
        screenShots.append(urlStr)
    }

    func updateSubject(_ title: String?) {
        subject = title
    }
    
    func getLastScreenShot() -> (String?, Int) {
        return (screenShots.last, screenShots.count-1)
    }

    func getimageURL(at index: Int) -> String {
        return screenShots[index]
    }

    func updateUserID(_ hashedID: String?) {
        userID = hashedID
    }
}

// MARK: - API Calls
extension CreateTicketViewModel {
    func uploadToS3(imageData: Data) {
        TicketsNetworkManager.shared.uploadToS3(imageData: imageData) { urlStr in
            DispatchQueue.main.async { [weak self] in
                AppLoader.dismiss()

                self?.updateScreenShots(with: urlStr)

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
        guard let title = subject, let userID = userID else { return }

        AppLoader.show()

        isForCreate = true
        let imagesStr = screenShots.joined(separator: ",")

        TicketsNetworkManager.shared.createTicket(for: userID, with: title, notes ?? "", imagesStr, and: propertyID) { [weak self] in
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
