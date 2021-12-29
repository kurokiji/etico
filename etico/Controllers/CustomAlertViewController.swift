//
//  CustomAlertView.swift
//  etico
//
//  Created by Daniel Torres on 24/12/21.
//

import Foundation
import UIKit

class CustomAlertViewController: UIViewController {
    
    // MARK: - Variables
    var customTitle: String?
    var message: String?
    var image: UIImage?
    var color: UIColor?
    var callBack: (()-> Void)?
    
    // MARK: - Outlets
    @IBOutlet weak var alertViewCard: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextViewHC: NSLayoutConstraint!
    @IBOutlet weak var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Dark mode configuration
        switch traitCollection.userInterfaceStyle {
               case .light, .unspecified:
            print("light")
               case .dark:
            alertViewCard.backgroundColor = Constants.customGrey
        }
        
        // MARK: - View configuration
        alertViewCard.layer.cornerRadius = 20
        alertViewCard.layer.shadowColor = UIColor.black.cgColor
        alertViewCard.layer.shadowOpacity = 0.5
        alertViewCard.layer.shadowOffset = .init(width: 6, height: 6)
        alertViewCard.layer.shadowRadius = 20
        changeValues()
        messageTextViewHC.constant = self.messageTextView.contentSize.height
    }
    
    // MARK: - Buttons functions
    @IBAction func dismiss(_ sender: Any) {
        if let callBack = callBack {
            callBack()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Supporting Functions
    func changeValues(){
        if let title = customTitle {
            titleLabel.text = title
        }
        if let message = message {
            let messageOneLine = message.components(separatedBy: ", ")
            var messageString = ""
            for line in messageOneLine {
                messageString += "\(line)\n"
            }
            messageTextView.text = messageString
        }
        if let image = image {
            imageView.image = image
        }
        if let color = color {
            imageView.tintColor = color
            titleLabel.textColor = color
        }
    }
}
