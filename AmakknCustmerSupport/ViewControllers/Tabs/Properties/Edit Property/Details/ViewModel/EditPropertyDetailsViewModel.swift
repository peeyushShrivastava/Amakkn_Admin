//
//  EditPropertyDetailsViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 04/01/21.
//

import Foundation
import UIKit

// MARK: - Edit Cell Typealias
typealias editImagesCell = CollectionCellConfigurator<EditImageCell, EditImagesDataSource?>
typealias featuresCell = CollectionCellConfigurator<EditFeaturesCell, EditFeaturesDataSource?>
typealias amenitiesCell = CollectionCellConfigurator<EditAmenitiesCell, EditAmenitiesDataSource?>
typealias detailsCell = CollectionCellConfigurator<EditDetailsCell, EditPropertyDetailsDataSource?>
typealias plansCell = CollectionCellConfigurator<EditPlansCell, EditPlansDataSource?>
typealias editDescriptionCell = CollectionCellConfigurator<EditDescriptionCell, EditDescriptionDataSource?>
typealias editPriceCell = CollectionCellConfigurator<EditPriceCell, EditPriceDataSource?>

// MARK: - Edit Details Cell Height
enum EditDetailsCellsHeight: CGFloat {
    case images = 60.1
    case features = 100.0
    case amenities = 250.0
    case details = 95.0
    case plans = 60.0
    case description = 264.0
    case price = 85.0
}

// MARK: - EditPropertyDetails Delegate
protocol EditPropertyDetailsDelegate {
    func reloadData()
    func showError(with errorStr: String?)
}

class EditPropertyDetailsViewModel {
    private var propertyParams: AddPropertyParams?
    private var propertyDetails: PropertyDetails?
    private var editDetailsDataSource: EditDetailsDataSource?
    private var cellsDataSource = [CellConfigurator]()
    private var cellsHeight = [CGFloat]()

    var delegate: EditPropertyDetailsDelegate?

    var cellCount: Int {
        return cellsDataSource.count
    }

    func update(propertyDetails: PropertyDetails?) {
        self.propertyDetails = propertyDetails

        getAllParams()
    }

    private func updateCellsDataSource() {
        if let images = editDetailsDataSource?.images {
            cellsDataSource.append(editImagesCell(item: images))

            cellsHeight.append(EditDetailsCellsHeight.images.rawValue)
        }

        if let features = editDetailsDataSource?.features, AppSession.manager.validSession, features.params?.count != 0 {
            cellsDataSource.append(featuresCell(item: features))

            let rows: CGFloat = CGFloat(features.params?.count ?? 0 + 1)
            let updatedRows = rows > 1 ? rows : 1.0
            let height = (updatedRows * EditDetailsCellsHeight.features.rawValue) + 80.0

            cellsHeight.append(height)
        }

        if let amenities = editDetailsDataSource?.amenities, AppSession.manager.validSession, amenities.params?.count != 0 {
            cellsDataSource.append(amenitiesCell(item: amenities))

            let rows: CGFloat = CGFloat(amenities.params?.count ?? 0 + 1)/2
            let updatedRows = rows > 1 ? rows : 1.0
            let height = (updatedRows * EditDetailsCellsHeight.details.rawValue) + 80.0

            cellsHeight.append(height)
        }

        if let details = editDetailsDataSource?.details, details.params?.count != 0 {
            cellsDataSource.append(detailsCell(item: details))

            let rows: CGFloat = CGFloat(details.params?.count ?? 0 + 1)
            let updatedRows = rows > 1 ? rows : 1.0
            let height = (updatedRows * EditDetailsCellsHeight.details.rawValue) + 80.0

            cellsHeight.append(height)
        }

        if let plans = editDetailsDataSource?.plans {
            cellsDataSource.append(plansCell(item: plans))

            cellsHeight.append(EditDetailsCellsHeight.plans.rawValue)
        }

        if let description = editDetailsDataSource?.description {
            cellsDataSource.append(editDescriptionCell(item: description))

            cellsHeight.append(EditDetailsCellsHeight.description.rawValue)
        }

        if let price = editDetailsDataSource?.price, AppSession.manager.validSession, price.params?.count != 0 {
            cellsDataSource.append(editPriceCell(item: price))

            let rows: CGFloat = CGFloat((price.params?.count ?? 0) + 1)
            let updatedRows = rows > 1 ? rows : 1.0
            let height = (updatedRows * EditDetailsCellsHeight.price.rawValue) + 80.0

            cellsHeight.append(height)
        }

        delegate?.reloadData()
    }
}

// MARK: - Public Methods
extension EditPropertyDetailsViewModel {
    subscript (_ index: Int) -> CellConfigurator {
        return cellsDataSource[index]
    }

    func height(for row: Int) -> CGFloat {
        return cellsHeight[row]
    }
}

// MARK: - API Calls
extension EditPropertyDetailsViewModel {
    private func getAllParams() {
        guard let propertyType = propertyDetails?.propertyType else { return }

        PropertyNetworkManager.shared.getParams(for: propertyType) { [weak self] respModel in
            DispatchQueue.main.async {
                self?.propertyParams = respModel
                self?.editDetailsDataSource = EditDetailsDataSource(self?.propertyDetails, and: respModel)

                self?.updateCellsDataSource()
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.delegate?.showError(with: errorStr)
            }
        }
    }
}

// MARK: - Update Features
extension EditPropertyDetailsViewModel {
    func updateFeatures(with key: String?, isPlus: Bool, callBack: @escaping () -> Void) {
        guard let key = key, let index = editDetailsDataSource?.features?.dataSource?.firstIndex(where: { $0.key == key }) else { return }
        guard let value = editDetailsDataSource?.features?.dataSource?[index].value, let valueInt = Int(value) else { return }

        editDetailsDataSource?.features?.dataSource?[index].value = isPlus ? "\(valueInt + 1)" : "\(valueInt - 1)"

        if let features = editDetailsDataSource?.features, AppSession.manager.validSession {
            cellsDataSource[0] = featuresCell(item: features)
        }

        callBack()
    }
}

// MARK: - Update Amenities
extension EditPropertyDetailsViewModel {
    func update(_ amenity: Amenity?, isSelected: Bool, callBack: @escaping () -> Void) {
        guard let amenity = amenity else { return }

        if isSelected {
            editDetailsDataSource?.amenities?.dataSource?.append(amenity)
        } else {
            let _ = editDetailsDataSource?.amenities?.dataSource?.enumerated().map({ (count, data) -> Bool in
                if data.name == amenity.name {
                    editDetailsDataSource?.amenities?.dataSource?.remove(at: count)
                }
                return false
            })
        }

        if let amenities = editDetailsDataSource?.amenities, AppSession.manager.validSession {
            cellsDataSource[1] = amenitiesCell(item: amenities)
        }

        callBack()
    }
}
