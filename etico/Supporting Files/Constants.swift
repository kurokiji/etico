//
//  Constants.swift
//  etico
//
//  Created by Daniel Torres on 22/12/21.
//

import Foundation
import UIKit

final class Constants {
    static let proyectUrl = "http://kurokiji.es"
    
    static let employee = "employee"
    static let humanresources = "humanresources"
    static let executive = "executive"
    
    static let employeeText = "Employee"
    static let humanresourcesText = "Human Resources"
    static let executiveText = "Executive"
    
    static let customYellow = UIColor(r: 237, g: 194, b: 80)
    static let customBlue = UIColor(r: 91, g: 180, b: 218)
    static let customPink = UIColor(r: 216, g: 132, b: 168)
    static let customGrey = UIColor.init(r: 26, g: 26, b: 27)
    static let customBlack = UIColor.init(r: 27, g: 27, b: 29)


    static let errorImage = UIImage(systemName: "xmark.circle.fill")
    static let checkImage = UIImage(systemName: "checkmark.icloud.fill")
    static let passwordImage = UIImage(systemName: "key.icloud.fill")
    static let alertImage = UIImage(systemName: "exclamationmark.triangle.fill")
    static let profileImage = UIImage(systemName: "person.circle")
    
    
   enum job {
        case employee
        case humanresouces
        case executive
    }
    
    static func createAlert(title: String, message:String, image: UIImage?, color: UIColor, callBack: (()-> Void)?) -> CustomAlertViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyBoard.instantiateViewController(withIdentifier: "alert") as! CustomAlertViewController
            myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            myAlert.callBack = callBack
            myAlert.customTitle = title
            myAlert.message = message
            myAlert.image = image
            myAlert.color = color
       return myAlert
    }
}

extension UIColor {
     convenience init(r: CGFloat,g:CGFloat,b:CGFloat,a:CGFloat = 1) {
         self.init(
             red: r / 255.0,
             green: g / 255.0,
             blue: b / 255.0,
             alpha: a
         )
     }
 }

