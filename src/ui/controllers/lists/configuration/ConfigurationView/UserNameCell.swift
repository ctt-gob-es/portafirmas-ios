//
//  UserNameCell.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 3/11/21.
//  Copyright © 2021 Solid Gear Projects S.L. All rights reserved.
//

import UIKit

class UserNameCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    func configureCell(for item: String) {
        titleLabel.text = item
    }
}
