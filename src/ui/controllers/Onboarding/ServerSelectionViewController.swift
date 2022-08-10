//
//  ServerSelectionViewController.swift
//  PortaFirmasUniv
//
//  Created by Héctor Rogel on 24/11/21.
//  Copyright © 2021 Izertis. All rights reserved.
//

import UIKit

enum OnboardingScreen {
    case firstScreen
    case secondScreen
}

enum NavigationDestination {
    case mainScreen
    case nextScreen
}

class ServerSelectionViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reminderText: UITextView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var optionsTableView: UITableView!
    private let numberOfRowsFirstScreen: Int = 3
    private let numberOfRowsSecondScreen: Int = 2
    private let cellIdentifier = "OptionsCell"
    private let screenType: OnboardingScreen
    private var isPad: Bool

    init(isPad: Bool, screenType: OnboardingScreen = .firstScreen) {
        self.isPad = isPad
        self.screenType = screenType
        super.init(nibName: "ServerSelectionView", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureTableView()
    }

    // MARK: - Configuration and style
    private func configureView() {
        switch screenType {
        case .firstScreen:
            titleLabel.text = "Onboarding_Server_View_Title".localized()
            reminderText.text = "Onboarding_Server_View_Reminder".localized()
        case .secondScreen:
            titleLabel.text = "Onboarding_Certificate_View_Title".localized()
            let attributedString = NSMutableAttributedString(string: "Onboarding_Certificate_View_Reminder".localized())
            attributedString.addAttribute(.link, value: "https://clave.gob.es/clave_Home/registro.html", range: NSRange(location: 29, length: 46))
            attributedString.addAttributes([.font: UIFont(name: "Helvetica-Bold", size: 16.0) ?? UIFont()], range: NSRange(location: 0, length: attributedString.length))
            reminderText.attributedText = attributedString
        }
        skipButton.setTitle("Onboarding_View_Skip".localized(), for: .normal)
        reminderText.sizeToFit()
    }

    private func configureTableView() {
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        optionsTableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    // MARK: - Actions
    private func handleNavigation(destination: NavigationDestination) {
        switch destination {
        case .mainScreen:
            if isPad {
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                guard let mainVC = UIStoryboard(name: "MainStoryboard_iPhone", bundle: nil).instantiateInitialViewController() else {
                    return
                }
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: true, completion: nil)
            }
        case .nextScreen:
            let secondVC = ServerSelectionViewController(isPad: isPad, screenType: .secondScreen)
            self.navigationController?.pushViewController(secondVC, animated: true)
        }
    }
    @IBAction func skipButtonTapped(_ sender: Any) {
        handleNavigation(destination: .mainScreen)
    }
}

extension ServerSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch screenType {
        case .firstScreen:
            switch indexPath.row {
            case 0:
                let serversArray = UserDefaults.standard.array(forKey: kPFUserDefaultsKeyServersArray)
                UserDefaults.standard.set(serversArray?[0], forKey: kPFUserDefaultsKeyCurrentServer)
                handleNavigation(destination: .nextScreen)
            case 1:
                let serversArray = UserDefaults.standard.array(forKey: kPFUserDefaultsKeyServersArray)
                UserDefaults.standard.set(serversArray?[1], forKey: kPFUserDefaultsKeyCurrentServer)
                handleNavigation(destination: .nextScreen)
            default: handleNavigation(destination: .nextScreen)
            }
        case .secondScreen:
            switch indexPath.row {
            case 0:
                UserDefaults.standard.set(false, forKey: kPFUserDefaultsKeyRemoteCertificatesSelection)
                handleNavigation(destination: .mainScreen)
            case 1:
                UserDefaults.standard.set(nil, forKey: kPFUserDefaultsKeyCurrentCertificate)
                UserDefaults.standard.set(true, forKey: kPFUserDefaultsKeyRemoteCertificatesSelection)
                UserDefaults.standard.synchronize()
                handleNavigation(destination: .mainScreen)
            default: return
            }
        }
    }
}

extension ServerSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch screenType {
        case .firstScreen:
            return numberOfRowsFirstScreen
        case .secondScreen:
            return numberOfRowsSecondScreen
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OptionsCell
        cell.configureCell(for: indexPath.row, screenType: screenType)
        return cell
    }
}

extension ServerSelectionViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
