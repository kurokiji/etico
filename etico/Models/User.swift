//
//  User.swift
//  etico
//
//  Created by Daniel Torres on 22/12/21.
//

import Foundation

class User: Decodable, Encodable{
    var id: Int?
    var name: String
    var email: String
    var job: String
    var salary: Float
    var biography: String
    var profileImgUrl: String
    var api_token: String?
    
    init(id: Int?, name: String, email: String, job: String, salary: Float, biography: String, profileImageUrl: String) {
        self.id = id
        self.name = name
        self.email = email
        self.job = job
        self.salary = salary
        self.biography = biography
        self.profileImgUrl = profileImageUrl
    }
    
    // TODO: Es mejor pasar un valor 0 al id cuando inicilizas al crear un usuario nuevo o hacer la id opcional?

}

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
    
    enum ObjectSavableError: String, LocalizedError {
        case unableToEncode = "Unable to encode object into data"
        case noValue = "No data object found for the given key"
        case unableToDecode = "Unable to decode object into given type"
        
        var errorDescription: String? {
            rawValue
        }
    }
}
