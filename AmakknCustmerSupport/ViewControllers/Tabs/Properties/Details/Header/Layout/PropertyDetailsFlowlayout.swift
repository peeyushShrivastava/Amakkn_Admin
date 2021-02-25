//
//  PropertyDetailsFlowlayout.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 27/10/20.
//

import UIKit

class PropertyDetailsFlowlayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)

        layoutAttributes?.forEach({ (attributes) in
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader, attributes.indexPath.section == 0 {
                guard let collectionView = collectionView else { return }

                let contentOffsetY = collectionView.contentOffset.y
                let width = collectionView.frame.width
                let height = attributes.frame.height - contentOffsetY

                guard height > attributes.frame.height  else { return }

                attributes.frame = CGRect(x: 0.0, y: contentOffsetY, width: width, height: height)
            }
        })

        return layoutAttributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
