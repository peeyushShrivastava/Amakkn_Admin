//
//  PopoverViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 13/01/21.
//

import UIKit

// MARK: - Popover Delegate
protocol AppPopoverDelegate {
    func didSelectCell(with title: String?)
}

class PopoverViewController: UIViewController {
    @IBOutlet weak var ibTableView: UITableView!
    
    var titleList: [String]?
    var selectedTitle: String?
    var delegate: AppPopoverDelegate?

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
extension PopoverViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "subjectCellID", for: indexPath) as? SubjectCell else { return UITableViewCell() }

        let title = titleList?[indexPath.row]
        cell.subject = title
        cell.ibSubjectLabel.textColor = title == selectedTitle ? .systemGreen : AppColors.selectedTitleTextColor

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCell(with: titleList?[indexPath.row])
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
}

// MARK: - Init Self
extension PopoverViewController: InitiableViewController {
    static var storyboardType: AppStoryboard {
        return .ticket
    }
}
