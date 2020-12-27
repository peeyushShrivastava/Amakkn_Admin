//
//  StroyboardExtension.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 19/10/20.
//

import Foundation
import UIKit

// MARK: - Generic Storyboard Protocol
protocol InitiableViewController {
    static var storyboardType: AppStoryboard { get }
}

extension InitiableViewController where Self: UIViewController {
    static func instantiateSelf() -> Self? {
        return initializeHelper()
    }

    private static func initializeHelper<T: UIViewController>() -> T? {
        let vcID = String(describing: self)
        let storyboard = UIStoryboard(name: storyboardType.rawValue, bundle: Bundle.main)

        return storyboard.instantiateViewController(withIdentifier: vcID) as? T
    }
}

// MARK: - Storyboards Enum
enum AppStoryboard: String {
    case main = "Main"
    case chat = "Chat"
    case users = "Users"
    case properties = "Properties"
    case more = "More"
}
