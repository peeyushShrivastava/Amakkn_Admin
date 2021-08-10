//
//  TicketDetailsViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import UIKit
import AVFoundation
import Photos

class TicketDetailsViewController: UIViewController {
    @IBOutlet weak var ibPropertyInfoView: PropertyInfoView!
    @IBOutlet weak var ibPropertyInfoViewHeight: NSLayoutConstraint!

    @IBOutlet weak var ibViolationHolder: UIView!
    @IBOutlet weak var ibViolationLabel: UILabel!
    @IBOutlet weak var ibViolationHeight: NSLayoutConstraint!

    @IBOutlet weak var ibScrollContainerView: UIView!

    let picker = UIImagePickerController()
    var scrollView = UIScrollView()

    private var scrollHolderHeight: CGFloat = 0.0

    let viewModel = TicketDetailsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        title = viewModel.title

        /// Get Ticket Details
        viewModel.getTicketDetails()
        viewModel.getStatusList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationHandler.manager.delegate = self
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationHandler.manager.delegate = nil
    }

    private func updateInfoView() {
        guard let propertyInfo = viewModel.propertyInfo else { ibPropertyInfoView.isHidden = true; ibPropertyInfoViewHeight.constant = 0.0; return }

        ibPropertyInfoView.delegate = self
        ibPropertyInfoView.update(with: propertyInfo)

        ibPropertyInfoView.layer.masksToBounds = true
        ibPropertyInfoView.layer.borderWidth = 1.0
        ibPropertyInfoView.layer.borderColor = AppColors.borderColor?.cgColor
    }

    private func updateViolation() {
        guard let violation = viewModel.getViolation(), violation.hasViolation != "0" else { ibViolationHolder.isHidden = true; ibViolationHeight.constant = 0.0; return }

        ibViolationHolder.isHidden = false
        ibViolationLabel.text = violation.violationText
    }
}

// MARK: - Navigation
extension TicketDetailsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addViolationSegueID" {
            guard let violationVC =  segue.destination as? CreateViolationViewController else { return }

            violationVC.viewModel.updateTicketID(viewModel.getTicketID())
            violationVC.viewModel.updateUserInfo(viewModel.getUserInfo())
        } else if segue.identifier == "createTicketSegueID" {
            guard let ticketVC =  segue.destination as? CreateTicketViewController else { return }

            ticketVC.viewModel.updatePropertyInfo(viewModel.getPropertyInfo())
            ticketVC.viewModel.updateUserInfo(viewModel.getUserInfo())
            ticketVC.viewModel.updateParentTicketID(viewModel.getparentTicketID())
        }
    }
}

// MARK: - Button Actions
extension TicketDetailsViewController {
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.getTicketDetails()
    }

    @IBAction func moreButtonTapped(_ sender: UIBarButtonItem) {
        guard let barButtonItem = navigationItem.rightBarButtonItem else { return }
        guard let buttonItemView = barButtonItem.value(forKey: "view") as? UIView else { return }

        let moreMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let userInfo = UIAlertAction(title: "User Info", style: .default, handler: { [weak self] _ in
            guard let userDetailsVC = UserDetailsViewController.instantiateSelf() else { return }

            userDetailsVC.viewModel.userID = self?.viewModel.getUserID()
            userDetailsVC.viewModel.updateDataSource(with: nil)

            self?.navigationController?.pushViewController(userDetailsVC, animated: true)
        })
        let createTicket = UIAlertAction(title: "Create a Linked Ticket" , style: .default, handler: { [weak self] _ in
            self?.performSegue(withIdentifier: "createTicketSegueID", sender: nil)
        })
        let addViolation = UIAlertAction(title: "Add violation to this User", style: .default, handler: { [weak self] _ in
            self?.performSegue(withIdentifier: "addViolationSegueID", sender: nil)
        })
        let cancelAction = UIAlertAction(title: "Alert_Cancel".localized(), style: .cancel, handler: nil)

        /// Add Actions
        moreMenu.addAction(userInfo)
        moreMenu.addAction(createTicket)
        moreMenu.addAction(addViolation)
        moreMenu.addAction(cancelAction)

        /// Applicable for iPad
        moreMenu.popoverPresentationController?.sourceRect = buttonItemView.bounds
        moreMenu.popoverPresentationController?.sourceView = buttonItemView

        present(moreMenu, animated: true, completion: nil)
    }
}

// MARK: - UIAlertView
extension TicketDetailsViewController {
    private func showAlert(for errorStr: String?) {
        let alertController = UIAlertController(title: errorStr, message: nil, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - TicketList Delegate
extension TicketDetailsViewController: TicketsListDelegate {
    func success() {
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        scrollView.frame = CGRect.zero
        scrollView.contentSize.height = 0.0
        scrollView.removeFromSuperview()

        updateViolation()
        updateInfoView()
        updateUI()

        if viewModel.statusChanged {
            viewModel.statusChanged = false

            showAlert(for: "Ticket Status has been changed Successfully!")
        }
    }

    func failed(with errorStr: String?) {
        showAlert(for: errorStr)
    }
}

// MARK: - AppNotification Delegate
extension TicketDetailsViewController: AppNotificationDelegate {
    func didReceiveNotification(for ticketID: String?) {
        guard ticketID == viewModel.getTicketID() else { return }

        viewModel.getTicketDetails()
    }
}

// MARK: - Update Status
extension TicketDetailsViewController {
    private func updateUI() {
        guard let details = viewModel.getDetails() else { return }

        if scrollHolderHeight == 0.0 {
            scrollHolderHeight = ibScrollContainerView.frame.height
        }

        let height = ibPropertyInfoViewHeight.constant == 0.0 ? ibScrollContainerView.frame.height+90.0 : ibScrollContainerView.frame.height
        scrollView.frame = CGRect(x: 0.0, y: 0.0, width: ibScrollContainerView.frame.width, height: (ibViolationHeight.constant == 0.0 ? height+ibViolationHeight.constant+40.0 : height))
        scrollView.showsVerticalScrollIndicator = false
        ibScrollContainerView.addSubview(scrollView)

        let contentX: CGFloat = 20.0
        let contentWidth: CGFloat = (scrollView.frame.size.width - (contentX*2))
        var prevContentY: CGFloat = 0.0

        for (count, state) in details.enumerated() {
            let contentHeight = state.isActive == "0" ? 100.0 : getHeight(for: state)
            let contentY = prevContentY

            let contentView = UIView(frame: CGRect(x: contentX, y: contentY, width: contentWidth, height: contentHeight))

            let statusView = state.isActive == "0" ? getInActiveView(for: state, with: contentView) : getActiveView(for: state, with: contentView, at: count)

            let scrollViewHeight: CGFloat = scrollView.contentSize.height+contentHeight

            scrollView.contentSize = CGSize(width: ibScrollContainerView.frame.size.width, height: scrollViewHeight)
            scrollView.addSubview(statusView)

            prevContentY = scrollViewHeight
        }

        if viewModel.getFeedback()?.isUserHappy != "-1" {
            let contentHeight: CGFloat = 180.0
            let contentView = UIView(frame: CGRect(x: contentX, y: prevContentY, width: contentWidth, height: contentHeight))

            let feedbackView = getFeedbackView(with: contentView)
            let scrollViewHeight: CGFloat = scrollView.contentSize.height+contentHeight

            scrollView.contentSize = CGSize(width: view.frame.size.width, height: scrollViewHeight)
            scrollView.addSubview(feedbackView)
        }
    }

    private func getActiveView(for state: TicketDetails, with contentView: UIView, at index: Int) -> UIView {
        guard let statusView = Bundle.main.loadNibNamed("TDCustomView", owner: self, options: nil)?.first as? TDCustomView else { return UIView() }

        statusView.frame = contentView.frame
        statusView.center = contentView.center
        statusView.isTicketClosed = viewModel.checkClosedStatus(for: state.status, at: index)
        statusView.ticketModel = state

        statusView.delegate = self

        return statusView
    }

    private func getInActiveView(for state: TicketDetails, with contentView: UIView) -> UIView {
        guard let statusView = Bundle.main.loadNibNamed("TDCustomInActiveView", owner: self, options: nil)?.first as? TDCustomInActiveView else { return UIView() }

        statusView.frame = contentView.frame
        statusView.center = contentView.center
        statusView.ticketModel = state

        return statusView
    }

    private func getFeedbackView(with contentView: UIView) -> UIView {
        guard let feedbackView = Bundle.main.loadNibNamed("TDSubmitFeedback", owner: self, options: nil)?.first as? TDSubmitFeedback else { return UIView() }

        feedbackView.frame = contentView.frame
        feedbackView.center = contentView.center
        feedbackView.feedback = viewModel.getFeedback()

        return feedbackView
    }

    private func getHeight(for state: TicketDetails) -> CGFloat {
        let verticalSpacing: CGFloat = 10.0
        let titleHeight: CGFloat = 30.0
        let imageHolderHeight: CGFloat = state.images?.count == 0 ? (state.isActive == "-1" ? 0.0 : 50.0) : 50.0
        let commentHolderHeight: CGFloat = state.isActive == "1" ? 140.0 : 20.0
        let commentsHeight: CGFloat = state.comments?.count == 0 ? 0.0 : getCommentsHeight(state.comments)
        let bottomHeight: CGFloat = 30.0

        let totalHeight = titleHeight + verticalSpacing + imageHolderHeight + commentsHeight + commentHolderHeight + bottomHeight
        return totalHeight
    }

    private func getCommentsHeight(_ comments: [DetailsComment]?) -> CGFloat {
        guard let comments = comments, comments.count != 0 else { return 0.0 }

        let maxWidth: CGFloat = 255.0
        let maxHeight: CGFloat = 1000.0
        let fontSize: CGFloat = 15.0
        let spacing: CGFloat = 40.0
        var height: CGFloat = 0.0

        for comment in comments {
            guard let text = comment.text else { return 0.0 }
            /// Calculate estimated frame for Chat Bubble / Text label
            let size = CGSize(width: maxWidth, height: maxHeight)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], context: nil)

            height += (estimatedFrame.height + spacing)
        }

        return height
    }
}

// MARK: - TDCustomView Delegate
extension TicketDetailsViewController: TDCustomViewDelegate {
    func changeStatusDidTapped(for status: String?, and statusID: String?) {
        showActionSheet(for: status, and: statusID)
    }

    func sendDidTapped(with comment: String?, for statusID: String?) {
        viewModel.addComment(comment, for: statusID)
    }

    func addImage(for sender: UIButton, and statusID: String?) {
        viewModel.updateStatusID(statusID)

        showActionSheet(for: sender)
    }

    func viewImage(for images: [String]?, at index: Int) {
        guard let imageURLs = images  else { return }
        guard let photoVC = PhotosViewController.instantiateSelf() else { return }

        photoVC.photos = imageURLs
        photoVC.counter = index
        navigationController?.pushViewController(photoVC, animated: true)
    }

    private func showActionSheet(for sender: UIButton) {
        let  alertController = UIAlertController(title: "More_Choose_Photo".localized(), message: "", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "More_Camera".localized(), style: .default, handler: { _ in
            DispatchQueue.main.async { [weak self] in
                self?.cameraTapped()
            }
        }))
        alertController.addAction(UIAlertAction(title: "More_Gallery".localized(), style: .default, handler: { _ in
            DispatchQueue.main.async { [weak self] in
                self?.galleryTapped()
            }
        }))
        alertController.addAction(UIAlertAction(title: "Documents", style: .default, handler: { [weak self] _ in
            let supportedTypes: [UTType] = [.text, .pdf, .rtf]
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)

            picker.delegate = self
            picker.modalPresentationStyle = UIModalPresentationStyle.fullScreen

            self?.present(picker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Alert_Cancel".localized(), style: .destructive, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))

        if let popoverPresentationController = alertController.popoverPresentationController { popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.frame
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.up
        }
    
        present(alertController, animated: true, completion: nil)
    }

    private func showActionSheet(for statusID: String?, and fromStatusID: String?) {
        let  alertController = UIAlertController(title: "Change Status", message: "", preferredStyle: .actionSheet)

        viewModel.statusList?.forEach({ status in
            alertController.addAction(UIAlertAction(title: status.statusName, style: .default, handler: { _ in
                DispatchQueue.main.async { [weak self] in
                    guard status.statusID != statusID else { self?.showAlert(for: "Cannot change selected Status to same Status."); return }

                    self?.viewModel.changeStatus(for: status.statusID, status: statusID, and: fromStatusID)
                }
            }))
        })

        alertController.addAction(UIAlertAction(title: "Alert_Cancel".localized(), style: .destructive, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Camera / Gallery Methods
extension TicketDetailsViewController {
    private func cameraTapped() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                picker.allowsEditing = false
                picker.sourceType = .camera
                picker.delegate = self
                picker.modalPresentationStyle = .overCurrentContext
                self.tabBarController?.tabBar.isHidden = true
                present(picker, animated: true, completion: nil)
            } else {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        DispatchQueue.main.async(execute: {
                            self.picker.allowsEditing = false
                            self.picker.sourceType = .camera
                            self.picker.delegate = self
                            self.picker.modalPresentationStyle = .overCurrentContext
                            self.tabBarController?.tabBar.isHidden = true
                            self.present(self.picker, animated: true, completion: nil)
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            let alertController = UIAlertController(title: "Camera_Disabled".localized(), message: "Reeanble_Camera".localized(), preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "wanted_go_to_settings".localized(), style: .cancel, handler: { action in
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }
                             _ = self.navigationController?.popViewController(animated: false)
                            }))
                            alertController.addAction(UIAlertAction(title: "Alert_Cancel".localized(), style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        })
                    }
                })
            }
        }
    }

    private func galleryTapped() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            DispatchQueue.main.async { [weak self] in
                self?.showImagePicker()
            }
        case .denied, .restricted :
            DispatchQueue.main.async(execute: {
                let alertController = UIAlertController(title: "Gallery_Disabled".localized(), message: "Reeanble_Gallery".localized(), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "wanted_go_to_settings".localized(), style: .cancel, handler: { action in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                 _ = self.navigationController?.popViewController(animated: false)
                }))
                alertController.addAction(UIAlertAction(title: "Alert_Cancel".localized(), style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            })
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async { [weak self] in
                        self?.showImagePicker()
                    }
                case .denied, .restricted:
                    DispatchQueue.main.async(execute: {
                        let alertController = UIAlertController(title: "Gallery_Disabled".localized(), message: "Reeanble_Gallery".localized(), preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "wanted_go_to_settings".localized(), style: .cancel, handler: { action in
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            }
                         _ = self.navigationController?.popViewController(animated: false)
                        }))
                        alertController.addAction(UIAlertAction(title: "Alert_Cancel".localized(), style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    })
                case .notDetermined:
                    DispatchQueue.main.async(execute: {
                        let alertController = UIAlertController(title: "Gallery_Disabled".localized(), message: "Reeanble_Gallery".localized(), preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "wanted_go_to_settings".localized(), style: .cancel, handler: { action in
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            }
                         _ = self.navigationController?.popViewController(animated: false)
                        }))
                        alertController.addAction(UIAlertAction(title: "Alert_Cancel".localized(), style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    })
                default: break
                }
            }
        default: break
        }
    }

    private func showImagePicker() {
        let galleryVC = AppPhotoPickerViewController(nibName: "AppPhotoPickerViewController", bundle: nil)
        galleryVC.delegate = self

        let navController = UINavigationController(rootViewController: galleryVC)
        navController.modalPresentationStyle = .overFullScreen

        present(navController, animated: true, completion: nil)
    }

    private func uploadToS3Server(image: UIImage?) {
        guard let image = image else { return }
        guard let compressedImageData = reduceImageSize(in: 200, image: image) else { return }

        viewModel.uploadToS3(imageData: compressedImageData, for: "png")
    }

    func reduceImageSize(in kiloByte: Int, image: UIImage) -> Data? {
        var actualHeight = image.size.height
        var actualWidth = image.size.width
        var imgRatio = actualWidth / actualHeight

        let maxHeight: CGFloat = 1920.0
        let maxWidth: CGFloat = 1080.0
        let maxRatio = maxWidth / maxHeight

        if (actualHeight > maxHeight) || (actualWidth > maxWidth) {
            if (imgRatio < maxRatio) {
                imgRatio = maxHeight / actualHeight;
                actualWidth = (imgRatio * actualWidth);
                actualHeight = maxHeight;
            } else if (imgRatio > maxRatio) {
                imgRatio = maxWidth / actualWidth;
                actualHeight = (imgRatio * actualHeight);
                actualWidth = maxWidth;
            } else {
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }

        let resizedImageData = resizeImage(image, targetSize: CGSize(width: actualWidth, height: actualHeight))

        return resizedImageData
    }

    func resizeImage(_ image: UIImage, targetSize: CGSize) -> Data? {
        let compressionQuality = 1.0
        let rect = CGRect(x: 0.0, y: 0.0, width: targetSize.width, height: targetSize.height)

        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)

        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImageData = resizedImage?.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()

        return resizedImageData
    }
}

// MARK: - Image Picker Delegates
extension TicketDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let chosenImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage else { return }

        AppLoader.show()

        uploadToS3Server(image: chosenImage)

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
}

// MARK: - Custom Photo Picker Delegates
extension TicketDetailsViewController: PhotoPickerDelegate {
    func didUpdateWith(image: UIImage?) {
        guard let image = image else { return }

        AppLoader.show()

        uploadToS3Server(image: image)
    }
}

// MARK: - Documents Delegate
extension TicketDetailsViewController: UIDocumentPickerDelegate {
    func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        urls.forEach { url in
            _ = url.startAccessingSecurityScopedResource()

            let coordinator = NSFileCoordinator()

            var error: NSError?

            coordinator.coordinate(readingItemAt: url, options: [], error: &error, byAccessor: { [weak self] url in
                guard let extStr = url.absoluteString.components(separatedBy: ".").last else { self?.showAlert(for: "Invalid file format. Only .pdf, .png, .jpg extensions are allowed."); return }
                guard extStr == "pdf" || extStr == "png" || extStr == "jpg" else { self?.showAlert(for: "Invalid file format. Only .pdf, .png, .jpg extensions are allowed."); return }
                guard let fileData = try? Data(contentsOf: url) else { return }

                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    AppLoader.show()
                }
                self?.viewModel.uploadToS3(imageData: fileData, for: extStr)
            })

            url.stopAccessingSecurityScopedResource()
        }
    }

    func documentPickerWasCancelled(_: UIDocumentPickerViewController) {
    }
}

// MARK: - PropertyInfo Delegate
extension TicketDetailsViewController: PropertyInfoDelegate {
    func infoDidTapped() {
        guard let propertyDetailsVC = PropertyDetailsViewController.instantiateSelf() else { return }

        propertyDetailsVC.viewModel.update(with: viewModel.propertyID)

        navigationController?.pushViewController(propertyDetailsVC, animated: true)
    }
}

// MARK: - Init Self
extension TicketDetailsViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .more
    }
}
