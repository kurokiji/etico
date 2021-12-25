//
//  EmployeesListViewController.swift
//  etico
//
//  Created by Daniel Torres on 22/12/21.
//

import UIKit
import Alamofire

//TODO: COMO ACTUALIZAR CADA VEZ QUE VUELVAS A ESTA VENTANA!?!?!?!?!

class EmployeesListViewController: UIViewController {

    var loggedUser: User?
    var edditedEmployee: User?
    var employeesList: [User] = []
    var orderedEmployeesList: [[User]] = []
    var filterSelected = Filters.name
    let refreshControl = UIRefreshControl()
        
    
    @IBOutlet weak var employeesTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showIDButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    enum Filters {
    case name
    case salary
    case job
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        employeesTable.dataSource = self
        employeesTable.delegate = self
        let yellow = UIColor(r: 237, g: 194, b: 80)
        activityIndicator.color = yellow
        showIDButton.isEnabled = false
        filterButton.isEnabled = false
        addButton.isEnabled = false
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
           employeesTable.addSubview(refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveData()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        retrieveData()
    }
    
    func retrieveData() {
        if let loggedUser = loggedUser {
            NetworkingProvider.shared.getAll(apiToken: loggedUser.api_token!) { employees in
                self.employeesList = employees
                self.orderedEmployeesList = self.sortList(by: self.filterSelected,
                                                          employeeList: self.employeesList)
                self.employeesTable.reloadData()
                
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                self.activityIndicator.isHidden = true
                self.showIDButton.isEnabled = true
                self.filterButton.isEnabled = true
                self.addButton.isEnabled = true
            } failure: { error in
                self.present(Constants.createAlert(title: "Ha habido un error",
                                                   message: "Tira de la lista hacia abajo para intentarlo de nuevo",
                                                   image: Constants.alertImage,
                                                   color: Constants.customPink),
                             animated: true)
            }
        }
    }
    
    @IBAction func viewLoggedProfile(_ sender: Any) {
        if let loggedUser = loggedUser {
            if loggedUser.job == Constants.humanresources {
                performSegue(withIdentifier: "showHRProfile", sender: nil)
            } else if loggedUser.job == Constants.executive{
                performSegue(withIdentifier: "showEXProfile", sender: nil)
            }
        }
    }
    
    //TODO: doble comprobacion de loggeduser? aqui
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEXProfile" {
            let controller = segue.destination as! EmployeeViewController
            controller.employee = loggedUser
            controller.loggedUser = loggedUser
        } else if segue.identifier == "addUser"{
            let controller = segue.destination as! EditEmployeeViewController
            controller.loggedUser = loggedUser
        } else if segue.identifier == "showHRProfile"{
            let controller = segue.destination as! ProfileViewController
            controller.loggedUser = loggedUser
        }
    }

    @IBAction func filterButton(_ sender: Any) {
        let filtersAlert = UIAlertController(title: nil,
                                             message: nil,
                                             preferredStyle: .actionSheet)
        
        filtersAlert.addAction(.init(title: "Name",
                                     style: .default,
                                     handler: { _ in
            self.orderedEmployeesList = self.sortList(by: Filters.name,
                                                      employeeList: self.employeesList)
            self.filterSelected = Filters.name
            self.employeesTable.reloadData()
        }))
        
        filtersAlert.addAction(.init(title: "Salary",
                                     style: .default,
                                     handler: { _ in
            self.orderedEmployeesList = self.sortList(by: Filters.salary,
                                                      employeeList: self.employeesList)
            self.filterSelected = Filters.salary
            self.employeesTable.reloadData()
        }))
        
        filtersAlert.addAction(.init(title: "Job",
                                     style: .default,
                                     handler: { _ in
            self.orderedEmployeesList = self.sortList(by: Filters.job,
                                                      employeeList: self.employeesList)
            self.filterSelected = Filters.job
            self.employeesTable.reloadData()
        }))
        
        filtersAlert.addAction(.init(title: "Cancel",
                                     style: .cancel,
                                     handler: { _ in
            filtersAlert.dismiss(animated: true, completion: nil)
        }))
        
        present(filtersAlert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        employeesTable.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "EmployeeViewController") as! EmployeeViewController
        controller.employee = orderedEmployeesList[indexPath.section][indexPath.row]
        controller.loggedUser = loggedUser
        self.present(controller, animated: true)
    }
    
    // TODO: Este FOR es un poco penoso, alguna manera mejor de encontrar el id?
    @IBAction func unwind(_ seg: UIStoryboardSegue) {
        if let employee = edditedEmployee {
            for position in 0..<employeesList.count {
                if employee.id == employeesList[position].id {
                    employeesList[position] = employee
                }
                switch filterSelected {
                case .name:
                    orderedEmployeesList = sortList(by: Filters.name, employeeList: employeesList)
                case .salary:
                    orderedEmployeesList = sortList(by: Filters.salary, employeeList: employeesList)
                case .job:
                    orderedEmployeesList = sortList(by: Filters.job, employeeList: employeesList)
                }
            employeesTable.reloadData()
            }
        }
    }
    
    func sortList(by: Filters, employeeList: [User]) -> [[User]]{
        let alphabeticalEmployees = employeeList.sorted(by: { (s1, s2) -> Bool in
            return s1.name.localizedCompare(s2.name) == .orderedAscending
            })
        var sortedEmployees: [[User]] = []
        switch by {
        case Filters.name:
            sortedEmployees = []
            var prevInitial: Character? = nil
            for employee in alphabeticalEmployees {
                let initial = employee.name.first
                if initial != prevInitial {
                    sortedEmployees.append([])
                    prevInitial = initial
                }
                sortedEmployees[sortedEmployees.endIndex - 1].append(employee)
            }
        case Filters.job:
            sortedEmployees = [[],[],[]]
            for employee in alphabeticalEmployees{
                switch employee.job{
                case Constants.employee:
                    sortedEmployees[0].append(employee)
                case Constants.humanresources:
                    sortedEmployees[1].append(employee)
                default:
                    sortedEmployees[2].append(employee)
                }
            }
        case Filters.salary:
            sortedEmployees = [[],[],[],[],[]]
            for employee in alphabeticalEmployees {
                switch employee.salary {
                case 0..<15000:
                    sortedEmployees[0].append(employee)
                case 15000..<20000:
                    sortedEmployees[1].append(employee)
                case 20000..<25000:
                    sortedEmployees[2].append(employee)
                case 25000..<30000:
                    sortedEmployees[3].append(employee)
                default:
                    sortedEmployees[4].append(employee)
                }
            }
        }
        return sortedEmployees
    }
    
}

extension EmployeesListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return orderedEmployeesList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedEmployeesList[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "employee", for: indexPath)
        cell.textLabel!.text = orderedEmployeesList[indexPath.section][indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName: String
        switch filterSelected {
        case Filters.name:
            sectionName = String(orderedEmployeesList[section][0].name.first!)
        case Filters.salary:
            switch section {
            case 0:
                sectionName = "Up to 10.000€"
            case 1:
                sectionName = "10.000€ to 15.000€"
            case 2:
                sectionName = "15.000€ to 20.000€"
            case 3:
                sectionName = "20.000€ to 25.000€"
            case 4:
                sectionName = "25.000€ to 30.000€"
            default:
                sectionName = "More than 30.000€"
            }
        case Filters.job:
            switch section {
            case 0:
                sectionName = Constants.employeeText
            case 1:
                sectionName = Constants.humanresourcesText
            default:
                sectionName = "Without category"
            }
        }
        return sectionName
    }
}




