//
//  PropertyDetailsViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 25/10/20.
//

import UIKit

class PropertyDetailsViewController: UIViewController {
    @IBOutlet weak var ibCollectionView: UICollectionView!

    var detailsHeaderView: PropertyDetailsHeaderView?

    let viewModel = PropertyDetailsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        updateCollection()
        registerCells()

        getPropertyDetails()
        getComplaints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.barTintColor = AppColors.viewBGColor
        self.navigationController?.navigationBar.isTranslucent = false

        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.isHidden = false
    }

    private func updateCollection() {
        ibCollectionView.contentInsetAdjustmentBehavior = .never
        ibCollectionView.collectionViewLayout = PropertyDetailsFlowlayout()

        guard let layout = ibCollectionView.collectionViewLayout as? PropertyDetailsFlowlayout else { return }

        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0)
    }

    private func registerCells() {
        ibCollectionView.register(UINib(nibName: "DescriptionCell", bundle: nil), forCellWithReuseIdentifier: "DescriptionCell")
        ibCollectionView.register(UINib(nibName: "OverviewCell", bundle: nil), forCellWithReuseIdentifier: "OverviewCell")
        ibCollectionView.register(UINib(nibName: "AmenitiesCell", bundle: nil), forCellWithReuseIdentifier: "AmenitiesCell")
        ibCollectionView.register(UINib(nibName: "RentOptionsCell", bundle: nil), forCellWithReuseIdentifier: "RentOptionsCell")
        ibCollectionView.register(UINib(nibName: "LocationCell", bundle: nil), forCellWithReuseIdentifier: "LocationCell")
        ibCollectionView.register(UINib(nibName: "VisitingHoursCell", bundle: nil), forCellWithReuseIdentifier: "VisitingHoursCell")
        ibCollectionView.register(UINib(nibName: "FloorPlansCell", bundle: nil), forCellWithReuseIdentifier: "FloorPlansCell")
        ibCollectionView.register(UINib(nibName: "UserInfoCell", bundle: nil), forCellWithReuseIdentifier: "UserInfoCell")
        ibCollectionView.register(UINib(nibName: "ComplaintsCell", bundle: nil), forCellWithReuseIdentifier: "ComplaintsCell")

        ibCollectionView.register(UINib(nibName: "PropertyDetailsHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerViewID")
    }
}

// MARK: - Navigation
extension PropertyDetailsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoViewerSegueID",
            let destinationVC = segue.destination as? PhotosViewController {
            guard let images = sender as? [String] else { return }

            destinationVC.photos = images
        }
    }
}

// MARK: - Alert View
extension PropertyDetailsViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - API Calls
extension PropertyDetailsViewController {
    private func getPropertyDetails() {
        viewModel.getPropertyDetails(successCallBack: { [weak self] in
            DispatchQueue.main.async {
                self?.ibCollectionView.reloadData()
            }
        }, failureCallBack: { _ in
            // Error
        })
    }

    private func getComplaints() {
        viewModel.getcomplaints { [weak self] in
            self?.ibCollectionView.reloadData()
        }
    }
}

// MARK: - Push VCs
extension PropertyDetailsViewController {
    private func pushPhotoGalleryVC(with images: [String]?) {
        performSegue(withIdentifier: "photoViewerSegueID", sender: images)
    }

    private func pushQRCodeVC(with model: DetailsHeaderModel?) {
//        guard let qrCodeVC = self.storyboard?.instantiateViewController(withIdentifier: "PropertyDetailQRCode") as? PropertyDetailQRCodeController else { return }
//
//        qrCodeVC.model = model
//
//        navigationController?.pushViewController(qrCodeVC, animated: true)
    }
}

// MARK: - UICollectionView Delegate / Data Source
extension PropertyDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dataSource = viewModel[indexPath.item]

        let detailCell = collectionView.dequeueReusableCell(withReuseIdentifier: type(of: dataSource).reuseCellID, for: indexPath)
    
        dataSource.configure(detailCell)

        if let locationCell = detailCell as? LocationCell {
            locationCell.delegate = self
        }

        if let visitingHrsCell = detailCell as? VisitingHoursCell {
            visitingHrsCell.delegate = self
        }

        if let floorPlanCell = detailCell as? FloorPlansCell {
            floorPlanCell.delegate = self
        }

        if let hostInfoCell = detailCell as? UserInfoCell {
            hostInfoCell.delegate = self
        }

        if let complaintsCell = detailCell as? ComplaintsCell {
            complaintsCell.delegate = self
        }

        return detailCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: viewModel.height(for: indexPath.row))
    }
}

// MARK: - UICollectionView FlowLayout Delegate
extension PropertyDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerViewID", for: indexPath) as? PropertyDetailsHeaderView else { return UICollectionReusableView() }

        detailsHeaderView = headerView
        detailsHeaderView?.model = viewModel.headerDataSource()
        detailsHeaderView?.delegate = self

        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let percentage: CGFloat = Utility.shared.hasNotch ? 0.45 : 0.6
        return .init(width: view.frame.width, height: view.frame.height*percentage)
    }
}

// MARK: - HeaderView Delegate
extension PropertyDetailsViewController: PropertyDetailsHeaderDelegate {
    func didQRCodeTapped(with model: DetailsHeaderModel?) {
        pushQRCodeVC(with: model)
    }

    func showGallery(with images: [String]?) {
        pushPhotoGalleryVC(with: images)
    }
}

// MARK: - Location Delegate
extension PropertyDetailsViewController: DetailsLocationDelegate {
    func neighbourhoodDidTap(at location: DetailsLocationModel?) {
        guard let viewLocationVC = ViewLocationViewController.instantiateSelf() else { return }

        viewLocationVC.location = location

        navigationController?.pushViewController(viewLocationVC, animated: true)
    }
}

// MARK: - Visiting Hrs Delegate
extension PropertyDetailsViewController: DetailsVisitingsHrsDelegate {
    func callDidTap(with phone: String?, and countryCode: String?) {
//        viewModel.call(with: countryCode, and: phone, failureCallBack: { [weak self] errorStr in
//            self?.showAlert(with: errorStr)
//        })
    }
}

// MARK: - FloorPlan Delegate
extension PropertyDetailsViewController: DetailsFloorPlanDelegate {
    func didSelect(_ floorPlan: String?, at index: Int) {
        guard let floorPlan = floorPlan else { return }
//        guard let webVC = self.storyboard?.instantiateViewController(withIdentifier: "PropertyDetailWebView") as? PropertyDetailWebViewController else { return }
//
//        webVC.urlStringToLoad = floorPlan
//        webVC.viewTitle = "\(index+1)"
//
//        navigationController?.pushViewController(webVC, animated: true)
    }
}

// MARK: - HostInfo Delegate
extension PropertyDetailsViewController: DetailsHostdelegate {
    func companyDidTapped(for companyID: String?, and userType: String?) {
        guard let companyID = companyID, let userType = userType else { return }
//        guard let companyDetailsVC = UIStoryboard.init(name: "Realtor", bundle: nil).instantiateViewController(withIdentifier: "CompanyDetailsViewControllerId") as? CompanyDetailsViewController else { return }
//
//        companyDetailsVC.companyId = companyID
//        companyDetailsVC.userType = userType
//
//        if userType == UserType.broker.rawValue {
//            companyDetailsVC.isCompany = "0"
//        }
//
//        navigationController?.pushViewController(companyDetailsVC, animated: true)
    }

    func hostDidTapped(for userID: String?, and userType: String?) {
        guard let userID = userID, let userType = userType else { return }
//        guard let agentProfileVC = UIStoryboard.init(name: "Agents", bundle: nil).instantiateViewController(withIdentifier: "AgentProfileViewControllerId") as? AgentProfileViewController else { return }
//
//        agentProfileVC.userId = userID
//        agentProfileVC.userType = userType
//
//        navigationController?.pushViewController(agentProfileVC, animated: true)
    }
}

// MARK: - Complaints delegate
extension PropertyDetailsViewController: ComplaintsDelegate {
    func didSelectCall(with phone: String?, _ countryCode: String?) {
        viewModel.call(with: phone, countryCode) { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.showAlert(with: errorStr)
            }
        }
    }

    func didSelectChat(at index: Int) {
        viewModel.getChatModel(at: index) { [weak self] chatModel in
            DispatchQueue.main.async {
                self?.pushChatVC(with: chatModel)
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.showAlert(with: errorStr)
            }
        }
    }

    func resolveComplaint(id: String?) {
        viewModel.resolveComplaint(id: id)
    }
}

// MARK: - Push Chat VC
extension PropertyDetailsViewController {
    private func pushChatVC(with chatModel: ChatInboxModel?) {
        guard let chatVC = ChatViewController.instantiateSelf() else { return }

        chatVC.viewModel.update(chatInboxModel: chatModel)
        chatVC.subject = viewModel.subjectID

        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - Init Self
extension PropertyDetailsViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .properties
    }
}
