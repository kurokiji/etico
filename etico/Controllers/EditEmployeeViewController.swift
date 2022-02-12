//
//  EditEmployeeViewController.swift
//  etico
//
//  Created by Daniel Torres on 23/12/21.
//

import UIKit
import Kingfisher
import IQKeyboardManagerSwift

class EditEmployeeViewController: UIViewController {
    
    // MARK: - Variables
    var employee: User?
    var loggedUser: User?
    var deletedEmployee: Int?
    var profileImageURL: String?
    
    // MARK: - Outlets
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var salaryTextfield: UITextField!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var biographyTextfield: UITextView!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var jobSelector: UISegmentedControl!
    @IBOutlet weak var uploadProgressBar: UIProgressView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - View configuration
        scrollView.bounces = false
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.5
        card.layer.shadowOffset = .init(width: 6, height: 6)
        card.layer.shadowRadius = 20
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 20.0
        IQKeyboardManager.shared.toolbarTintColor = UIColor(named: "CustomBlue") ?? Constants.customBlue
        biographyTextfield.layer.borderColor = UIColor.lightGray.cgColor
        biographyTextfield.layer.borderWidth = 0.2
        biographyTextfield.layer.cornerRadius = 10
        salaryTextfield.layer.borderWidth = 0.5
        salaryTextfield.layer.cornerRadius = 10
        emailTextfield.layer.borderColor = UIColor.lightGray.cgColor
        emailTextfield.backgroundColor = UIColor(named: "CustomBackgroundColor")!
        emailTextfield.layer.borderWidth = 0.5
        emailTextfield.layer.cornerRadius = 10
        nameTextfield.layer.borderColor = UIColor.lightGray.cgColor
        nameTextfield.backgroundColor = UIColor(named: "CustomBackgroundColor")!
        nameTextfield.layer.borderWidth = 0.5
        nameTextfield.layer.cornerRadius = 10
        salaryTextfield.layer.borderColor = UIColor.lightGray.cgColor
        salaryTextfield.backgroundColor = UIColor(named: "CustomBackgroundColor")!
        salaryTextfield.layer.borderWidth = 0.5
        salaryTextfield.layer.cornerRadius = 10
        changeInterface(passButtonEnabled: nil, saveButtonEnabled: nil, photoButtonEnabled: nil, deleteButtonHidden: nil, progressHidden: true)
 
        if let employee = employee {
            if let loggedUser = loggedUser {
                if employee.id == loggedUser.id {
                    changeInterface(passButtonEnabled: nil, saveButtonEnabled: nil, photoButtonEnabled: nil, deleteButtonHidden: true, progressHidden: nil)
                    jobSelector.isEnabled = false
                    
                } else {
                    changeInterface(passButtonEnabled: nil, saveButtonEnabled: nil, photoButtonEnabled: nil, deleteButtonHidden: false, progressHidden: nil)
                }
            }
            addPhotoButton.setTitle("Edit Photo", for: .normal)
            nameTextfield.becomeFirstResponder()
            nameTextfield.text = employee.name
            emailTextfield.text = employee.email
            salaryTextfield.text = String(employee.salary)
            biographyTextfield.text = employee.biography
            switch employee.job {
            case Constants.employee:
                jobSelector.selectedSegmentIndex = 0
            case Constants.humanresources:
                jobSelector.selectedSegmentIndex = 1
            case Constants.executive:
                jobSelector.selectedSegmentIndex = 2
            default:
                jobSelector.selectedSegmentIndex = 0
            }
            profileImage.kf.setImage(with: URL(string: employee.profileImgUrl),
                                     placeholder: Constants.profileImage,
                                     options: [.transition(.fade(0.25))])
        } else {
            addPhotoButton.setTitle("Add Photo", for: .normal)
            deleteButton.isHidden = true
            changePasswordButton.isHidden = true
        }
       
    }
    
    // MARK: - Buttons functions
    @IBAction func deleteEmployee(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Are you sure?",
                                            message: "This action can't be undone",
                                            preferredStyle: .actionSheet)
        deleteAlert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
            if let employee = self.employee, let apiToken = self.loggedUser?.api_token, let id = employee.id{
                NetworkingProvider.shared.delete(employeeID: id,
                                                 apiToken: apiToken) {
                    self.employee = nil
                    self.deletedEmployee = id
                    self.performSegue(withIdentifier: "backToList", sender: self)
                } failure: { error in
                    let errorAlert = Constants.createAlert(title: "Error",
                                                           message: error,
                                                           image: Constants.errorImage,
                                                           color: UIColor(named: "CustomPink") ?? UIColor(named: "CustomPink") ?? Constants.customPink,
                                                           callBack: nil)
                    self.present(errorAlert, animated: true, completion: nil)
                } noPermission: { error in
                    self.present(Constants.createAlert(title: "No permission",
                                                       message: error,
                                                       image: Constants.errorImage,
                                                       color: UIColor(named: "CustomPink") ?? Constants.customPink,
                                                       callBack: {
                        if let first = self.presentingViewController,
                                let second = first.presentingViewController{
                                  first.view.isHidden = true
                                  second.dismiss(animated: true)
                             }
                    }), animated: true, completion: nil)
                }
            }
        }))
        deleteAlert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
            deleteAlert.dismiss(animated: true)
        }))
        present(deleteAlert, animated: true)
    }
    
    @IBAction func saveEmployee(_ sender: Any) {
        if let apiToken = loggedUser?.api_token{
            self.changeInterface(passButtonEnabled: nil, saveButtonEnabled: false, photoButtonEnabled: nil, deleteButtonHidden: nil, progressHidden: nil)
            var name: String?
            var email: String?
            var salary: Float?
            var biography: String?
            var error = false
            var alertMessage = ""
            var job: String
            
            switch jobSelector.selectedSegmentIndex {
            case 0:
                job = Constants.employee
            case 1:
                job = Constants.humanresources
            case 2:
                job = Constants.executive
            default:
                job = Constants.employee
            }
     
            if let nameText = nameTextfield.text {
                if nameText.count <= 30 || nameText.isEmpty {
                    name = nameText
                } else {
                    error = true
                    alertMessage.append(contentsOf: "Name must not be longer than 30 characters \n")
                }
            }
            
            if let emailText = emailTextfield.text {
                if emailText.count <= 40 && !emailText.isEmpty {
                    email = emailText
                } else {
                    error = true
                    alertMessage.append(contentsOf: "Email is mandatory and must not be longer than 30 characters\n")
                }
            }
            
            if let salaryText = salaryTextfield.text, let salaryNumber = Float(salaryText) {
                salary = salaryNumber
            } else {
                error = true
                alertMessage.append(contentsOf: "Salary is mandatory and must be a number\n")
            }
           
            if let biographyText = biographyTextfield.text {
                if biographyText.count <= 300 && !biographyText.isEmpty {
                    biography = biographyText
                } else {
                    error = true
                    alertMessage.append(contentsOf: "Biogtaphy is mandatory and must not be longer than 300 characters\n")
                }
            }
            
            if error {
                let errorAlert = Constants.createAlert(title: "Check fields",
                                                       message: alertMessage,
                                                       image: Constants.errorImage,
                                                       color: UIColor(named: "CustomPink") ?? Constants.customPink,
                                                       callBack: nil)
                present(errorAlert, animated: true, completion: nil)
                self.changeInterface(passButtonEnabled: nil, saveButtonEnabled: true, photoButtonEnabled: nil, deleteButtonHidden: nil, progressHidden: nil)            } else {
                if let correctName = name, let correctEmail = email, let correctBiography = biography, let correctSalary = salary {
                    if let employee = employee, let id = employee.id{
                        employee.name = correctName
                        employee.email = correctEmail
                        employee.job = job
                        employee.salary = correctSalary
                        employee.biography = correctBiography
                        if let profileImageURL = profileImageURL {
                            employee.profileImgUrl = profileImageURL
                        }
                        
                        NetworkingProvider.shared.modify(employee: employee, apiToken: apiToken, employeeID: id) {
                            if let loggedUser = self.loggedUser {
                                if loggedUser.id == employee.id {
                                    let userDefaults = UserDefaults.standard
                                    do {
                                        try userDefaults.setObject(employee, forKey: "loggedUser")
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                            self.performSegue(withIdentifier: "backToList", sender: self)
                        } failure: { error in
                            let errorAlert = Constants.createAlert(title: "Error",
                                                                   message: error,
                                                                   image: Constants.errorImage,
                                                                   color: UIColor(named: "CustomPink") ?? Constants.customPink,
                                                                   callBack: nil)
                            self.present(errorAlert, animated: true, completion: nil)
                            self.changeInterface(passButtonEnabled: nil, saveButtonEnabled: true, photoButtonEnabled: nil, deleteButtonHidden: nil, progressHidden: nil)
                        } noPermission: { error in
                            //TODO: Codigo duplicado
                            self.present(Constants.createAlert(title: "No permission",
                                                               message: error, image: Constants.errorImage,
                                                               color: UIColor(named: "CustomPink") ?? Constants.customPink,
                                                               callBack: {
                                if let first = self.presentingViewController,
                                        let second = first.presentingViewController{
                                          first.view.isHidden = true
                                          second.dismiss(animated: true)
                                     }
                            }), animated: true, completion: nil)
                        }
                    } else {
                        employee = User(id: nil, name: correctName, email: correctEmail, job: job, salary: correctSalary, biography: correctBiography, profileImageUrl: profileImageURL ?? "https://picsum.photos/500/500")
                        if let employee = employee {
                            NetworkingProvider.shared.add(apiToken: apiToken, employee: employee) {
                                self.performSegue(withIdentifier: "backToList", sender: self)
                            } failure: { error in
                                let errorAlert = Constants.createAlert(title: "Error",
                                                                       message: error,
                                                                       image: Constants.errorImage,
                                                                       color: UIColor(named: "CustomPink") ?? Constants.customPink,
                                                                       callBack: nil)
                                self.present(errorAlert, animated: true, completion: nil)
                                self.changeInterface(passButtonEnabled: nil, saveButtonEnabled: true, photoButtonEnabled: nil, deleteButtonHidden: nil, progressHidden: nil)
                            } noPermission: { error in
                                let userDefaults = UserDefaults.standard
                                do {
                                    try userDefaults.removeObject(forKey: "loggedUser")
                                } catch {
                                    print(error.localizedDescription)
                                }
                            
                                self.present(Constants.createAlert(title: "No permission",
                                                                   message: error,
                                                                   image: Constants.errorImage,
                                                                   color: UIColor(named: "CustomPink") ?? Constants.customPink,
                                                                   callBack: {
                                    if let first = self.presentingViewController,
                                            let second = first.presentingViewController{
                                              first.view.isHidden = true
                                              second.dismiss(animated: true)
                                         }
                                }), animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func changePassword(_ sender: Any) {
        self.changeInterface(passButtonEnabled: false, saveButtonEnabled: nil, photoButtonEnabled: nil, deleteButtonHidden: nil, progressHidden: nil)
        if let employee = employee {
            NetworkingProvider.shared.passwordRecover(email: employee.email) {
                let passAlert = Constants.createAlert(title: "New password sent",
                                                      message: "The new password has been sent to the employee email",
                                                      image: Constants.passwordImage,
                                                      color: UIColor(named: "CustomBlue") ?? Constants.customBlue,
                                                      callBack: nil)
                self.present(passAlert, animated: true, completion: nil)
                self.changeInterface(passButtonEnabled: true, saveButtonEnabled: nil, photoButtonEnabled: nil, deleteButtonHidden: nil, progressHidden: nil)
            } failure: { error in
                let errorAlert = Constants.createAlert(title: "Error",
                                                       message: error,
                                                       image: Constants.errorImage,
                                                       color: UIColor(named: "CustomPink") ?? Constants.customPink,
                                                       callBack: nil)
                self.present(errorAlert, animated: true, completion: nil)
                self.changeInterface(passButtonEnabled: true, saveButtonEnabled: nil, photoButtonEnabled: nil, deleteButtonHidden: nil, progressHidden: nil)
            }
        }
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToList"{
            let controller = segue.destination as? EmployeesListViewController
            if let employee = employee {
                controller?.edditedEmployee = employee
            }
            if let deletedEmployee = deletedEmployee {
                controller?.deletedEmployee = deletedEmployee
            }
        }
    }
    
    // MARK: - Supporting functions
    func changeInterface(passButtonEnabled: Bool?, saveButtonEnabled: Bool?, photoButtonEnabled: Bool?, deleteButtonHidden: Bool?, progressHidden: Bool?){
        if let passButtonEnabled = passButtonEnabled {
            changePasswordButton.isEnabled = passButtonEnabled
        }
        if let saveButtonEnabled = saveButtonEnabled {
            saveButton.isEnabled = saveButtonEnabled
        }
        if let photoButtonEnabled = photoButtonEnabled {
            addPhotoButton.isEnabled = photoButtonEnabled
        }
        if let deleteButtonHidden = deleteButtonHidden {
            deleteButton.isHidden = deleteButtonHidden
        }
        if let progressHidden = progressHidden {
            uploadProgressBar.isHidden = progressHidden
        }
    }
}

// MARK: - ImagePicker extension
extension EditEmployeeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let file = info[.editedImage] as? UIImage
        let url = info[.imageURL] as? URL
            
        if let file = file, let apiToken = loggedUser?.api_token{
            self.changeInterface(passButtonEnabled: nil, saveButtonEnabled: nil, photoButtonEnabled: false, deleteButtonHidden: nil, progressHidden: false)
            NetworkingProvider.shared.uploadImage(image: file, apiToken: apiToken) { progressQuantity in
                self.uploadProgressBar.progress = Float(progressQuantity)
            } success: { fileUrl in
                self.profileImage.image = file
                self.profileImageURL = fileUrl
                
                self.changeInterface(passButtonEnabled: nil, saveButtonEnabled: nil, photoButtonEnabled: true, deleteButtonHidden: nil, progressHidden: true)
            } failure: { error in
                let imageAlert = Constants.createAlert(title: "Error",
                                                       message: "There was a problem uploading the image, please try again",
                                                       image: Constants.errorImage,
                                                       color: UIColor(named: "CustomPink") ?? Constants.customPink,
                                                       callBack: nil)
                self.changeInterface(passButtonEnabled: nil, saveButtonEnabled: nil, photoButtonEnabled: true, deleteButtonHidden: nil, progressHidden: true)
                self.present(imageAlert, animated: true, completion: nil)
            }


        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
