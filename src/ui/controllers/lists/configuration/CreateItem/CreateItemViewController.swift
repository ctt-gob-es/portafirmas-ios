//
//  CreateItemViewController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 12/11/21.
//  Copyright © 2021 Izertis. All rights reserved.
//

import UIKit

class CreateItemViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: CreateItemViewModel
    private var type: SearchType
    private var user: User
    private var datePicker = UIDatePicker()
    private var timePicker = UIDatePicker()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var initDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    @IBOutlet weak var initTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var observationsTextField: UITextField!

    // MARK: - Init
    init(type: SearchType, user: User, viewModel: CreateItemViewModel) {
        self.type = type
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: "CreateItemView", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureViewWithInitData()
        showDatePicker()
        initDateField.delegate = self
        endDateField.delegate = self
        initTimeField.delegate = self
        endTimeField.delegate = self
    }

    // MARK: - Configurations and style
    private func configureViewWithInitData() {
        switch type {
        case .authorization:
            titleLabel.text = "Search_User_Title_Authorization".localized()
        case .validator:
            titleLabel.text = "Search_User_Title_Validator".localized()
        }
        userNameLabel.text = user.name
    }

    private func showDatePicker() {
        datePicker.date = Date()
        datePicker.locale = .current
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(handleDateSelection), for: .valueChanged)
        dismissPickerView()
    }

    private func dismissPickerView() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let button = UIBarButtonItem(title: "Alert_View_Ok_Option".localized(), style: .plain, target: self, action: #selector(self.action))
        toolbar.setItems([button], animated: true)
        initDateField.inputAccessoryView = toolbar
        endDateField.inputAccessoryView = toolbar
        initTimeField.inputAccessoryView = toolbar
        endTimeField.inputAccessoryView = toolbar
    }

    // MARK: - Binding
    func bind() {
        viewModel.resultUpdated = {
            let viewControllers: [UIViewController] = self.navigationController?.viewControllers ?? []
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }

        viewModel.errorMsgUpdated = { msg in
            self.didReceiveError(errorString: msg)
        }
    }

    // MARK: - Actions
    @IBAction func acceptButtonTapped(_ sender: Any) {
        guard let type = getType() else {
            return
        }
        let authorization = Authorization(name: user.name, type: type, initialDate: getInitDate(), endDate: getEndDate(), observations: observationsTextField.text ?? "")
        viewModel.createAuthorization(user: user, authorization: authorization)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func textFieldEnterPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }

    @objc private func handleDateSelection() {
        if initDateField.isFirstResponder {
            initDateField.text = datePicker.date.utcDateToString()
        }
        if endDateField.isFirstResponder {
            endDateField.text = datePicker.date.utcDateToString()
        }
        if initTimeField.isFirstResponder {
            initTimeField.text = datePicker.date.utcDateToStringTime()
        }
        if endTimeField.isFirstResponder {
            endTimeField.text = datePicker.date.utcDateToStringTime()
        }
    }

    @objc func action() {
        handleDateSelection()
        view.endEditing(true)
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

    private func getType() -> AuthorizationType? {
        switch typeSegmentedControl.selectedSegmentIndex {
        case 0:
            return AuthorizationType.delegado
        case 1:
            return AuthorizationType.sustituto
        default:
            return nil
        }
    }

    private func getInitDate() -> String {
        if (initDateField.text != "" && initTimeField.text != "") {
        return "\(initDateField.text ?? "") \(initTimeField.text ?? "")"
        } else {
            return Date().utcDateToString(withFormat: DateFormatConstants.dateTimeFormat)
        }
    }

    private func getEndDate() -> String {
        if (endDateField.text != "" && endTimeField.text != "") {
        return "\(endDateField.text ?? "") \(endTimeField.text ?? "")"
        } else {
            return ""
        }
    }
}

extension CreateItemViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case initDateField:
            datePicker.datePickerMode = .date
            initDateField.inputView = datePicker
        case endDateField:
            datePicker.datePickerMode = .date
            endDateField.inputView = datePicker
        case initTimeField:
            datePicker.datePickerMode = .time
            initTimeField.inputView = datePicker
        case endTimeField:
            datePicker.datePickerMode = .time
            endTimeField.inputView = datePicker
        default:
            datePicker.datePickerMode = .time
        }
    }
}
