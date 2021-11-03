//
//  ConfigurationViewController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 21/10/21.
//

import Foundation
import UIKit

class ConfigurationViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: ConfigurationViewModel?
    private let authorizationCellIdentifier = "AuthorizationCell"
    private let tableViewCellHeight: CGFloat = 60.0

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSegmentedControl()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: authorizationCellIdentifier, bundle: nil), forCellReuseIdentifier: authorizationCellIdentifier)
        viewModel?.getAuthorizations()
    }

    // MARK: - Style and configurations
    private func configureSegmentedControl() {
        let color = UIColor.init(red: 105.0/255.0, green: 25.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
    }

    // MARK: - Actions
    @objc func injectViewModel(viewModel: ConfigurationViewModel) {
        self.viewModel = viewModel
    }

    @IBAction func optionsButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addNewAuthorizationButtonTapped(_ sender: Any) {
    }
}

extension ConfigurationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableViewCellHeight
    }
}

extension ConfigurationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: authorizationCellIdentifier, for: indexPath) as! AuthorizationCell
        cell.configureCell(for: "ejemplo de titulo de celda")
        return cell
    }
}
