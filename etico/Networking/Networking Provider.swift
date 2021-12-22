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
    
    func login(email: String, password: String, success: @escaping (_ user: User) -> (), failure: @escaping (_ error: (Int, String)) ->()) {
        
        let url = "\(kBaseUrl)login"
        
        let parameters: Parameters = [
            "email" : email,
            "password" : password
        ]
        
        AF.request(url, method: .put, parameters: parameters).validate(statusCode: statusOk).responseDecodable (of: Login.self) { response in
            if let status = response.value?.status {
                if status == 1 {
                    if let user = response.value?.user {
                        success(user)
                    }
                } else {
                    failure((response.value!.status, response.value!.msg))
                }
            } else {
                print(response.error?.responseCode ?? "No error")
            }
        }
    }

}
