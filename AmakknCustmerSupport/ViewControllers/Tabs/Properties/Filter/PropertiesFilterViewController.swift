//
//  PropertiesFilterViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 27/10/20.
//

import UIKit

class PropertiesFilterViewController: UIViewController {
    @IBOutlet weak var ibPropertyFilterTableView: UITableView!
    @IBOutlet weak var ibTableViewWidth: NSLayoutConstraint!
    @IBOutlet weak var ibResetButton: UIBarButtonItem!

    var headerView: UserFilterHeaderView?

    let viewModel = PropertiesFilterViewModel()
    var delegate: UserFilterDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        ibResetButton.isEnabled = false

        registerCell()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true
    }

    private func registerCell() {
        ibPropertyFilterTableView.register(UINib(nibName: "UserFilterCell", bundle: nil), forCellReuseIdentifier: "userFilterCellID")
        ibPropertyFilterTableView.register(UINib(nibName: "UserFilterDataCell", bundle: nil), forCellReuseIdentifier: "userFilterDataCellID")

        ibTableViewWidth.constant = viewModel.cellWidth
    }
    @IBAction func applyButtonTapped(_ sender: UIButton) {
    }
}

// MARK: - Button Actions
extension PropertiesFilterViewController {
    @IBAction func applyButtonTapped123(_ sender: UIButton) {
        delegate?.didUpdateFilter(with: viewModel.getFilteredDataSource())

        navigationController?.popViewController(animated: true)
    }

    @IBAction func resetButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.resetFilter()

        ibResetButton.isEnabled = false
        ibPropertyFilterTableView.reloadData()
    }
}

// MARK: - UITableView Delegate / DataSource
extension PropertiesFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = PropertyFilterSection(rawValue: indexPath.section) else { return UITableViewCell() }

        switch sectionType {
        case .filters:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userFilterDataCellID", for: indexPath) as? UserFilterDataCell else { return UITableViewCell() }

            let model = viewModel.getData(at: indexPath.section)
            cell.update(model?.filterData?[indexPath.row], with: indexPath.row)
            cell.updateValue(viewModel.getSelectedValue(at: indexPath))
            cell.delegate = self

            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userFilterCellID", for: indexPath) as? UserFilterCell else { return UITableViewCell() }

            let model = viewModel.getData(at: indexPath.section)
            cell.update(model?.filterData?[indexPath.row])
            cell.ibTickIcon.isHidden = !viewModel.isValueSelected(at: indexPath)

            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /// Create Header View
        headerView = Bundle.main.loadNibNamed("UserFilterHeaderView", owner: self, options: nil)?.last as? UserFilterHeaderView

        headerView?.backgroundColor = AppColors.darkViewBGColor
        headerView?.update(viewModel.getData(at: section)?.filterTitle, at: section)
        headerView?.updateValue(viewModel.getData(at: section)?.selectedData?.keys.first)

        headerView?.delegate = self

        return headerView
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.headerHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.updateData(at: indexPath)

        expandCell(at: indexPath.section)
        ibResetButton.isEnabled = true

        ibPropertyFilterTableView.reloadData()
    }
}

// MARK: - UserFilterHeader Delegate
extension PropertiesFilterViewController: UserFilterHeaderDelegate {
    func expandCell(at section: Int) {
        viewModel.updateExpand(at: section)

        if let data = viewModel.getData(at: section), let filterData = data.filterData {
            var indexPaths = [IndexPath]()

            for row in filterData.indices {
                indexPaths.append(IndexPath(row: row, section: section))
            }

            data.isExpanded ? ibPropertyFilterTableView.insertRows(at: indexPaths, with: .fade) :  ibPropertyFilterTableView.deleteRows(at: indexPaths, with: .fade)
        }
    }
}

// MARK: - UserFilterData Delegate
extension PropertiesFilterViewController: UserFilterDataDelegate {
    func textFieldDidChange(_ text: String?, for filterData: String?) {
        viewModel.updateFilterData(text, for: filterData)
    }
}
