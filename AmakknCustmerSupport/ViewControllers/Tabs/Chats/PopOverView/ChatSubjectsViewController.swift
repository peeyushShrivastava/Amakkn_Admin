//
//  ChatSubjectsViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 14/10/20.
//

import UIKit

// MARK: - Subjects Delegate
protocol SubjectsDelegate {
    func didSelectCell(with subjectID: String?)
}

class ChatSubjectsViewController: UIViewController {
    @IBOutlet weak var ibTableView: UITableView!
    
    var subjects: [ChatSubjectModel]?
    var selectedSubject: String?
    var delegate: SubjectsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        ibTableView.reloadData()
    }

    private func registerCell() {
        ibTableView.register(UINib(nibName: "SubjectCell", bundle: nil), forCellReuseIdentifier: "subjectCellID")
    }
}

// MARK: - UITableView Delegate / DataSource
extension ChatSubjectsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "subjectCellID", for: indexPath) as? SubjectCell else { return UITableViewCell() }

        let model = subjects?[indexPath.row]
        cell.subject = model?.subject
        cell.ibSubjectLabel.textColor = model?.subjectID == selectedSubject ? .systemGreen : AppColors.selectedTitleTextColor

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCell(with: subjects?[indexPath.row].subjectID)
        dismiss(animated: true, completion: nil)
    }
}
