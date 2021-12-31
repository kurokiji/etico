//
//  Networking Provider.swift
//  etico
//
//  Created by Daniel Torres on 22/12/21.
//

import Foundation
import Alamofire
import UIKit

final class NetworkingProvider {
    static let shared = NetworkingProvider()
    
    private let kBaseUrl = "\(Constants.proyectUrl)/api"
    let statusOk = 200...299
    
    func login(email: String, password: String, success: @escaping (_ user: User) -> (), failure: @escaping (_ error: String) ->()) {
        let url = "\(kBaseUrl)/login"
        let parameters: Parameters = [
            "email" : email,
            "password" : password
        ]
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).validate(statusCode: statusOk).responseDecodable (of: Login.self) { response in
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
                failure("There is a problem connecting to the server")
            }
        }
    }
    
    func getAll(apiToken: String, success: @escaping (_ employees: [User]) ->(), failure: @escaping (_ error: String) -> ()) {
        let url = "\(kBaseUrl)/employee/getall"
        
        let headers: HTTPHeaders = [
            "token" : apiToken
        ]
        
        AF.request(url, method: .get, headers: headers).validate(statusCode: statusOk).responseDecodable (of: Response.self) { response in
            if let status = response.value?.status {
                if status == 1 {
                    if let employees = response.value?.data {
                        success(employees)
                        for employee in employees {
                            print(employee.salary)
                        }
                    }
                } else {
                    failure(response.value!.msg)
                }
            } else {
                print(response)
                failure("There is a problem connecting to the server")
            }
        }
    }
    
    func add(apiToken: String, employee: User, success: @escaping () ->(), failure: @escaping (_ error: String) -> ()) {
        let url = "\(kBaseUrl)/employee/add"
        
        let headers: HTTPHeaders = [
            "token" : apiToken
        ]
        
        let parameters: Parameters = [
            "name" : employee.name,
            "email" : employee.email,
            "job" : employee.job,
            "salary" : employee.salary,
            "biography" : employee.biography,
            "profileImgUrl": employee.profileImgUrl
        ]
        
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate(statusCode: statusOk).responseDecodable (of:Response.self) { response in
            if let status = response.value?.status {
                if status == 1 {
                    success()
                } else {
                    failure(response.value!.msg)
                }
            } else {
                failure("There is a problem connecting to the server")
            }
        }
    }
    
    func passwordRecover(email: String, success: @escaping () ->(), failure: @escaping (_ error: String) -> ()) {
        let url = "\(kBaseUrl)/passwordrecover"
        
        let parameters: Parameters = [
            "email" : email
        ]
        
        AF.request(url, method: .put, parameters: parameters).validate(statusCode: statusOk).responseDecodable (of: Response.self) { response in
            if let status = response.value?.status {
                if status == 1 {
                    success()
                } else {
                    failure(response.value!.msg)
                }
            } else {
                failure("There is a problem connecting to the server")
            }
        }
    }
    
    func modify(employee: User, apiToken: String, employeeID: Int, success: @escaping () -> (), failure: @escaping (_ error: String) ->()) {
        let url = "\(kBaseUrl)/employee/modify/\(employeeID)"
        
        let headers: HTTPHeaders = [
            "token" : apiToken
        ]
        
        let parameters: [String : Any] = [
            "name" : employee.name,
            "email" : employee.email,
            "job" : employee.job,
            "salary" : employee.salary,
            "biography" : employee.biography,
            "profileImgUrl" : employee.profileImgUrl
        ]
        
        // POR QUE TENGO QUE USAR EL ENCODING PARA ESTE
        
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate(statusCode: statusOk).responseDecodable (of: Response.self) { response in
            if let status = response.value?.status {
                if status == 1 {
                    success()
                } else {
                    failure(response.value!.msg)
                }
            } else {
                failure("There is a problem connecting to the server")
            }
        }
        
    }
    
    func delete(employeeID: Int, apiToken: String, success: @escaping () -> (), failure: @escaping (_ error: String) -> ()) {
        let url = "\(kBaseUrl)/employee/delete/\(employeeID)"
        let headers: HTTPHeaders = [
            "token" : apiToken
        ]
        
        AF.request(url, method: .put, headers: headers).validate(statusCode: statusOk).responseDecodable (of:Response.self) { response in
            if let status = response.value?.status {
                if status == 1 {
                    success()
                } else {
                    failure(response.value!.msg)
                }
            } else {
                failure("There is a problem connecting to the server")
            }
        }
    }
    
    func uploadImage(image: UIImage?, apiToken: String,progress: @escaping ( _ progressQuantity: Double) -> (), success: @escaping ( _ fileUrl: String) -> (), failure: @escaping ( _ error: String)-> ()) {
        let url = "\(kBaseUrl)/employee/uploadimage"
        let headers: HTTPHeaders = [
            "token" : apiToken
        ]
        
//        if let imageUrl = imageUrl {
            if let file = image?.jpegData(compressionQuality: 0.1){
                AF.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(file, withName: "photo", fileName: "profile.png" , mimeType: "image/png")
                    
                }, to: url, method: .post, headers: headers).validate(statusCode: statusOk).uploadProgress(closure: { progressQuantity in
                    progress(progressQuantity.fractionCompleted)
                }).responseDecodable (of: Response.self) { response in
                    if let status = response.value?.status {
                        if status == 1 {
                            if let url = response.value?.msg{
                                success(Constants.proyectUrl + url)
                            }
                        } else {
                            failure(response.value!.msg)
                        }
                    } else {
                        failure("There is a problem connecting to the server")
                    }
                }
            }
            
//        }
    }
    
    func checkToken(apiToken: String, success: @escaping () ->(), failure: @escaping (_ error: String) -> ()) {
        let url = "\(kBaseUrl)/checktoken"
        
        let parameters: Parameters = [
            "token" : apiToken
        ]
        
        AF.request(url, method: .put, parameters: parameters).validate(statusCode: statusOk).responseDecodable (of: Response.self) { response in
            if let status = response.value?.status {
                if status == 1 {
                    success()
                } else {
                    failure(response.value!.msg)
                }
            } else {
                failure("There is a problem connecting to the server")
            }
        }
    }
    
    func logout(apiToken: String, success: @escaping ()->(), failure: @escaping (_ error: String) -> ()){
        let url = "\(kBaseUrl)/employee/logout"
        
        let headers: HTTPHeaders = [
            "token" : apiToken
        ]
        
        AF.request(url, method: .put, headers: headers).validate(statusCode: statusOk).responseDecodable (of:Response.self) { response in
            print(response)
            if let status = response.value?.status {
                if status == 1 {
                    success()
                } else {
                    failure(response.value!.msg)
                }
            } else {
                failure("There is a problem connecting to the server")
            }
        }
    }
}
