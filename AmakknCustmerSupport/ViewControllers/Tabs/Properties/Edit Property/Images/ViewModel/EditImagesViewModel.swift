//
//  EditImagesViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 04/01/21.
//

import Foundation
import UIKit

// MARK: - EditImagesView Delegate
protocol EditImagesViewDelegate {
    func reloadData()
    func show(_ errorStr: String?)
}

class EditImagesViewModel {
    private var images: [String]?
    var propertyID: String?
    var isForPlans = false

    var delegate: EditImagesViewDelegate?

    var cellCount: Int {
        return images?.count ?? 0
    }
    
    var cellHeight: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 250.0 : 200.0
    }

    var cellWidth: CGFloat {
        let width = UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.width*0.7 : UIScreen.main.bounds.width - 20.0
        return width
    }

    subscript (_ index: Int) -> String? {
        return images?[index]
    }

    func update(images: [String]?, isPlans: Bool) {
        self.images = images
        self.isForPlans = isPlans
    }

    func updatePhoto(title: String?, at index: Int) {
        guard let title = title else { return }

        var tempImages = images
        var imageData = tempImages?[index].components(separatedBy: "#")
        imageData?[1] = title
        guard let newImage = imageData?.joined(separator: "#") else { return }

        tempImages?[index] = newImage

        updateProperty(images: tempImages) { [weak self] in
            DispatchQueue.main.async {
                self?.images = tempImages

                self?.delegate?.reloadData()
            }
        } failureCallBack: { errorStr in
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.show(errorStr)
            }
        }
    }

    func deleteImage(at index: Int) {
        images?.remove(at: index)
        let tempImages = images

        if isForPlans {
            delete(plans: tempImages) { [weak self] in
                DispatchQueue.main.async {
                    self?.images = tempImages

                    self?.delegate?.reloadData()
                }
            } failureCallBack: { errorStr in
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.show(errorStr)
                }
            }
        } else {
            updateProperty(images: tempImages) { [weak self] in
                DispatchQueue.main.async {
                    self?.images = tempImages

                    self?.delegate?.reloadData()
                }
            } failureCallBack: { errorStr in
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.show(errorStr)
                }
            }
        }
    }

    func makeDefault(at index: Int) {
        guard let defaultImage = images?[index] else { return }

        var tempImages = images
        tempImages?.remove(at: index)
        tempImages?.insert(defaultImage, at: 0)

        updateProperty(images: tempImages) { [weak self] in
            DispatchQueue.main.async {
                self?.images = tempImages

                self?.delegate?.reloadData()
            }
        } failureCallBack: { errorStr in
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.show(errorStr)
            }
        }
    }
}

// MARK: - APIs Call
extension EditImagesViewModel {
    private func updateProperty(images: [String]?, successCallBack: @escaping() -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        guard let images = images, let propertyID = propertyID else { return }

        let imgagesStr = images.joined(separator: ",")

        PropertyNetworkManager.shared.updateProperty(imgagesStr, for: propertyID) {
            successCallBack()
        } failureCallBack: { errorStr in
            failureCallBack(errorStr)
        }
    }

    private func delete(plans: [String]?, successCallBack: @escaping() -> Void, failureCallBack: @escaping(_ errorStr: String?) -> Void) {
        guard let plans = plans, let propertyID = propertyID else { return }

        let plansStr = plans.joined(separator: ",")

        PropertyNetworkManager.shared.delete(plansStr, for: propertyID) {
            successCallBack()
        } failureCallBack: { errorStr in
            failureCallBack(errorStr)
        }
    }
}
