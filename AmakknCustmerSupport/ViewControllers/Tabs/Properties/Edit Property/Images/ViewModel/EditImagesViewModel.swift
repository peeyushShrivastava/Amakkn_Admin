//
//  EditImagesViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 04/01/21.
//

import Foundation
import UIKit

class EditImagesViewModel {
    private var images: [String]?

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

    func update(images: String?) {
        let imagesList = images?.components(separatedBy: ",")

        self.images = imagesList
    }
}
