//
//  PhotosViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 29/12/20.
//

import UIKit

class PhotosViewController: UIViewController {
    @IBOutlet weak var ibContainerView: UIView!
    @IBOutlet weak var ibPhotoCounterLabel: UILabel!

    var counter = 1
    var photos: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()

        updateContainerView()
        updateCounter(with: counter)
    }

    private func updateCounter(with selectedIndex: Int) {
        ibPhotoCounterLabel.text = "\(selectedIndex) of \(photos?.count ?? 0)"
    }
}

// MARK: - Update Container View
extension PhotosViewController {
    private func updateContainerView() {
        guard let pageVC = PhotosPageViewController.instantiateSelf() else { return }

        pageVC.photos = photos
        pageVC.count = counter-1

        addChild(pageVC)

        //  Use the container's BOUNDS - to have a 0 reference
        pageVC.view.frame = ibContainerView.bounds
        pageVC.pageDelegate = self
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false

        ibContainerView.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
    }
}

// MARK: - PageControl Delegate
extension PhotosViewController: PhotosPageControlDelegate {
    func didChange(page: Int) {
        updateCounter(with: page)
    }
}

// MARK: - Init Self
extension PhotosViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .properties
    }
}
