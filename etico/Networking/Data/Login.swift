//
//  Login.swift
//  etico
//
//  Created by Daniel Torres on 22/12/21.
//

import Foundation

class Login: Decodable {
    var status: Int
    var msg: String
    var user: User?
}
