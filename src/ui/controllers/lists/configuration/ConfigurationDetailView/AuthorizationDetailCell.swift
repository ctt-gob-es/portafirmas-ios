//
//  AuthorizationDetailCell.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 4/11/21.
//  Copyright © 2021 Izertis All rights reserved.
//

import UIKit

class AuthorizationDetailCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    func configureCell(index: Int, authorization: Authorization) {
        switch index {
        case 0:
            titleLabel.text = "Authorization_Detail_Name".localized()
            contentLabel.text = authorization.nameSend
        case 1:
            titleLabel.text = "Authorization_Detail_State".localized()
            switch authorization.state {
            case .pending:
                iconImageView.image = UIImage(named: "ic_waiting")
                contentLabel.text = "Authorization_Detail_State_Pending".localized()
            case .accepted:
                iconImageView.image = UIImage(named: "ic_check")
                contentLabel.text = "Authorization_Detail_State_Accepted".localized()
            case .revoked:
                iconImageView.image = UIImage(named: "ic_error")
                contentLabel.text = "Authorization_Detail_State_Revoked".localized()
            default:
                return
            }
        case 2:
            titleLabel.text = "Authorization_Detail_Sended_Received".localized()
            contentLabel.text = authorization.sended ? "Authorization_Detail_Sended".localized() : "Authorization_Detail_Received".localized()
            iconImageView.image = authorization.sended ? UIImage(named: "ic_authorized_out") : UIImage(named: "ic_authorized_in")
        case 3:
            titleLabel.text = "Authorization_Detail_Type".localized()
            contentLabel.text = authorization.type?.rawValue.capitalized
        case 4:
            titleLabel.text = "Authorization_Detail_Initial_Date".localized()
            contentLabel.text = authorization.initialDate
        case 5:
            titleLabel.text = "Authorization_Detail_End_Date".localized()
            contentLabel.text = authorization.endDate
        case 6:
            titleLabel.text = "Authorization_Detail_Observations".localized()
            contentLabel.text = authorization.observations
        default:
            return
        }
    }
}
