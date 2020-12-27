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

// MARK: - Navigation
extension StatsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "statsDetailsSegueID",
            let destinationVC = segue.destination as? StatsDetailsViewController {

            destinationVC.startDate = ibStartTextField.text
            destinationVC.endDate = ibStopTextField.text
        }
    }
}

// MARK: - Button Actions
extension StatsViewController {
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        ibStartTextField.resignFirstResponder()
        ibStopTextField.resignFirstResponder()

        performSegue(withIdentifier: "statsDetailsSegueID", sender: nil)
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
