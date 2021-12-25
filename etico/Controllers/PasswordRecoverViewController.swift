//
//  PasswordRecoverViewController.swift
//  etico
//
//  Created by Daniel Torres on 25/12/21.
//

import UIKit

class PasswordRecoverViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var card: UIView!
    var callBack: ((_ text: String)-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.5
        card.layer.shadowOffset = .init(width: 6, height: 6)
        card.layer.shadowRadius = 20
    }
    

    @IBAction func sendPassword(_ sender: Any) {
        callBack?(emailTextField.text ?? "")
        self.dismiss(animated: true, completion: nil)
    }
}
