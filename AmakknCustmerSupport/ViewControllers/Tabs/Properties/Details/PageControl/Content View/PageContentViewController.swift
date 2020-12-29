//
//  PageContentViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 29/12/20.
//

import UIKit
import SDWebImage

class PageContentViewController: UIViewController {
    @IBOutlet weak var ibPhotoImageView: UIImageView!
    @IBOutlet weak var ibLoader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func updateImage(with urlStr: String?) {
        guard let urlStr = urlStr else { return }

        ibLoader.isHidden = false

        ibPhotoImageView.sd_setImage(with: URL(string: urlStr), placeholderImage:UIImage(), options: SDWebImageOptions.progressiveLoad, completed: { [weak self] image, _, _, _ in
            guard let image = image else { return }

            self?.ibPhotoImageView.image = image
            self?.ibLoader.stopAnimating()
        })
    }
}

// MARK: - Init Self
extension PageContentViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .properties
    }
}
