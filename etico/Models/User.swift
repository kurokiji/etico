//
//  User.swift
//  etico
//
//  Created by Daniel Torres on 22/12/21.
//

import Foundation

class User: Decodable{
    var name: String
    var email: String
    var job: String
    var salary: Float
    var biography: String
    var api_token: String
}


