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
    
    // TODO: Modificar botones dependiendo de donde venga, o hacerlo enl anterior
    
    override func viewDidLoad() {
        super.viewDidLoad()
        biographyTextfield.delegate = self
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.5
        card.layer.shadowOffset = .init(width: 6, height: 6)
        card.layer.shadowRadius = 20
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 20.0
        IQKeyboardManager.shared.toolbarTintColor = Constants.customBlue
 
        if let employee = employee {
            if let loggedUser = loggedUser {
                if employee.id == loggedUser.id {
                    deleteButton.isHidden = true
                    
                } else {
                    deleteButton.isHidden = false
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
                                                           color: Constants.customPink)
                    self.present(errorAlert, animated: true, completion: nil)
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
            changeButtonsStatus(passButtonEnabled: nil, saveButtonEnabled: false)
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
                if biographyText.count <= 500 && !biographyText.isEmpty {
                    biography = biographyText
                } else {
                    error = true
                    alertMessage.append(contentsOf: "Biogtaphy is mandatory and must not be longer than 500 characters\n")
                }
            }
            
            if error {
                let errorAlert = Constants.createAlert(title: "Check fields",
                                                       message: alertMessage,
                                                       image: Constants.errorImage,
                                                       color: Constants.customPink)
                present(errorAlert, animated: true, completion: nil)
                changeButtonsStatus(passButtonEnabled: nil, saveButtonEnabled: true)
            } else {
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
                            self.performSegue(withIdentifier: "backToList", sender: self)
                        } failure: { error in
                            let errorAlert = Constants.createAlert(title: "Error",
                                                                   message: error,
                                                                   image: Constants.errorImage,
                                                                   color: Constants.customPink)
                            self.present(errorAlert, animated: true, completion: nil)
                            self.changeButtonsStatus(passButtonEnabled: nil, saveButtonEnabled: true)
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
                                                                       color: Constants.customPink)
                                self.present(errorAlert, animated: true, completion: nil)
                                self.changeButtonsStatus(passButtonEnabled: nil, saveButtonEnabled: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func changePassword(_ sender: Any) {
        self.changeButtonsStatus(passButtonEnabled: false, saveButtonEnabled: nil)
        if let employee = employee {
            NetworkingProvider.shared.passwordRecover(email: employee.email) {
                self.changePasswordButton.isEnabled = false
                let passAlert = Constants.createAlert(title: "New password sent",
                                                      message: "The new password has been sent to the employee email",
                                                      image: Constants.passwordImage,
                                                      color: Constants.customBlue)
                self.present(passAlert, animated: true, completion: nil)
                self.changeButtonsStatus(passButtonEnabled: true, saveButtonEnabled: nil)
            } failure: { error in
                let errorAlert = Constants.createAlert(title: "Error",
                                                       message: error,
                                                       image: Constants.errorImage,
                                                       color: Constants.customPink)
                self.present(errorAlert, animated: true, completion: nil)
                self.changeButtonsStatus(passButtonEnabled: true, saveButtonEnabled: nil)
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
    func changeButtonsStatus(passButtonEnabled: Bool?, saveButtonEnabled: Bool?){
        if let passButtonEnabled = passButtonEnabled {
            changePasswordButton.isEnabled = passButtonEnabled
        }
        if let saveButtonEnabled = saveButtonEnabled {
            saveButton.isEnabled = saveButtonEnabled
        }
    }
}

// MARK: - ImagePicker extension
extension EditEmployeeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let file = info[.editedImage] as? UIImage
        let url = info[.imageURL] as? URL
        
        if let imageUrl = url, let apiToken = loggedUser?.api_token{
            NetworkingProvider.shared.uploadImage(imageUrl: imageUrl, apiToken: apiToken) { fileUrl in
                self.profileImage.image = file
                self.profileImageURL = fileUrl
                print(fileUrl)
            } failure: { error in
                let imageAlert = Constants.createAlert(title: "Error", message: "There was a problem uploading the image, please try again", image: Constants.errorImage, color: Constants.customPink)
                self.present(imageAlert, animated: true, completion: nil)
            }

        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension EditEmployeeViewController: UITextViewDelegate {
    
}
