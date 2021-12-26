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
    var editedEmployee: User?
    var deletedEmployee: Int?
    
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
        // TODO: Añadir limtes a la edición
        //https://www.hackingwithswift.com/example-code/uikit/how-to-limit-the-number-of-characters-in-a-uitextfield-or-uitextview
 
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
            if let employee = self.employee, let apiToken = self.loggedUser?.api_token{
                NetworkingProvider.shared.delete(employeeID: employee.id,
                                                 apiToken: apiToken) {
                    self.editedEmployee = nil
                    self.deletedEmployee = employee.id
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
        changeButtonsStatus(passButtonEnabled: nil, saveButtonEnabled: false)
        
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
        
        //TODO: Extraer cada elemento de su field
        
        //TODO: Hacer una función de validación que reciva una función para mostrar el alert y devuelva los datos relativos a los errores
        
        //TODO: Comprobar función, si pasa hacer la petición
        
        if let employee = employee {
            //            let salary = Float(salaryTextfield.text)
            //            let editedEmployee = User.init(id: employee.id,
            //                                           name: nameTextfield.text ?? "No name",
            //                                           email: employee.email,
            //                                           job: job,
            //                                           salary: Float(salaryTextfield.text!)!,
            //                                           biography: biographyTextfield.text ?? "No biography")
            editedEmployee = User.init(id: employee.id,
                                       name: "puton",
                                       email: "puta@putonnnn.com",
                                       job: job,
                                       salary: 00000,
                                       biography: "asdfghjklertyuixcvb srdgsryh sht zdh ery aer gbdfz bzdfh adfh f zdhfzghfgh zdfhdf hzdfh zdfh zd fhfdkhzdhfhz",
                                       profileImageUrl: "WASDASD")
            
            // TODO: No crear nuevo usuario, utilizar el mismo y asignar variables
            
            if let api_token = loggedUser?.api_token, let editedEmployee = editedEmployee {
                NetworkingProvider.shared.modify(employee: editedEmployee, apiToken: api_token) {
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
            
        } else {
            editedEmployee = User.init(id: 0,
                                       name: "puton",
                                       email: "puta@puton.com",
                                       job: job,
                                       salary: 00000,
                                       biography: "asdfghjklertyuixcvb srdgsryh sht zdh ery aer gbdfz bzdfh adfh f zdhfzghfgh zdfhdf hzdfh zdfh zd fhfdkhzdhfhz",
                                       profileImageUrl: "asfdasfdasd")
            if let api_token = loggedUser?.api_token, let editedEmployee = editedEmployee {
                NetworkingProvider.shared.add(apiToken: api_token, employee: editedEmployee) {
                    // TODO: unwind segue a la pantalla anterior con los nuevos datos y a la lista
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
            if let editedEmployee = editedEmployee {
                controller?.edditedEmployee = editedEmployee
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
        let file = info[.editedImage]
        let url = info[.imageURL]
        profileImage.image = file as? UIImage
        
        if let imageUrl = url{
            NetworkingProvider.shared.uploadImage(imageUrl: imageUrl as? URL, apiToken: loggedUser?.api_token ?? "") { fileUrl in
                print("uploaded")
            } failure: { error in
                print(error)
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
