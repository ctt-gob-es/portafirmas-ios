//
//  DefaultNavigationViewController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 10/11/21.
//

import Foundation

class DefaultNavigationViewController: UINavigationController {

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
}
