//
//  CreateItemViewController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 12/11/21.
//  Copyright © 2021 Izertis All rights reserved.
//

import UIKit

class SearchUserViewController: UIViewController {
    // MARK: - Properties
    private let userNameCellIdentifier = "UserNameCell"
    private var type: SearchType
    private var viewModel: CreateItemViewModel
    private var users: [User] = []
    private let minLengthToSearch: Int = 3

    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Init
    init(type: SearchType) {
        self.type = type
        viewModel = CreateItemViewModel(type: type)
        super.init(nibName: "SearchUserView", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        configureView()
        configureTableView()
        bind()
    }

    // MARK: - Style and configuration
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: userNameCellIdentifier, bundle: nil), forCellReuseIdentifier: userNameCellIdentifier)
    }

    private func configureView() {
        switch type {
        case .authorization:
            viewTitle.text = "Search_User_Title_Authorization".localized()
        case .validator:
            viewTitle.text = "Search_User_Title_Validator".localized()
        }
    }

    // MARK: - Binding
    private func bind() {
        viewModel.usersUpdated = { users in
            self.users = users
            self.tableView.reloadData()
        }

        viewModel.resultUpdated = {
            self.navigationController?.popViewController(animated: true)
        }

        viewModel.errorMsgUpdated = { msg in
            self.didReceiveError(errorString: msg)
        }
    }

    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
        self.navigationController?.popViewController(animated: true)
    }

    private func didReceiveError(errorString: String) {
        SVProgressHUD.dismiss {
            let alert = UIAlertController(title: "Alert_View_Error".localized(), message: errorString, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Alert_View_Ok_Option".localized(), style: UIAlertAction.Style.default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension SearchUserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch type {
        case .authorization:
        let createItemViewController = CreateItemViewController(type: type, user: users[indexPath.row], viewModel: viewModel)
        self.navigationController?.pushViewController(createItemViewController, animated: true)
        case .validator:
            let alert = UIAlertController(title: "Create_validator_Alert_Title".localized(), message: "Create_Validator_Alert_Message".localized().replacingOccurrences(of: "%@", with: users[indexPath.row].name), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Create_Validator_Alert_Accept".localized(), style: UIAlertAction.Style.default, handler: { _ in
                self.viewModel.createValidator(user: self.users[indexPath.row])
            }))
            alert.addAction(UIAlertAction(title: "Create_Validator_Alert_Cancel".localized(), style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension SearchUserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userNameCellIdentifier, for: indexPath) as! UserNameCell
        cell.configureCell(for: users[indexPath.row].name)
        return cell
    }
}

extension SearchUserViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= minLengthToSearch {
            viewModel.searchUser(string: searchText)
        } else {
            users = []
            tableView.reloadData()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        if text.count <= minLengthToSearch {
            viewModel.searchUser(string: text)
        }
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}
