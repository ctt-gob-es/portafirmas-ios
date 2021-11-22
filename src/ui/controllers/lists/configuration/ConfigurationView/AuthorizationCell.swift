//
//  AuthorizationCell.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 22/10/21.
//  Copyright © 2021 Izertis All rights reserved.
//

import Foundation
import UIKit

class AuthorizationCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var state: UIImageView!
    @IBOutlet weak var direction: UIImageView!

    func configureCell(for authorization: Authorization) {
        name.text = authorization.name
        date.text = authorization.endDate.toDate()?.toString() ?? "-"
        switch authorization.state {
        case "pending":
            state.image = UIImage(named: "ic_waiting")
        case "accepted":
            state.image = UIImage(named: "ic_check")
        case "revoked":
            state.image = UIImage(named: "ic_error")
        default:
            return
        }
        direction.image = authorization.sended ? UIImage(named: "ic_authorized_out") : UIImage(named: "ic_authorized_in")
    }
}
