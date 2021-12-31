//
//  PasswordRecoverViewController.swift
//  etico
//
//  Created by Daniel Torres on 25/12/21.
//

import UIKit

class PasswordRecoverViewController: UIViewController {
    // MARK: - Variables
    var callBack: ((_ text: String)-> Void)?
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var card: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Dark mode configuration
        switch traitCollection.userInterfaceStyle {
               case .light, .unspecified:
            print("light")
               case .dark:
            card.backgroundColor = Constants.customGrey
        }
        
        // MARK: - View configuration
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.5
        card.layer.shadowOffset = .init(width: 6, height: 6)
        card.layer.shadowRadius = 20
    }
    
    // MARK: - Buttons functions
    @IBAction func sendPassword(_ sender: Any) {
        callBack?(emailTextField.text ?? "")
        self.dismiss(animated: true, completion: nil)
    }
}
