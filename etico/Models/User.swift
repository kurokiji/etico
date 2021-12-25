//
//  User.swift
//  etico
//
//  Created by Daniel Torres on 22/12/21.
//

import Foundation

class User: Decodable{
    var id: Int
    var name: String
    var email: String
    var job: String
    var salary: Float
    var biography: String
    var profileImgUrl: String
    var api_token: String?
    
    init(id: Int, name: String, email: String, job: String, salary: Float, biography: String, profileImageUrl: String) {
        self.id = id
        self.name = name
        self.email = email
        self.job = job
        self.salary = salary
        self.biography = biography
        self.profileImgUrl = profileImageUrl
    }
    
    // TODO: Es mejor pasar un valor 0 al id cuando inicilizas al crear un usuario nuevo o hacer la id opcional?
    
//    init(name: String, email: String, job: String, salary: Float, biography: String) {
//        self.name = name
//        self.email = email
//        self.job = job
//        self.salary = salary
//        self.biography = biography
//    }
}


