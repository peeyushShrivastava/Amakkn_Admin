//
//  SelectSubjectViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 25/07/21.
//

import UIKit

class SelectSubjectViewController: UIViewController {
    @IBOutlet weak var ibTableView: UITableView!

    var subject: ((_ sunject: SubjectModel?) -> Void)?

    private let viewModel = SelectSubjectViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        registerCell()

        viewModel.getSubjects()
    }

    private func registerCell() {
        ibTableView.register(UINib(nibName: "SelectSubCell", bundle: nil), forCellReuseIdentifier: "selectSubCellID")
    }
}

// MARK: - ViewModel Delegate
extension SelectSubjectViewController: TicketsListDelegate {
    func success() {
        ibTableView.reloadData()
    }

    func failed(with errorStr: String?) { }
}

// MARK: - UITableView Delegate / DataSource
extension SelectSubjectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "selectSubCellID") as? SelectSubCell else { return UITableViewCell() }

        cell.ibTitleLabel.text = viewModel[indexPath.row]?.subject

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let subjectCallBack = subject else { return }

        subjectCallBack(viewModel[indexPath.row])

        navigationController?.popViewController(animated: true)
    }
}
