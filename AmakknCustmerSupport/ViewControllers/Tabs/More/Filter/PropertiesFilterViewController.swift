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

    let viewModel = PropertiesFilterViewModel()

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
}

// MARK: - Button Actions
extension PropertiesFilterViewController {
    @IBAction func applyButtonTapped(_ sender: UIButton) {
        guard let propertiesVC = PropertiesViewController.instantiateSelf() else { return }
 
        propertiesVC.viewModel.updateFilter(viewModel.getFilteredDataSource())

        navigationController?.pushViewController(propertiesVC, animated: true)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userFilterCellID", for: indexPath) as? UserFilterCell else { return UITableViewCell() }

        let model = viewModel.getData(at: indexPath.section)
        cell.update(model?.filterData?[indexPath.row])
        cell.ibTickIcon.isHidden = !viewModel.isValueSelected(at: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 2 {
            let headerView = Bundle.main.loadNibNamed("UserFilterHeaderView", owner: self, options: nil)?.last as? UserFilterHeaderView

            headerView?.backgroundColor = AppColors.darkViewBGColor
            headerView?.update(viewModel.getData(at: section)?.filterTitle, at: section)
            headerView?.updateValue(viewModel.getData(at: section)?.selectedData?.keys.first)

            headerView?.delegate = self

            return headerView
        }
        let headerView = Bundle.main.loadNibNamed("UserFilterDataHeaderView", owner: self, options: nil)?.last as? UserFilterDataHeaderView

        headerView?.backgroundColor = AppColors.darkViewBGColor
        headerView?.update(viewModel.getData(at: section)?.filterTitle, at: section)

        let data = viewModel.getData(at: section)
        headerView?.updateValue(for: data?.selectedData?.keys.first, data?.selectedValues?.values.first)

        headerView?.delegate = self
        headerView?.dataDelegate = self

        return headerView
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.getHeaderHeight(at: section)
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
    func textFieldDidChange(_ text: String?, for filterData: String?, at index: Int) {
        viewModel.updateFilterData(text, for: filterData, at: index)
    }
}
