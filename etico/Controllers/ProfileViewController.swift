//
//  EmployeeViewController.swift
//  etico
//
//  Created by Daniel Torres on 22/12/21.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    
    // MARK: - Variables
    var loggedUser: User?
    
    // MARK: - Outlets
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var biographyLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Dark mode configuration
        switch traitCollection.userInterfaceStyle {
               case .light, .unspecified:
            print("light")
               case .dark:
            view.backgroundColor = UIColor.darkGray
            card.backgroundColor = Constants.customGrey
        }
        
        // MARK: - View configuration
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.5
        card.layer.shadowOffset = .init(width: 6, height: 6)
        card.layer.shadowRadius = 20
        
        if let loggedUser = loggedUser {
            nameLabel.text = loggedUser.name
            switch loggedUser.job {
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
            let salaryNS = NSNumber(value: loggedUser.salary)
            let salaryText = formatter.string(from: salaryNS)
            if let salaryText = salaryText {
                salaryLabel.text = "\(salaryText)€"
            } else {
                salaryLabel.text = "\(loggedUser.salary)€"
            }
            biographyLabel.text = loggedUser.biography
            
            profileImage.kf.setImage(with: URL(string: loggedUser.profileImgUrl),
                                     placeholder: Constants.profileImage,
                                     options: [.transition(.fade(0.25))])
        }
        
    }
    // MARK: - Buttons functions
    @IBAction func showQr(_ sender: Any) {
        performSegue(withIdentifier: "showQR", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let loggedUser = loggedUser {
            if segue.identifier == "showQR" {
                let controller = segue.destination as? QRViewController
                controller?.email = loggedUser.email
            }
        }
    }
}
