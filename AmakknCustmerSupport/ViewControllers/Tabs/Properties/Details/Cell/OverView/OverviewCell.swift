//
//  OverviewCell.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 26/10/20.
//

import UIKit

class OverviewCell: UICollectionViewCell, ConfigurableCell {
    @IBOutlet weak var ibTitleLabel: UILabel!
    @IBOutlet weak var ibTableView: UITableView!

    var dataSource: [OverviewListModel]?

    override func awakeFromNib() {
        super.awakeFromNib()

        ibTitleLabel.text = "Property_Detail_OVerView".localized()

        registerCell()
    }

    private func registerCell() {
        ibTableView.register(UINib(nibName: "DetailsOverviewCell", bundle: nil), forCellReuseIdentifier: "overviewCellID")
        ibTableView.separatorStyle = .none
    }

    func configure(data details: DetailsOverViewModel?) {
        dataSource = details?.dataSource
    }
}

// MARK: - UITableView Delegate / DataSource
extension OverviewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "overviewCellID", for: indexPath) as? DetailsOverviewCell else { return UITableViewCell() }

        cell.dataSource = dataSource?[indexPath.item]

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
