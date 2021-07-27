//
//  AppLoader.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/07/21.
//

import UIKit

class AppLoader {
    static var loaderView: UIView?
    static var loader: UIActivityIndicatorView?

    class func show() {
        guard let window = UIApplication.shared.windows.last else { return }

        guard loaderView == nil, loader == nil else { return }

        loaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: window.frame.size.width, height: window.frame.size.height))

        loaderView?.backgroundColor = UIColor(red: 43.0/255.0, green: 78.0/255.0, blue: 86.0/255.0, alpha: 0.3)

        window.addSubview(loaderView ?? UIView())

        let spinnerHolder = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        spinnerHolder.layer.cornerRadius = 15.0
        spinnerHolder.backgroundColor = UIColor(red: 43.0/255.0, green: 78.0/255.0, blue: 86.0/255.0, alpha: 1.0)
        spinnerHolder.center = loaderView?.center ?? CGPoint.zero
        loaderView?.addSubview(spinnerHolder)

        loader = UIActivityIndicatorView(style: .large)
        loader?.tintColor = .white
        loader?.center = window.center
        loader?.startAnimating()

        window.addSubview(loader ?? UIView())
        window.bringSubviewToFront(loader ?? UIView())
    }

    class func dismiss() {
        AppLoader.loaderView?.isHidden = true
        AppLoader.loaderView?.removeFromSuperview()
        AppLoader.loaderView = nil

        AppLoader.loader?.isHidden = true
        AppLoader.loader?.removeFromSuperview()
        AppLoader.loader = nil
    }
}
