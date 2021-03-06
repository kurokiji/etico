//
//  EmployeeViewController.swift
//  etico
//
//  Created by Daniel Torres on 23/12/21.
//

import UIKit
import Kingfisher
import SwiftUI

class EmployeeViewController: UIViewController {
    // MARK: - Variables
    var employee: User?
    var loggedUser: User?
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var biographyLabel: UITextView!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: - View configuration
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.5
        card.layer.shadowOffset = .init(width: 6, height: 6)
        card.layer.shadowRadius = 20
        biographyLabel.isScrollEnabled = false
        setLabels()
        biographyLabel.sizeToFit()

        if let employee = employee, let loggedUser = loggedUser {
            if employee.id != loggedUser.id {
                logoutButton.isHidden = true
            }
        }
    }
    
    // MARK: - Supporting functions
    func setLabels() {
        if let employee = employee {
            nameLabel.text = employee.name
            switch employee.job {
            case Constants.employee:
                jobLabel.text = Constants.employeeText
            case Constants.humanresources:
                jobLabel.text = Constants.humanresourcesText
            case Constants.executive:
                jobLabel.text = Constants.executiveText
            default:
                jobLabel.text = Constants.employeeText
            }
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyDecimalSeparator = ","
            formatter.currencyGroupingSeparator = "."
            formatter.locale = Locale(identifier: "es_ES")
            let salaryNS = NSNumber(value: employee.salary)
            let salaryText = formatter.string(from: salaryNS)
            if let salaryText = salaryText {
                salaryLabel.text = salaryText
            } else {
                salaryLabel.text = "\(employee.salary)???"
            }
            biographyLabel.text = employee.biography
            profileImage.kf.setImage(with: URL(string: employee.profileImgUrl), placeholder: Constants.profileImage, options: [.transition(.fade(0.25))])
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let loggedUser = loggedUser, let employee = employee {
            if segue.identifier == "editEmployee" {
                let controller = segue.destination as? EditEmployeeViewController
                controller?.employee = employee
                controller?.loggedUser = loggedUser
            } else if segue.identifier == "showQR" {
                let controller = segue.destination as? QRViewController
                controller?.email = employee.email
            }
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        performSegue(withIdentifier: "editEmployee", sender: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        if let apiToken = loggedUser?.api_token {
            NetworkingProvider.shared.logout(apiToken: apiToken) {
                let userDefaults = UserDefaults.standard
                do {
                    try userDefaults.removeObject(forKey: "loggedUser")
                } catch {
                    print(error.localizedDescription)
                }
                if let first = self.presentingViewController,
                        let second = first.presentingViewController{
                          first.view.isHidden = true
                          second.dismiss(animated: true)
                     }
            } failure: { error in
                let errorAlert = Constants.createAlert(title: "Error",
                                                       message: error,
                                                       image: Constants.errorImage,
                                                       color: UIColor(named: "CustomPink") ?? Constants.customPink,
                                                       callBack: nil)
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
    }
}
