//
//  OnboardingSplashViewController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 24/11/21.
//  Copyright © 2021 Izertis. All rights reserved.
//

import UIKit

class OnboardingSplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {

            let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
            let vc = ServerSelectionViewController(isPad: isPad)
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}

