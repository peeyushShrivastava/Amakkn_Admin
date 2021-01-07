//
//  FeedbackViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 31/12/20.
//

import UIKit

class FeedbackViewController: BaseViewController {
    @IBOutlet weak var ibCollectionView: UICollectionView!
    @IBOutlet weak var ibEmptyBGView: EmptyBGView!

    let viewModel = FeedbackViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        ibEmptyBGView.delegate = self

        registerCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true

        ibEmptyBGView.updateUI()
        AppSession.manager.validSession ? ibEmptyBGView.startActivityIndicator(with: "Fetching Feedbacks...") : ibEmptyBGView.updateErrorText()

        getFeedbackList()
    }

    private func registerCell() {
        ibCollectionView.register(UINib(nibName: "FeedbackCell", bundle: nil), forCellWithReuseIdentifier: "feedbackCellID")

        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.itemSize = CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)

        ibCollectionView.collectionViewLayout = layout
    }
}

// MARK: - Navigation
extension FeedbackViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feedBackDetailsSegueID",
            let destinationVC = segue.destination as? FeedbackDetailsViewController,
            let index = sender as? Int {

            destinationVC.feedback = viewModel.getFeedbackText(at: index)
        }
    }
}

// MARK: - API Calls
extension FeedbackViewController {
    private func getFeedbackList() {
        guard AppSession.manager.validSession else { ibCollectionView.isHidden = true; ibEmptyBGView.isHidden = false; return }

        viewModel.getFeedbackList { [weak self] isListEmpty in
            self?.ibCollectionView.isHidden = isListEmpty
            self?.ibEmptyBGView.isHidden = !isListEmpty

            self?.ibCollectionView.reloadData()
        } failureCallBack: { [weak self] errorStr in
            self?.ibCollectionView.isHidden = true
            self?.ibEmptyBGView.isHidden = false
            self?.ibEmptyBGView.updateErrorText()

            self?.showAlert(with: errorStr)
        }
    }
}

// MARK: - Alert View
extension FeedbackViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension FeedbackViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedbackCellID", for: indexPath) as? FeedbackCell else { return UICollectionViewCell() }

        cell.dataSource = viewModel[indexPath.item]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "feedBackDetailsSegueID", sender: indexPath.item)
    }
}
