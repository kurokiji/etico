//
//  LoginViewController.swift
//  etico
//
//  Created by Daniel Torres on 22/12/21.
//

import UIKit
import IQKeyboardManagerSwift
import SwiftUI

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
        
        // MARK: - View configuration
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.tag = 0
        passwordTextField.tag = 1
        activityIndicator.color = UIColor(named: "CustomYellow") ?? Constants.customYellow
        loadingView.isHidden = true
        loadingCard.layer.cornerRadius = 20
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.5
        card.layer.shadowOffset = .init(width: 6, height: 6)
        card.layer.shadowRadius = 20
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        emailTextField.layer.borderWidth = 0.5
        emailTextField.layer.cornerRadius = 10
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.layer.borderWidth = 0.5
        passwordTextField.layer.cornerRadius = 10
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 20.0
        IQKeyboardManager.shared.toolbarTintColor = UIColor(named: "CustomBlue") ?? Constants.customBlue
    }
    
    // MARK: - Buttons functions
    @IBAction func loginButton(_ sender: Any) {
        if emailTextField.hasText && passwordTextField.hasText {
            self.disableLogin(isLoading: true)
            login(email: emailTextField.text!, password: passwordTextField.text!)
        } else {
            self.present(Constants.createAlert(title: "Required fields",
                                               message: "Please, fill in all the fields of the form",
                                               image: Constants.alertImage,
                                               color: UIColor(named: "CustomYellow") ?? Constants.customYellow,
                                               callBack: nil),
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
                                                       message: "Email sent successfully with your new password",
                                                       image: Constants.passwordImage,
                                                       color: UIColor(named: "CustomBlue") ?? Constants.customBlue,
                                                       callBack: nil),
                                 animated: true)
                } failure: { error in
                    self.present(Constants.createAlert(title: "Error",
                                                       message: error,
                                                       image: Constants.errorImage,
                                                       color: UIColor(named: "CustomPink") ?? Constants.customPink,
                                                       callBack: nil),
                                 animated: true)

                }
            }
            self.present(myAlert, animated: true)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEmployeesList" {
            let controller = segue.destination as? EmployeesListViewController
            if let loggedUser = loggedUser {
                controller?.loggedUser = loggedUser
            }
        }
        if segue.identifier == "showProfile" {
            let controller = segue.destination as? ProfileViewController
            if let loggedUser = loggedUser {
                controller?.loggedUser = loggedUser
            }
        }
    }
    
    func goToNextScreen(loggedUser: User){
        if let vc = presentingViewController as? EmployeesListViewController {
            vc.loggedUser = loggedUser
            vc.retrieveData()
            self.dismiss(animated: true, completion: nil)
        }
        if loggedUser.job == Constants.humanresources || loggedUser.job == Constants.executive {
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
    
    func login(email: String, password: String){
        NetworkingProvider.shared.login(email: email, password: password) { user in
            self.loggedUser = user
            let userDefaults = UserDefaults.standard
            do {
                try userDefaults.setObject(user, forKey: "loggedUser")
            } catch {
                print(error.localizedDescription)
            }
            self.disableLogin(isLoading: false)
            self.goToNextScreen(loggedUser: user)
            
        } failure: { error in
            self.disableLogin(isLoading: false)
            self.present(Constants.createAlert(title: "Error",
                                               message: error,
                                               image: Constants.errorImage,
                                               color: UIColor(named: "CustomPink") ?? Constants.customPink,
                                               callBack: nil),
                         animated: true)
        }
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
                    nextField.becomeFirstResponder()
                } else {
                    textField.resignFirstResponder()
                }
                return false
            }
    }


