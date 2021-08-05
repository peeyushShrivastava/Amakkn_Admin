//
//  PhotosPageViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 29/12/20.
//

import UIKit

// MARK: - PageControl Delegate
protocol PhotosPageControlDelegate {
    func didChange(page: Int)
}

class PhotosPageViewController: UIPageViewController {

    var orderedViewControllers = [UIViewController]()

    var photos: [String]?
    var count = 0
    var pageDelegate: PhotosPageControlDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self

        updateVCs()
    }

    private func updateVCs() {
        guard let photos = photos else { return }

        for _ in photos {
            guard let newVC = PageContentViewController.instantiateSelf() else { return }
            orderedViewControllers.append(newVC)
        }

        setViewControllers([orderedViewControllers[count]],
                           direction: .forward,
                           animated: true,
                           completion: nil)

        guard let currentVC = orderedViewControllers[count] as? PageContentViewController else { return }

        currentVC.updateImage(with: photos[count])
    }
}

// MARK: - PageController Delegate / DataSource
extension PhotosPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }

        if viewControllerIndex > 0 {
            return orderedViewControllers[viewControllerIndex - 1]
        }

        return nil
    }

    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }

        if viewControllerIndex + 1 < orderedViewControllers.count {
            return orderedViewControllers[viewControllerIndex + 1]
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted _: Bool) {
        if let pageContentIndex = pageViewController.viewControllers?[0] {
            let currentIndex = orderedViewControllers.firstIndex(of: pageContentIndex) ?? 0

            guard let currentVC = orderedViewControllers[currentIndex] as? PageContentViewController else { return }
    
            currentVC.updateImage(with: photos?[currentIndex])
            
            pageDelegate?.didChange(page: currentIndex)
        }
    }
}

// MARK: - Init Self
extension PhotosPageViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .properties
    }
}
