//
//  CopyableLabel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 28/02/21.
//

import Foundation
import UIKit

class CopyableLabel: UILabel {
    override var canBecomeFirstResponder: Bool {
        get { return true }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        shareInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        shareInit()
    }

    private func shareInit() {
        isUserInteractionEnabled = true

        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu(sender:))))
    }

    @objc func showMenu(sender: Any?) {
        becomeFirstResponder()

        let menu = UIMenuController.shared

        if !menu.isMenuVisible {
            menu.showMenu(from: self, rect: bounds)
//            menu.setMenuVisible(true, animated: true)
        }
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text

        UIMenuController.shared.hideMenu(from: self)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(copy(_:)))
    }
}
