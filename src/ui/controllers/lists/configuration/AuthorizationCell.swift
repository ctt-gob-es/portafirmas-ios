//
//  AuthorizationCell.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 22/10/21.
//

import Foundation
import UIKit

class AuthorizationCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var state: UIImageView!
    @IBOutlet weak var direction: UIImageView!

    func configureCell(for item: String) {
        name.text = item
        date.text = "01/01/2000"
        state.image = UIImage(named: "ic_check")
        direction.image = UIImage(named: "ic_authorized_in")
    }
}
