//
//  AuthorizationDetailViewController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 4/11/21.
//  Copyright © 2021 Izertis All rights reserved.
//

import UIKit

class AuthorizationDetailViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: AuthorizationDetailViewModel?
    private var authorization: Authorization
    private let authorizationDetailViewIdentifier = "AuthorizationDetailView"
    private let authorizationDetailCellIdentifier = "AuthorizationDetailCell"
    private let authorizationDetailButtonCellIdentifier = "AuthorizationDetailButtonCell"
    private let numberOfSections: Int = 9
    private let observationsRow: Int = 6
    private let cellHeight: CGFloat = 60.0

    @IBOutlet weak var detailTableView: UITableView!

    // MARK: - Init
    init(authorization: Authorization) {
        self.viewModel = AuthorizationDetailViewModel()
        self.authorization = authorization
        super.init(nibName: authorizationDetailViewIdentifier, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        detailTableView.dataSource = self
        detailTableView.delegate = self
        detailTableView.rowHeight = UITableView.automaticDimension
        detailTableView.register(UINib(nibName: authorizationDetailCellIdentifier, bundle: nil), forCellReuseIdentifier: authorizationDetailCellIdentifier)
        detailTableView.register(UINib(nibName: authorizationDetailButtonCellIdentifier, bundle: nil), forCellReuseIdentifier: authorizationDetailButtonCellIdentifier)
        detailTableView.reloadData()
    }

    // MARK: - Binding
    func bind() {
        viewModel?.resultUpdated = {
            self.showLoading()
            self.navigationController?.popViewController(animated: true)
        }

        viewModel?.errorMsgUpdated = { msg in
            self.didReceiveError(errorString: msg)
        }
    }

    // MARK: - Actions
    @IBAction func configurationButtonTapped(_ sender: Any) {
        showLoading()
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func acceptButtonTapped(sender: UIButton) {
        viewModel?.acceptAuthorization(id: authorization.id)
    }

    @objc private func rejectButtonTapped(sender: UIButton) {
        viewModel?.rejectAuthorization(id: authorization.id)
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

    private func showLoading() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }
}

extension AuthorizationDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == observationsRow {
            return UITableView.automaticDimension
        } else {
            return cellHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AuthorizationDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfSections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 7:

            let cell = tableView.dequeueReusableCell(withIdentifier: authorizationDetailButtonCellIdentifier, for: indexPath) as! AuthorizationDetailButtonCell
            cell.configureCell(for: "Authorization_Detail_Accept".localized())
            cell.button.addTarget(self, action: #selector(acceptButtonTapped(sender:)), for: .touchUpInside)
            if authorization.state != "pending" || authorization.sended {
                cell.button.isHidden = true
            }
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: authorizationDetailButtonCellIdentifier, for: indexPath) as! AuthorizationDetailButtonCell
            if authorization.state == "accepted" {
                cell.configureCell(for: "Authorization_Detail_Cancel".localized())
            } else {
                cell.configureCell(for: "Authorization_Detail_Revoke".localized())
            }
            cell.button.addTarget(self, action: #selector(rejectButtonTapped(sender:)), for: .touchUpInside)
            if authorization.state == "revoked" {
                cell.button.isHidden = true
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: authorizationDetailCellIdentifier, for: indexPath) as! AuthorizationDetailCell
            cell.configureCell(index: indexPath.row, authorization: authorization)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        }
    }
}
