//
//  CreateTicketViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 20/07/21.
//

import UIKit
import AVFoundation
import Photos

class CreateTicketViewController: UIViewController {
    @IBOutlet weak var ibSubjectTitle: UILabel!
    @IBOutlet weak var ibMesageTitle: UILabel!
    @IBOutlet weak var ibAddScreenShotTitle: UILabel!
    
    @IBOutlet weak var ibSubjectHolder: UIView!
    @IBOutlet weak var ibMessageHolder: UIView!
    @IBOutlet weak var ibScreenShotHolder: UIView!

    @IBOutlet weak var ibSelectSubButton: UIButton!
    @IBOutlet weak var ibNextIcon: UIImageView!
    @IBOutlet weak var ibMessageTextView: UITextView!
    @IBOutlet weak var ibCreateButton: UIButton!

    @IBOutlet weak var ibScreenShot1: UIImageView!
    @IBOutlet weak var ibScreenShot2: UIImageView!
    @IBOutlet weak var ibScreenShot3: UIImageView!
    @IBOutlet weak var ibScreenShot4: UIImageView!
    @IBOutlet weak var ibScreenShot5: UIImageView!

    let picker = UIImagePickerController()
    let viewModel = CreateTicketViewModel()

    private let maxCharCount = 100

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        updateUI()
        updateCreateButton(with: false)
    }

    private func updateUI() {
        ibSubjectHolder.layer.masksToBounds = true
        ibMessageHolder.layer.masksToBounds = true
        ibScreenShotHolder.layer.masksToBounds = true

        ibSubjectHolder.layer.borderWidth = 1.0
        ibMessageHolder.layer.borderWidth = 1.0
        ibScreenShotHolder.layer.borderWidth = 1.0

        ibSubjectHolder.layer.borderColor = AppColors.borderColor?.cgColor
        ibMessageHolder.layer.borderColor = AppColors.borderColor?.cgColor
        ibScreenShotHolder.layer.borderColor = AppColors.borderColor?.cgColor

        ibScreenShot1.image = UIImage(named: "icRoomsPlus")
    }

    private func updateCreateButton(with state: Bool) {
        ibCreateButton.isUserInteractionEnabled = state
        ibCreateButton.alpha = state ? 1.0 : 0.5
    }
}

// MARK: - Button Action
extension CreateTicketViewController {
    @IBAction func createButtonTapped(_ sender: UIButton) {
        viewModel.createTicket(with: ibMessageTextView.text)
    }

    @IBAction func addScreenShot(_ sender: UIButton) {
        switch sender.tag {
            case 1:
                guard let image = ibScreenShot1.image else { return }
                image == UIImage(named: "icRoomsPlus") ? showActionSheet(for: sender) : viewImage(for: viewModel.getimageURL())
            case 2:
                guard let image = ibScreenShot2.image else { return }
                image == UIImage(named: "icRoomsPlus") ? showActionSheet(for: sender) : viewImage(for: viewModel.getimageURL())
            case 3:
                guard let image = ibScreenShot3.image else { return }
                image == UIImage(named: "icRoomsPlus") ? showActionSheet(for: sender) : viewImage(for: viewModel.getimageURL())
            case 4:
                guard let image = ibScreenShot4.image else { return }
                image == UIImage(named: "icRoomsPlus") ? showActionSheet(for: sender) : viewImage(for: viewModel.getimageURL())
            case 5:
                guard let image = ibScreenShot5.image else { return }
                image == UIImage(named: "icRoomsPlus") ? showActionSheet(for: sender) : viewImage(for: viewModel.getimageURL())
            default:
                return
        }
    }
}

// MARK:- Navigation
extension CreateTicketViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subjectsSegueID" {
            guard let subjectsVC =  segue.destination as? SelectSubjectViewController else { return }

            subjectsVC.subject = { [weak self] subjectModel in
                self?.viewModel.updateSubject(subjectModel?.subject)

                self?.ibSelectSubButton.setTitle(subjectModel?.subject, for: .normal)
                self?.updateCreateButton(with: true)
            }
        }
    }
}

// MARK: - UIAlertView
extension CreateTicketViewController {
    private func showAlert(for errorStr: String?) {
        let alertController = UIAlertController(title: errorStr, message: nil, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .cancel, handler: { [weak self] _ in
            guard self?.viewModel.isForCreate ?? false else { return }

            self?.navigationController?.popViewController(animated: true)
        }))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - ViewModel Delegate
extension CreateTicketViewController: TicketsListDelegate {
    func success() {
        guard !viewModel.isForCreate else { showAlert(for: "A ticket has been created successfully!"); return }

        updateScreenShots()
    }

    func failed(with errorStr: String?) {
        showAlert(for: errorStr)
    }
}

// MARK: - Update ScreenShots
extension CreateTicketViewController {
    private func updateScreenShots() {
        let (imageURL, index) = viewModel.getLastScreenShot()
        guard index >= 0, let imageURLStr = imageURL else { return }

        switch index {
            case 0:
                ibScreenShot1.image = nil
                ibScreenShot1.layer.masksToBounds = true
                ibScreenShot1.layer.borderWidth = 1.0
                ibScreenShot1.layer.borderColor = AppColors.borderColor?.cgColor

                ibScreenShot1.sd_setImage(with: URL(string: imageURLStr), placeholderImage: UIImage(named: "PropertyDetailFloorPlanImagePlaceHolder"))

                ibScreenShot2.image = UIImage(named: "icRoomsPlus")
            case 1:
                ibScreenShot2.image = nil
                ibScreenShot2.layer.masksToBounds = true
                ibScreenShot2.layer.borderWidth = 1.0
                ibScreenShot2.layer.borderColor = AppColors.borderColor?.cgColor

                ibScreenShot2.sd_setImage(with: URL(string: imageURLStr), placeholderImage: UIImage(named: "PropertyDetailFloorPlanImagePlaceHolder"))

                ibScreenShot3.image = UIImage(named: "icRoomsPlus")
            case 2:
                ibScreenShot3.image = nil
                ibScreenShot3.layer.masksToBounds = true
                ibScreenShot3.layer.borderWidth = 1.0
                ibScreenShot3.layer.borderColor = AppColors.borderColor?.cgColor

                ibScreenShot3.sd_setImage(with: URL(string: imageURLStr), placeholderImage: UIImage(named: "PropertyDetailFloorPlanImagePlaceHolder"))

                ibScreenShot4.image = UIImage(named: "icRoomsPlus")
            case 3:
                ibScreenShot4.image = nil
                ibScreenShot4.layer.masksToBounds = true
                ibScreenShot4.layer.borderWidth = 1.0
                ibScreenShot4.layer.borderColor = AppColors.borderColor?.cgColor

                ibScreenShot4.sd_setImage(with: URL(string: imageURLStr), placeholderImage: UIImage(named: "PropertyDetailFloorPlanImagePlaceHolder"))

                ibScreenShot5.image = UIImage(named: "icRoomsPlus")
            case 4:
                ibScreenShot5.image = nil
                ibScreenShot5.layer.masksToBounds = true
                ibScreenShot5.layer.borderWidth = 1.0
                ibScreenShot5.layer.borderColor = AppColors.borderColor?.cgColor

                ibScreenShot5.sd_setImage(with: URL(string: imageURLStr), placeholderImage: UIImage(named: "PropertyDetailFloorPlanImagePlaceHolder"))
            default:
            /// Do nothing
            break
        }
    }
}

// MARK: - UITextView Delegate Methods
extension CreateTicketViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else { ibMessageHolder.endEditing(true); return false }

        if let string = textView.text, let textRange = Range(range, in: string) {
            let updatedTextCount = string.replacingCharacters(in: textRange, with: text).count

            if updatedTextCount > maxCharCount {
                return false
            }
            if updatedTextCount > 0, string.replacingCharacters(in: textRange, with: text) == " " {
                return false
            }
        }

        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
}

// MARK: - Camera / Gallery Methods
extension CreateTicketViewController {
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

        viewModel.uploadToS3(imageData: compressedImageData)
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
extension CreateTicketViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
extension CreateTicketViewController: PhotoPickerDelegate {
    func didUpdateWith(image: UIImage?) {
        guard let image = image else { return }

        AppLoader.show()

        uploadToS3Server(image: image)
    }
}

// MARK: - UIActionSheet
extension CreateTicketViewController {
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

        alertController.addAction(UIAlertAction(title: "Alert_Cancel".localized(), style: .destructive, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))

        if let popoverPresentationController = alertController.popoverPresentationController { popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.frame
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.up
        }
    
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - View Image
extension CreateTicketViewController {
    private func viewImage(for images: [String]?) {
        guard let imageURLs = images  else { return }
        guard let photoVC = PhotosViewController.instantiateSelf() else { return }

        photoVC.photos = imageURLs
        navigationController?.pushViewController(photoVC, animated: true)
    }
}

// MARK: - Init Self
extension CreateTicketViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .more
    }
}
