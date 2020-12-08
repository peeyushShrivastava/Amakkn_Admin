//
//  InboxViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import UIKit

class InboxViewController: BaseViewController {
    @IBOutlet weak var ibInboxCollectionView: UICollectionView!
    @IBOutlet weak var ibEmptyBGView: EmptyBGView!

    let viewModel = InboxViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        ibEmptyBGView.delegate = self
        ibEmptyBGView.updateUI()

        registerCell()
        viewModel.getSubjects()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getChats()
    }

    private func registerCell() {
        ibInboxCollectionView.register(UINib(nibName: "ChatInboxCell", bundle: nil), forCellWithReuseIdentifier: "chatInboxCellID")
        ibInboxCollectionView.register(UINib(nibName: "LoaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "LoaderView")

        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.itemSize = CGSize(width: viewModel.cellWidth, height: viewModel.cellHeight)

        ibInboxCollectionView.collectionViewLayout = layout
    }
}

// MARK: - Button Actions
extension InboxViewController {
    @IBAction func filterBottonTapped(_ sender: UIBarButtonItem) {
        guard let popOverVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatSubjectsViewController") as? ChatSubjectsViewController else { return }

        popOverVC.modalPresentationStyle = .popover
        popOverVC.subjects = viewModel.chatSubjects
        popOverVC.delegate = self

        let popOver = popOverVC.popoverPresentationController
        popOver?.barButtonItem = sender
        popOver?.delegate = self

        present(popOverVC, animated: true, completion:nil)
    }
}

// MARK: - UIPopover Delegate
extension InboxViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - API Calls
extension InboxViewController {
    private func getChats() {
        viewModel.getSupportChatList { [weak self] isListEmpty in

            self?.ibInboxCollectionView.isHidden = isListEmpty
            self?.ibEmptyBGView.isHidden = !isListEmpty

            self?.ibInboxCollectionView.reloadData()
        } failureCallBack: { [weak self] errorStr in
            self?.ibInboxCollectionView.isHidden = true
            self?.ibEmptyBGView.isHidden = false

            self?.showAlert(with: errorStr)
        }
    }
}

// MARK: - Alert View
extension InboxViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: "Amakkn_Alert_Text".localized(), message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView Delegate / DataSource
extension InboxViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatInboxCellID", for: indexPath) as? ChatInboxCell else { return UICollectionViewCell() }

        cell.inboxModel = viewModel[indexPath.item]

        if viewModel.apiCallIndex == indexPath.row, viewModel.isMoreDataAvailable {
            viewModel.apiCallIndex += 10
            getChats()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter, viewModel.isMoreDataAvailable  else { return UICollectionReusableView() }

        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoaderView", for: indexPath)

        return footerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard viewModel.isMoreDataAvailable  else { return CGSize.zero }

        return .init(width: viewModel.cellWidth, height: 40.0)
    }
}

// MARK: - Subjects Delegate
extension InboxViewController: SubjectsDelegate {
    func didSelectCell(with subjectID: String?) {
        viewModel.filterData(with: subjectID) { [weak self] in
            DispatchQueue.main.async {
                self?.ibInboxCollectionView.reloadData()
            }
        }
    }
}
