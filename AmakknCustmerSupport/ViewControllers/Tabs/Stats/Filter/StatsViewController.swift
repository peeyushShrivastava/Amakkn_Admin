//
//  StatsViewController.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 21/12/20.
//

import UIKit

class StatsViewController: UIViewController {
    @IBOutlet weak var ibStartTextField: UITextField!
    @IBOutlet weak var ibStopTextField: UITextField!

    @IBOutlet var ibDatePickerHolderView: UIView!
    @IBOutlet weak var ibDatePicker: UIDatePicker!
    @IBOutlet var ibAccessoryView: UIView!

    var updateDates: ((_ startDate: String, _ endDate: String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        updateTextFields()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true
    }

    private func updateTextFields() {
        ibStartTextField.inputAccessoryView = ibAccessoryView
        ibStartTextField.inputView = ibDatePickerHolderView
        ibStartTextField.text = getCurrentDate()

        ibStopTextField.inputAccessoryView = ibAccessoryView
        ibStopTextField.inputView = ibDatePickerHolderView
        ibStopTextField.text = getCurrentDate()
    }

    private func getCurrentDate() -> String? {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"

        return dateFormatter.string(from: Date())
    }
}

// MARK: - Button Actions
extension StatsViewController {
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard let startDate = ibStartTextField.text, let endDate = ibStopTextField.text else { return }

        ibStartTextField.resignFirstResponder()
        ibStopTextField.resignFirstResponder()

        if let updateDates = updateDates {
            updateDates(startDate, endDate)
        }

        navigationController?.popViewController(animated: true)
    }

    @IBAction func accessoryDoneTapped(_ sender: UIButton) {
        ibStartTextField.resignFirstResponder()
        ibStopTextField.resignFirstResponder()
    }
}

// MARK: - DatePicker Action
extension StatsViewController {
    @IBAction func datePckerValueChanged(_ sender: UIDatePicker) {
        updateDate(for: sender)
    }

    private func updateDate(for picker: UIDatePicker) {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"

        let dateStr = dateFormatter.string(from: picker.date)
        if ibDatePicker.tag == 1 {
            ibStartTextField.text = dateStr
        } else {
            ibStopTextField.text = dateStr
        }
    }
}

// MARK: - UITextField Delegate
extension StatsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        ibDatePicker.tag = (textField == ibStartTextField) ? 1 : 2

        return true
    }
}
