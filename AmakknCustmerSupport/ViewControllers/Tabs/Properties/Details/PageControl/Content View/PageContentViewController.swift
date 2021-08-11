//
//  PageContentViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 29/12/20.
//

import UIKit
import SDWebImage
import WebKit

class PageContentViewController: UIViewController {
//    @IBOutlet weak var ibPhotoImageView: UIImageView!
    @IBOutlet weak var ibContentView: UIView!
    @IBOutlet weak var ibLoader: UIActivityIndicatorView!

    var ibContentWebView: WKWebView?

    override func loadView() {
        ibContentWebView = WKWebView()
        ibContentWebView?.navigationDelegate = self
        view = ibContentWebView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func updateFile(with urlStr: String?) {
        guard let urlStr = urlStr else { return }

//        ibLoader.isHidden = false

        let link = URL(string: urlStr)!

        let request = URLRequest(url: link)
        ibContentWebView?.load(request)
    }
}

// MARK: - WKNavigation delegate Methods
extension PageContentViewController: WKNavigationDelegate {
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
//        ibLoader.stopAnimating()
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
//        ibLoader.stopAnimating()
    }
}

// MARK: - Init Self
extension PageContentViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .properties
    }
}
