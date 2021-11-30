//
//  OptionsCell.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 24/11/21.
//  Copyright © 2021 Izertis. All rights reserved.
//

import UIKit

class OptionsCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    func configureCell(for index: Int, screenType: OnboardingScreen) {
        switch screenType {
        case .firstScreen:
            switch index {
            case 0:
                titleLabel.text = "Onboarding_Server_View_DTIC_Title".localized()
                messageLabel.text = "Onboarding_Server_View_DTIC_Message".localized()
            case 1:
                titleLabel.text = "Onboarding_Server_View_Redsara_Title".localized()
                messageLabel.text = "Onboarding_Server_View_Redsara_Message".localized()
            case 2:
                titleLabel.text = "Onboarding_Server_View_Other_Title".localized()
                messageLabel.text = "Onboarding_Server_View_Other_Message".localized()
            default: return
            }
        case .secondScreen:
            switch index {
            case 0:
                titleLabel.text = "Onboarding_Certificate_View_Local_Title".localized()
                messageLabel.text = "Onboarding_Certificate_View_Local_Message".localized()
            case 1:
                titleLabel.text = "Onboarding_Certificate_View_Remote_Title".localized()
                messageLabel.text = "Onboarding_Certificate_View_Remote_Message".localized()
            default: return
            }
        }
    }
}
