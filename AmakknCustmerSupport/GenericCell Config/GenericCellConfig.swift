//
//  GenericCellConfig.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/10/20.
//

import Foundation
import UIKit

// MARK: - Configurable Cell
protocol ConfigurableCell {
    associatedtype DataSource

    func configure(data: DataSource)
}

// MARK: - Cell Configurator
protocol CellConfigurator {
    static var reuseCellID: String { get }

    func configure(_ detailsCell: UIView)
}

// MARK: - Collection Cell Configurator
class CollectionCellConfigurator<DetailsCellType: ConfigurableCell, DataSource>: CellConfigurator where DetailsCellType.DataSource == DataSource, DetailsCellType: UICollectionViewCell {
    static var reuseCellID: String { return String(describing: DetailsCellType.self) }

    let item: DataSource

    init(item: DataSource) {
        self.item = item
    }

    func configure(_ detailsCell: UIView) {
        guard let cell = detailsCell as? DetailsCellType else { return }

        cell.configure(data: item)
    }
}
