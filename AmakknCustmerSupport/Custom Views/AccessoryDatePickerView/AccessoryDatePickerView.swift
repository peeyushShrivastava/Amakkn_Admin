//
//  AccessoryDatePickerView.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 22/02/21.
//

import UIKit

// MARK: - AccessoryDatePickerView Delegate
protocol DatePickerViewDelegate {
    func didValueChanged(_ date: Date)
}

class AccessoryDatePickerView: UIView {
    @IBOutlet weak var ibDatePickerView: UIDatePicker!

    var delegate: DatePickerViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        ibDatePickerView.datePickerMode = UIDatePicker.Mode.date
    }

    @IBAction func pickerValueChangedd(_ sender: UIDatePicker) {
        delegate?.didValueChanged(sender.date)
    }
}
