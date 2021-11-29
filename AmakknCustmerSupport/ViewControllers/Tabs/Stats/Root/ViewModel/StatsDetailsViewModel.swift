//
//  StatsDetailsViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/12/20.
//

import Foundation
import UIKit

// MARK: - Sections Enum
enum StatsDetailsType: String {
    case propertyNos = "Property Numbers"
    case publishedProperties = "Published Property Stats"
    case userStats = "User Stats"
    case otherStats = "Other Sstats"
}

// MARK: - Sections Enum
enum StatsFiltersType: Int {
    case last24Hrs = 0
    case last7Days
    case lastMonth
    case lastYear
    case yTD
    case mTD
    case custom

    func toString() -> String {
        switch self {
            case .last24Hrs: return "Last 24 Hours"
            case .last7Days: return "Last 7 Days"
            case .lastMonth: return "Last Month"
            case .lastYear: return "Last Year"
            case .yTD: return "YTD"
            case .mTD: return "MTD"
            case .custom: return "Custom Dates"
        }
    }
}

class StatsDetailsViewModel {
    private var statsDataType: StatsDetailsDataSource?
    private var statsDataSource: [StatsDetailsModel]?

    private var customStartDate = ""
    private var customEndDate = ""

    private var selectedFilter = StatsFiltersType.last24Hrs
    private let filters = [StatsFiltersType.last24Hrs.toString(),
                   StatsFiltersType.last7Days.toString(),
                   StatsFiltersType.lastMonth.toString(),
                   StatsFiltersType.lastYear.toString(),
                   StatsFiltersType.yTD.toString(),
                   StatsFiltersType.mTD.toString(),
                   StatsFiltersType.custom.toString()]

    var sectionCount: Int {
        return statsDataSource?.count ?? 0
    }

    var cellHeight: CGFloat {
        return 45.0
    }

    var headerHeight: CGFloat {
        return 60.0
    }

    func updateDataSource(with statsModel: StatsModel?) {
        guard let statsModel = statsModel else { return }

        statsDataType = StatsDetailsDataSource(statsModel)
        updateData()
    }

    private func updateData() {
        statsDataSource = [StatsDetailsModel(with: StatsDetailsType.propertyNos.rawValue, for: statsDataType?.propertyNos?.data),
                           StatsDetailsModel(with: StatsDetailsType.publishedProperties.rawValue, for: statsDataType?.publishedPropertyStats?.data),
                           StatsDetailsModel(with: StatsDetailsType.userStats.rawValue, for: statsDataType?.userStats?.data),
                           StatsDetailsModel(with: StatsDetailsType.otherStats.rawValue, for: statsDataType?.otherStats?.data)]
    }

    func getCellCount(for section: Int) -> Int {
        guard let details = statsDataSource?[section] else { return 0 }

        return details.isExpanded ? (details.detailsData?.count ?? 0) : 0
    }

    func getData(at section: Int) -> StatsDetailsModel? {
        return statsDataSource?[section]
    }

    func updateExpand(at section: Int) {
        let isExpanded = statsDataSource?[section].isExpanded
        statsDataSource?[section].isExpanded = !(isExpanded ?? true)
    }

    func isLastCell(at indexPath: IndexPath) -> Bool {
        guard let dataCount = statsDataSource?[indexPath.section].detailsData?.count else { return false }

        return (dataCount-1 == indexPath.row)
    }
}

// MARK: - Stats API Call
extension StatsDetailsViewModel {
    func getStatsDetails(successCallBack: @escaping () -> Void, failureCallBack: @escaping (_ errorStr: String?)  -> Void) {
        AppLoader.show()

        getDates { startDate, endDate in
            AppNetworkManager.shared.getStatsDetails(from: startDate, to: endDate) { [weak self] responseModel in
                DispatchQueue.main.async {
                    AppLoader.dismiss()
                    self?.updateDataSource(with: responseModel)

                    successCallBack()
                }
            } failureCallBack: { errorStr in
                DispatchQueue.main.async {
                    AppLoader.dismiss()
                    failureCallBack(errorStr)
                }
            }
        }
    }
}

// MARK: - Filters
extension StatsDetailsViewModel {
    func getSelectedFilter() -> String {
        return selectedFilter.toString()
    }

    func getFilterList() -> [String] {
        return filters
    }

    func update(selectedFilter: StatsFiltersType) {
        self.selectedFilter = selectedFilter
    }

    func updateFilter(with customStartDate: String, and customEndDate: String) {
        self.customStartDate = customStartDate
        self.customEndDate = customEndDate

        self.selectedFilter = .custom
    }

    private func getDates(callBack: @escaping (_ startDate: String, _ endDate: String) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"

        switch selectedFilter {
            case .last24Hrs:
                guard let startDate = Calendar.current.date(byAdding: Calendar.Component.hour, value: -24, to: Date()) else { return }

                callBack(dateFormatter.string(from: startDate),
                         dateFormatter.string(from: Date()))
            case .last7Days:
                guard let startDate = Calendar.current.date(byAdding: Calendar.Component.hour, value: -24*7, to: Date()) else { return }

                callBack(dateFormatter.string(from: startDate),
                         dateFormatter.string(from: Date()))
            case .lastMonth:
                let month = Calendar.current.dateComponents([.year, .month], from: Date())
                guard let currentMonth = Calendar.current.date(from: month),
                      let startDate = Calendar.current.date(byAdding: Calendar.Component.month, value: -1, to: currentMonth),
                      let monthFirstDate = Calendar.current.date(byAdding: Calendar.Component.month, value: 1, to: startDate),
                      let endDate = Calendar.current.date(byAdding: Calendar.Component.day, value: -1, to: monthFirstDate) else { return }

                callBack(dateFormatter.string(from: startDate),
                         dateFormatter.string(from: endDate))
            case .lastYear:
                let year = Calendar.current.dateComponents([.year], from: Date())
                guard let currentYear = Calendar.current.date(from: year),
                      let startDate = Calendar.current.date(byAdding: Calendar.Component.year, value: -1, to: currentYear),
                      let yearFirstDate = Calendar.current.date(byAdding: Calendar.Component.year, value: 1, to: startDate),
                      let endDate = Calendar.current.date(byAdding: Calendar.Component.day, value: -1, to: yearFirstDate) else { return }

                callBack(dateFormatter.string(from: startDate),
                         dateFormatter.string(from: endDate))
            case .yTD:
                let year = Calendar.current.dateComponents([.year], from: Date())
                guard let currentYear = Calendar.current.date(from: year),
                      let startDate = Calendar.current.date(byAdding: Calendar.Component.year, value: -1, to: currentYear) else { return }

                callBack(dateFormatter.string(from: startDate),
                         dateFormatter.string(from: Date()))
            case .mTD:
                let month = Calendar.current.dateComponents([.year, .month], from: Date())
                guard let currentMonth = Calendar.current.date(from: month),
                      let startDate = Calendar.current.date(byAdding: Calendar.Component.year, value: -1, to: currentMonth) else { return }

                callBack(dateFormatter.string(from: startDate),
                         dateFormatter.string(from: Date()))
            case .custom:
                callBack(customStartDate,
                         customEndDate)
        }
    }
}
