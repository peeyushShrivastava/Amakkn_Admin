//
//  StatsDetailsViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/12/20.
//

import UIKit

class StatsDetailsViewController: UIViewController {
    @IBOutlet weak var ibDetailsTextView: UITextView!

    var startDate: String?
    var endDate: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        getStatsDetails()
    }
}

// MARK: - API Call
extension StatsDetailsViewController {
    private func getStatsDetails() {
        guard let startDate = startDate, let endDate = endDate else { return }

        AppNetworkManager.shared.getStatsDetails(from: startDate, to: endDate) { [weak self] responseDict in
            DispatchQueue.main.async {
                self?.ibDetailsTextView.text = self?.getString(from: responseDict)
            }
        } failureCallBack: { [weak self] errorStr in
            DispatchQueue.main.async {
                self?.showAlert(with: errorStr)
            }
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
        let alertController = UIAlertController(title: nil, message: errorStr, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "alert_OK".localized(), style: .cancel, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))

        present(alertController, animated: true, completion: nil)
    }
}
