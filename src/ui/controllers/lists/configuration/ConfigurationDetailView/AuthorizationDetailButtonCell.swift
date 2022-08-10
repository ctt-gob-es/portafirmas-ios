//
//  AuthorizationDetailButtonCell.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 10/11/21.
//  Copyright © 2021 Izertis All rights reserved.
//

import UIKit

class AuthorizationDetailButtonCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!

    func configureCell(for title: String) {
        button.setTitle(title, for: .normal)
    }
}
