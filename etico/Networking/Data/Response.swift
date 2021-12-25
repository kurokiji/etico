//
//  GetAllResponse.swift
//  etico
//
//  Created by Daniel Torres on 23/12/21.
//

import Foundation

class Response: Decodable {
    var status: Int
    var msg: String
    var data: [User]?
}
