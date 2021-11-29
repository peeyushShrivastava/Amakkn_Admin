//
//  StatsDetailsViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/12/20.
//

import UIKit

class StatsDetailsViewController: BaseViewController {
    @IBOutlet weak var ibDetailsTableView: UITableView!
    @IBOutlet weak var ibMoreButton: UIBarButtonItem!
    @IBOutlet weak var ibEmptyView: EmptyBGView!
    
    var headerView: UserDetailsHeaderView?
    private let viewModel = StatsDetailsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        ibEmptyView.delegate = self
        registerCell()
        getStatsDetails()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = false

        ibEmptyView.updateUI()
        AppSession.manager.validSession ? ibEmptyView.startActivityIndicator(with: "Fetching Stats...") : ibEmptyView.updateErrorText()
    }

    private func registerCell() {
        ibDetailsTableView.register(UINib(nibName: "StatsDetailsDataCell", bundle: nil), forCellReuseIdentifier: "statsDetailsCellID")
    }
}

// MARK: - Navigation
extension StatsDetailsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "statsFilterSegueID",
            let destinationVC = segue.destination as? StatsViewController {

            destinationVC.updateDates = { [weak self] (customStartDate, customEndDate) in
                self?.viewModel.updateFilter(with: customStartDate, and: customEndDate)

                self?.getStatsDetails()
            }
        }
    }
}

// MARK: Button Actions
extension StatsDetailsViewController {
    @IBAction func moreButtonTapped(_ sender: UIBarButtonItem) {
        guard let popOverVC = PopoverViewController.instantiateSelf() else { return }

        popOverVC.view.frame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 400.0)
        popOverVC.modalPresentationStyle = .popover
        popOverVC.titleList = viewModel.getFilterList()
        popOverVC.selectedTitle = viewModel.getSelectedFilter()
        popOverVC.delegate = self

        let popOver = popOverVC.popoverPresentationController
        popOver?.barButtonItem = sender
        popOver?.sourceRect = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 400.0)
        popOver?.delegate = self

        present(popOverVC, animated: true, completion:nil)
    }
}

// MARK: - UIPopover Delegate
extension StatsDetailsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - API Call
extension StatsDetailsViewController {
    private func getStatsDetails() {
        viewModel.getStatsDetails { [weak self] in
            self?.ibDetailsTableView.isHidden = false
            self?.ibEmptyView.isHidden = true
            self?.ibEmptyView.updateErrorText()

            self?.ibDetailsTableView.reloadData()
        } failureCallBack: { [weak self] errorStr in
            self?.ibDetailsTableView.isHidden = true
            self?.ibEmptyView.isHidden = false
            self?.ibEmptyView.updateErrorText()

            self?.showAlert(with: errorStr)
        }
    }

    private func getString(from dict: [String: Any]?) -> String? {
        guard let dict = dict else { return nil}
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: dict,
                                                                    options: [.prettyPrinted]) else { return nil }

        return String(data: theJSONData, encoding: .ascii)
    }
}

// MARK: - Show Alert
extension StatsDetailsViewController {
    private func showAlert(with errorStr: String?) {
        let alertController = UIAlertController(title: errorStr, message: nil, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableView Delegate / DataSource
extension StatsDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellCount(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "statsDetailsCellID", for: indexPath) as? StatsDetailsDataCell else { return UITableViewCell() }

        let models = viewModel.getData(at: indexPath.section)
        let model = models?.detailsData?[indexPath.row]

        cell.model = model
        cell.updateUI(for: viewModel.isLastCell(at: indexPath))

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /// Create Header View
        headerView = Bundle.main.loadNibNamed("UserDetailsHeaderView", owner: self, options: nil)?.last as? UserDetailsHeaderView

        headerView?.backgroundColor = AppColors.lightViewBGColor

        let userModel = viewModel.getData(at: section)
        headerView?.update(userModel?.detailsTitle, at: section)

        let isExpanded = (userModel?.detailsTitle == UserDetailsType.changeUserType.rawValue) ? false : userModel?.isExpanded
        headerView?.updateUI(for: isExpanded ?? false)

        headerView?.delegate = self

        return headerView
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.headerHeight
    }
}

// MARK: - EmptyBGView Delegate
extension StatsDetailsViewController {
    override func didSelectRefresh() {
        getStatsDetails()
    }
}

// MARK: - UserDetailsHeader Delegate
extension StatsDetailsViewController: UserDetailsHeaderDelegate {
    func expandCell(at section: Int, with title: String?) {
        viewModel.updateExpand(at: section)

        if let data = viewModel.getData(at: section), let filterData = data.detailsData {
            var indexPaths = [IndexPath]()

            for row in filterData.indices {
                indexPaths.append(IndexPath(row: row, section: section))
            }

            data.isExpanded ? ibDetailsTableView.insertRows(at: indexPaths, with: .fade) :  ibDetailsTableView.deleteRows(at: indexPaths, with: .fade)

            ibDetailsTableView.reloadSections([section], with: .none)
        }
    }
}

// MARK: - Popover Delegate
extension StatsDetailsViewController: AppPopoverDelegate {
    func didSelectCell(with title: String?) {
        guard let title = title else { return }

        switch title {
            case StatsFiltersType.last24Hrs.toString(): viewModel.update(selectedFilter: .last24Hrs)
            case StatsFiltersType.last7Days.toString(): viewModel.update(selectedFilter: .last7Days)
            case StatsFiltersType.lastMonth.toString(): viewModel.update(selectedFilter: .lastMonth)
            case StatsFiltersType.lastYear.toString(): viewModel.update(selectedFilter: .lastYear)
            case StatsFiltersType.yTD.toString(): viewModel.update(selectedFilter: .yTD)
            case StatsFiltersType.mTD.toString(): viewModel.update(selectedFilter: .mTD)
            case StatsFiltersType.custom.toString(): performSegue(withIdentifier: "statsFilterSegueID", sender: nil); return
            default: break
        }

        getStatsDetails()
    }
}
