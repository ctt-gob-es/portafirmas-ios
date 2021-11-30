//
//  DefaultNavigationViewController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 10/11/21.
//  Copyright © 2021 Izertis All rights reserved.
//

import Foundation

class DefaultNavigationViewController: UINavigationController {

    @objc weak var onboardingDelegate: OnboardingDelegate?

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        applyStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        applyStyle()
    }

    func applyStyle() {
        self.navigationBar.isHidden = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        onboardingDelegate?.viewDismissed()
    }
}

@objc protocol OnboardingDelegate {
    func viewDismissed()
}
