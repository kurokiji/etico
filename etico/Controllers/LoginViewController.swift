//
//  LoginViewController.swift
//  etico
//
//  Created by Daniel Torres on 22/12/21.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Variables
    var loggedUser: User?
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingCard: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.color = Constants.customYellow
        loadingView.isHidden = true
        loadingCard.layer.cornerRadius = 20
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.5
        card.layer.shadowOffset = .init(width: 6, height: 6)
        card.layer.shadowRadius = 20
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    // MARK: - Buttons functions
    @IBAction func login(_ sender: Any) {
        if emailTextField.hasText && passwordTextField.hasText {
            self.disableLogin(isLoading: true)
            // TODO: Sustituir los campos
            NetworkingProvider.shared.login(email: emailTextField.text!,
                                            password: passwordTextField.text!)
            { user in
                self.loggedUser = user
                self.goToNextScreen(job: user.job)
                
            } failure: { error in
                self.disableLogin(isLoading: false)
                self.present(Constants.createAlert(title: "Error",
                                                   message: error,
                                                   image: Constants.errorImage,
                                                   color: Constants.customPink),
                             animated: true)
            }
        } else {
            self.present(Constants.createAlert(title: "Campos obligatorios",
                                          message: "Por favor, rellena todos los campos del formulario",
                                          image: Constants.alertImage,
                                          color: Constants.customYellow),
                         animated: true)
        }
    }
        
    @IBAction func passwordRecover(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let myAlert = storyBoard.instantiateViewController(withIdentifier: "passRecover") as? PasswordRecoverViewController {
            myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            myAlert.callBack = { (email: String) in
                NetworkingProvider.shared.passwordRecover(email: email) {
                    self.present(Constants.createAlert(title: "Success",
                                                       message: "Email enviado correctamente",
                                                       image: Constants.passwordImage,
                                                       color: Constants.customBlue),
                                 animated: true)
                } failure: { error in
                    self.present(Constants.createAlert(title: "Error",
                                                       message: error,
                                                       image: Constants.errorImage,
                                                       color: Constants.customPink),
                                 animated: true)

                }
            }
            self.present(myAlert, animated: true)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEmployeesList" {
            let controller = segue.destination as! EmployeesListViewController
            if let loggedUser = loggedUser {
                controller.loggedUser = loggedUser
            }
        }
        if segue.identifier == "showProfile" {
            let controller = segue.destination as! ProfileViewController
            if let loggedUser = loggedUser {
                controller.loggedUser = loggedUser
            }
        }
    }
    
    func goToNextScreen(job: String){
        if job == Constants.humanresources || job == Constants.executive {
            performSegue(withIdentifier: "showEmployeesList", sender: nil)
        } else {
            performSegue(withIdentifier: "showProfile", sender: nil)
        }
    }
    
    // MARK: - Supporting functions
    func disableLogin(isLoading: Bool){
        if isLoading {
            loginButton.isEnabled = false
            loadingView.isHidden = false
        } else {
            loginButton.isEnabled = true
            loadingView.isHidden = true
        }
    }
    
}
