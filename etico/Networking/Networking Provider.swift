//
//  Networking Provider.swift
//  etico
//
//  Created by Daniel Torres on 22/12/21.
//

import Foundation
import Alamofire

final class NetworkingProvider {
    static let shared = NetworkingProvider()
    
    private let kBaseUrl = "http://localhost:8888/employee-management/public/api/"
    let statusOk = 200...299
    
    func login(email: String, password: String, success: @escaping (_ user: User) -> (), failure: @escaping (_ error: String) ->()) {
        let url = "\(kBaseUrl)login"
        let parameters: Parameters = [
            "email" : email,
            "password" : password
        ]
        AF.request(url, method: .put, parameters: parameters).validate(statusCode: statusOk).responseDecodable (of: Login.self) { response in
            print(response)
            if let status = response.value?.status {
                if status == 1 {
                    if let user = response.value?.user {
                        success(user)
                    }
                } else {
                    failure(response.value!.msg)
                }
            } else {
                failure("Hay un problema de conexión con el servidor")
            }
        }
    }
    
    func getAll(apiToken: String, success: @escaping (_ employees: [User]) ->(), failure: @escaping (_ error: String) -> ()) {
        let url = "\(kBaseUrl)employee/getall"
        
        let headers: HTTPHeaders = [
            "Token" : apiToken
        ]
        
        AF.request(url, method: .get, headers: headers).validate(statusCode: statusOk).responseDecodable (of: Response.self) { response in
            if let status = response.value?.status {
                if status == 1 {
                    if let employees = response.value?.data {
                        success(employees)
                    }
                } else {
                    failure(response.value!.msg)
                }
            } else {
                failure(response.value!.msg)
            }
        }
    }
    
    func add(apiToken: String, employee: User, success: @escaping () ->(), failure: @escaping (_ error: String) -> ()) {
        let url = "\(kBaseUrl)employee/add"
        
        let headers: HTTPHeaders = [
            "Token" : "456"
        ]
        
        let parameters: Parameters = [
            "name" : employee.name,
            "email" : employee.email,
            "job" : employee.job,
            "salary" : employee.salary,
            "biography" : employee.biography
        ]
        
        AF.request(url, method: .put, parameters: parameters, headers: headers).validate(statusCode: statusOk).responseDecodable (of: Response.self) { response in
            if let status = response.value?.status {
                if status == 1 {
                    
                } else {
                    failure(response.value!.msg)
                }
            } else {
                failure(response.value!.msg)
            }
        }
    }
    
    func passwordRecover(email: String, success: @escaping () ->(), failure: @escaping (_ error: String) -> ()) {
        let url = "\(kBaseUrl)passwordrecover"
        
        let parameters: Parameters = [
            "email" : email
        ]
        
        AF.request(url, method: .put, parameters: parameters).validate(statusCode: statusOk).responseDecodable (of: Response.self) { response in
            print(response)
            if let status = response.value?.status {
                if status == 1 {
                    success()
                } else {
                    failure(response.value!.msg)
                }
            } else {
                failure(response.value!.msg)
            }
        }
    }
    
    func modify(employee: User, apiToken: String, success: @escaping () -> (), failure: @escaping (_ error: String) ->()) {
        let url = "\(kBaseUrl)employee/modify/\(employee.id)"
        
        let headers: HTTPHeaders = [
            "Token" : "678"
        ]
        
        let parameters: [String : Any] = [
            "name" : employee.name,
            "email" : employee.email,
            "job" : employee.job,
            "salary" : employee.salary,
            "biography" : employee.biography
        ]
        
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate(statusCode: statusOk).responseDecodable (of:ValidateResponse.self) { response in
            if let status = response.value?.status {
                if status == 1 {
                    success()
                } else {
                    failure(response.value!.msg)
                }
            } else {
                failure(response.value!.msg)
            }
        }
        
    }
    
    func delete(employeeID: Int, apiToken: String, success: @escaping () -> (), failure: @escaping (_ error: String) -> ()) {
        let url = "\(kBaseUrl)employee/delete/\(employeeID)"
        let headers: HTTPHeaders = [
            "Token" : "678"
        ]
        
        AF.request(url, method: .put, headers: headers).validate(statusCode: statusOk).responseDecodable (of:ValidateResponse.self) { response in
            if let status = response.value?.status {
                if status == 1 {
                    success()
                } else {
                    failure(response.value!.msg)
                }
            } else {
                failure(response.value!.msg)
            }
        }
    }
}
