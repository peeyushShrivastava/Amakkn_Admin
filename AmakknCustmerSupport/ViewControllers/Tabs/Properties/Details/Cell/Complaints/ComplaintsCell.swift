//
//  ComplaintsCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/12/20.
//

import UIKit

// MARK: - Complaints Delegate
protocol ComplaintsDelegate {
    func resolveComplaint(id: String?)
    func didSelectCall(with phone: String?, _ countryCode: String?)
    func didSelectChat(at index: Int)
}

class ComplaintsCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTableView: UITableView!

    var complaints: [ComplaintModel]?
    var delegate: ComplaintsDelegate?

    var cellCount: Int {
        return (((complaints?.count ?? 0) > 0) ? ((complaints?.count ?? 1) + 1) : 0)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        registerCell()
    }

    private func registerCell() {
        ibTableView.register(UINib(nibName: "ComplaintCell", bundle: nil), forCellReuseIdentifier: "complaintCellID")
        ibTableView.register(UINib(nibName: "ResolveComplaintsCell", bundle: nil), forCellReuseIdentifier: "resolveCellID")
    }

    func configure(data details: [ComplaintModel]?) {
        complaints = details

        ibTableView.reloadData()
    }

    private func deleteRow(at index: Int) {
        complaints?.remove(at: index)

        ibTableView.reloadData()
    }
}

// MARK: - UITableView Delegate / DataSource
extension ComplaintsCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == complaints?.count ?? 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "resolveCellID") as? ResolveComplaintsCell else { return UITableViewCell() }

            cell.delegate = self

            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "complaintCellID") as? ComplaintCell else { return UITableViewCell() }

        cell.complaint = complaints?[indexPath.item]
        cell.index = indexPath.item
        cell.delegate = self

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item == complaints?.count ?? 0 {
            return 45.0
        }
        return 154.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.item != complaints?.count ?? 0 else { return false }

        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.item != complaints?.count ?? 0 else { return nil }

        let contextItem = UIContextualAction(style: .normal, title: "Resolve") { [weak self] (contextualAction, view, boolValue) in
            guard let complaint = self?.complaints?[indexPath.item] else { return }

            self?.delegate?.resolveComplaint(id: complaint.complaintID)
            self?.deleteRow(at: indexPath.row)
        }
        contextItem.backgroundColor = AppColors.darkSlateColor

        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

        return swipeActions
    }
}

// MARK: - UserCell Delegate
extension ComplaintsCell: UserCellDelegate {
    func didSelectCall(with phone: String?, _ countryCode: String?) {
        delegate?.didSelectCall(with: phone, countryCode)
    }

    func didSelectChat(at index: Int) {
        delegate?.didSelectChat(at: index)
    }
}

// MARK: - Resolve Delegate
extension ComplaintsCell: ResolveDelegate {
    func resolveAllComplaints() {
        delegate?.resolveComplaint(id: getComplaintIDs())
    }

    private func getComplaintIDs() -> String? {
        let complaintsIDs = complaints?.enumerated().compactMap({ [weak self] (index, complaint) -> String? in
            self?.deleteRow(at: index)

            return complaint.complaintID
        }).joined(separator: ",")

        return complaintsIDs
    }
}
