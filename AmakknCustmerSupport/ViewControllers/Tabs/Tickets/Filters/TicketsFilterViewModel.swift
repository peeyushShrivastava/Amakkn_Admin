//
//  TicketsFilterViewModel.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 05/10/21.
//

import Foundation
import UIKit

// MARK: - Filter Enum
enum TicketsFilterType: Int {
    case status = 0
    case subject
}

// TicketsFlter Delegate
protocol TicketsFilterDelegate: AnyObject {
    func updateList(with status: StatusModel?, and subject: SubjectModel?)
}

class TicketsFilterViewModel {
    private var statusList: [StatusModel]?
    private var subjects: [SubjectModel]?

    var filterType = TicketsFilterType.status
    var selectedStatus: StatusModel?
    var selectedSubject: SubjectModel?

    var delegate: TicketsListDelegate?

    var cellCount: Int {
        return ((filterType == .status) ?
                    (statusList?.count ?? 0) :
                    (subjects?.count ?? 0))
    }

    var cellHeight: CGFloat {
        return 50.0
    }

    var disableReset: Bool {
        return (selectedStatus == nil || selectedSubject == nil || (selectedStatus?.statusID == "-1" && selectedSubject?.subjectID == ""))
    }

    func getTitle(at index: Int) -> String? {
        let title = filterType == .status ? statusList?[index].statusName : subjects?[index].subject

        return title
    }

    func updateSelected(title: String?, callback: @escaping () -> Void) {
        if filterType == .status {
            guard let index = statusList?.firstIndex(where: { $0.statusName == title }) else { return }

            selectedStatus = statusList?[index]
            callback()
        } else {
            guard let index = subjects?.firstIndex(where: { $0.subject == title }) else { return }

            selectedSubject = subjects?[index]
            callback()
        }
    }

    func canShowTick(for title: String?) -> Bool {
        if filterType == .status {
            guard let index = statusList?.firstIndex(where: { $0.statusName == title }) else { return false }

            return (statusList?[index].statusID == selectedStatus?.statusID)
        } else {
            guard let index = subjects?.firstIndex(where: { $0.subject == title }) else { return false }

            return (subjects?[index].subjectID == selectedSubject?.subjectID)
        }
    }

    func updateData(_ status: StatusModel?, and subject: SubjectModel?) {
        selectedStatus = status
        selectedSubject = subject
    }

    func resetData() {
        selectedStatus = statusList?.first
        selectedSubject = subjects?.first
    }
}

// MARK: - API Calls
extension TicketsFilterViewModel {
    func getStatusList() {
        AppLoader.show()

        TicketsNetworkManager.shared.getStatusList { [weak self] statusModel in
            self?.statusList = statusModel?.statusList

            self?.getSubjects()
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }
    }

    private func getSubjects() {
        TicketsNetworkManager.shared.getSubjects { [weak self] model in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.subjects = model?.subjects
                self?.subjects?.insert(SubjectModel(subjectID: "", subject: "All"), at: 0)

                if self?.selectedSubject == nil {
                    self?.selectedStatus = self?.statusList?.first
                    self?.selectedSubject = self?.subjects?.first
                }

                self?.delegate?.success()
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                AppLoader.dismiss()

                self?.delegate?.failed(with: errorStr)
            }
        }
    }
}
