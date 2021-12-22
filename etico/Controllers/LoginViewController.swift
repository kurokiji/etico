//
//  LoginViewController.swift
//  etico
//
//  Created by Daniel Torres on 22/12/21.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var card: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.5
        card.layer.shadowOffset = .init(width: 6, height: 6)
        card.layer.shadowRadius = 20
    }
    
    @IBAction func login(_ sender: Any) {
        if emailTextField.hasText && passwordTextField.hasText {
            NetworkingProvider.shared.login(email: emailTextField.text!, password: passwordTextField.text!) { apiToken in
                // Guardar usuario
                // Perform segue
            } failure: { error in
                // Mostrar aviso PERSONALIZADO con el mensaje de error
            }
        } else {
            // Mostrar aviso PERSONALIZADO con que los campos son obligatorios
            // https://www.youtube.com/watch?v=tKZZ1iNp0o4
        }
    }
    
    @IBAction func passwordRecover(_ sender: Any) {
        //pensar en como pedir el email
    }
}
