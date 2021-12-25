//
//  EditEmployeeViewController.swift
//  etico
//
//  Created by Daniel Torres on 23/12/21.
//

import UIKit
import Kingfisher

class EditEmployeeViewController: UIViewController {

    var employee: User?
    var loggedUser: User?
    var editedEmployee: User?
    
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
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.5
        card.layer.shadowOffset = .init(width: 6, height: 6)
        card.layer.shadowRadius = 20
        // TODO: Añadir limtes a la edición
        //https://www.hackingwithswift.com/example-code/uikit/how-to-limit-the-number-of-characters-in-a-uitextfield-or-uitextview
        
        if let employee = employee {
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
        }
        
        if employee!.id == loggedUser!.id {
            deleteButton.isHidden = true
        }
        
        if employee != nil {
            addPhotoButton.setTitle("Change Photo", for: .normal)
        } else {
            addPhotoButton.setTitle("Add Photo", for: .normal)
            deleteButton.isHidden = true
            nameTextfield.becomeFirstResponder()
        }
    }
    
    @IBAction func deleteEmployee(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Are you sure?",
                                            message: "This action can't be undone",
                                            preferredStyle: .actionSheet)
        deleteAlert.addAction(.init(title: "Delete",
                                    style: .destructive,
                                    handler: { _ in
            NetworkingProvider.shared.delete(employeeID: self.employee!.id,
                                             apiToken: self.loggedUser!.api_token!) {

                if let first = self.presentingViewController,
                        let second = first.presentingViewController{
                          first.view.isHidden = true
                          second.dismiss(animated: true)
                     }
            } failure: { error in
                self.showAlert(title: "Error",
                               message: error,
                               image: Constants.errorImage,
                               color: Constants.customPink)
            }
        }))
        
        deleteAlert.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
            deleteAlert.dismiss(animated: true)
        }))
        
        present(deleteAlert, animated: true)

    }
    
    
    @IBAction func addPhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
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
            
            if let loggedUser = loggedUser {
                NetworkingProvider.shared.modify(employee: editedEmployee!, apiToken: "") {
                    self.performSegue(withIdentifier: "backToList", sender: self)
                } failure: { error in
                    self.showAlert(title: "Error",
                              message: error,
                                   image: Constants.errorImage,
                              color: Constants.customPink)
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
            
            NetworkingProvider.shared.add(apiToken: "", employee: editedEmployee!) {
                // TODO: unwind segue a la pantalla anterior con los nuevos datos y a la lista
                self.performSegue(withIdentifier: "backToList", sender: self)
            } failure: { error in
                self.showAlert(title: "Error",
                               message: error,
                               image: Constants.errorImage,
                               color: Constants.customPink)
                self.changeButtonsStatus(passButtonEnabled: nil, saveButtonEnabled: true)
            }

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToList"{
            let controller = segue.destination as? EmployeesListViewController
            controller?.edditedEmployee = editedEmployee
        }
    }
    
    
    @IBAction func changePassword(_ sender: Any) {
        self.changeButtonsStatus(passButtonEnabled: false, saveButtonEnabled: nil)
        if let employee = employee {
            NetworkingProvider.shared.passwordRecover(email: employee.email) {
                self.changePasswordButton.isEnabled = false
                self.showAlert(title: "New password sent",
                               message: "The new password has been sent to the employee email",
                               image: Constants.passwordImage,
                               color: Constants.customBlue)
                self.changeButtonsStatus(passButtonEnabled: true, saveButtonEnabled: nil)
            } failure: { error in
                self.showAlert(title: "Error",
                               message: error,
                               image: Constants.errorImage,
                               color: Constants.customPink)
                self.changeButtonsStatus(passButtonEnabled: true, saveButtonEnabled: nil)
            }
        }
    }
    
    func showAlert(title: String, message:String, image: UIImage?, color: UIColor) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let myAlert = storyBoard.instantiateViewController(withIdentifier: "alert") as? CustomAlertViewController {
            myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            myAlert.customTitle = title
            myAlert.message = message
            myAlert.image = image
            myAlert.color = color
            self.present(myAlert, animated: true, completion: nil)
        }
    }
    
    func changeButtonsStatus(passButtonEnabled: Bool?, saveButtonEnabled: Bool?){
        if let passButtonEnabled = passButtonEnabled {
            changePasswordButton.isEnabled = passButtonEnabled
        }
        if let saveButtonEnabled = saveButtonEnabled {
            saveButton.isEnabled = saveButtonEnabled
        }
    }
    
}

extension EditEmployeeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage]
        let url = info[.imageURL]
        profileImage.image = image as? UIImage
        //TODO: Guardar imagen en el servidor
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
