//
//  ConfigurationViewController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 21/10/21.
//  Copyright © 2021 Izertis All rights reserved.
//

import Foundation
import UIKit

enum SearchType {
    case authorization
    case validator
}

class ConfigurationViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: ConfigurationViewModel?
    private let authorizationCellIdentifier = "AuthorizationCell"
    private let validatorCellIdentifier = "UserNameCell"
    private let authorizationCellHeight: CGFloat = 60.0
    private let validatorCellHeight: CGFloat = 40.0
    private var showAuthorizations: Bool = true
    private var authorizations: [Authorization] = []
    private var validators: [String] = []

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoading()
        bind()
        configureSegmentedControl()
        configuraTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        switch showAuthorizations {
        case true:
            viewModel?.getAuthorizations()
        case false:
            viewModel?.getValidators()
        }
    }

    // MARK: - Style and configurations
    private func configureSegmentedControl() {
        let color = UIColor.init(red: 105.0/255.0, green: 25.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        segmentedControl.addTarget(self, action: #selector(segmentedControlTapped(_:)), for: .valueChanged)
    }

    private func configuraTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: authorizationCellIdentifier, bundle: nil), forCellReuseIdentifier: authorizationCellIdentifier)
        tableView.register(UINib(nibName: validatorCellIdentifier, bundle: nil), forCellReuseIdentifier: validatorCellIdentifier)
    }

    // MARK: - Binding
    func bind() {
        viewModel?.authorizationsUpdated = { authorizations in
            self.authorizations = authorizations
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.removeLoading()
        }

        viewModel?.validatorsUpdated = { validators in
            self.validators = validators
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.removeLoading()
        }
    }

    // MARK: - Actions
    @objc func injectViewModel(viewModel: ConfigurationViewModel) {
        self.viewModel = viewModel
    }

    @IBAction func segmentedControlTapped(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            showAuthorizations = true
            viewModel?.getAuthorizations()
        case 1:
            showAuthorizations = false
            viewModel?.getValidators()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        default:
            return
        }
    }

    @IBAction func optionsButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addNewItemButtonTapped(_ sender: Any) {
        switch showAuthorizations {
        case true:
            navigate(type: .authorization)
        case false:
            navigate(type: .validator)
        }
    }

    private func navigate(type: SearchType) {
        let searchUserViewController = SearchUserViewController(type: type)
        searchUserViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(searchUserViewController, animated: true)
    }

    private func showLoading() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }

    private func removeLoading() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
}

extension ConfigurationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch showAuthorizations {
        case true:
            return authorizationCellHeight
        case false:
            return validatorCellHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showAuthorizations {
            let authorizationDetailViewController = AuthorizationDetailViewController(authorization: authorizations[indexPath.row])
            authorizationDetailViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(authorizationDetailViewController, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension ConfigurationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch showAuthorizations {
        case true:
            return authorizations.count
        case false:
            return validators.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch showAuthorizations {
        case true:
            let cell = tableView.dequeueReusableCell(withIdentifier: authorizationCellIdentifier, for: indexPath) as! AuthorizationCell
            cell.configureCell(for: authorizations[indexPath.row])
            return cell
        case false:
            let cell = tableView.dequeueReusableCell(withIdentifier: validatorCellIdentifier, for: indexPath) as! UserNameCell
            cell.configureCell(for: validators[indexPath.row])
            return cell
        }
    }
}
