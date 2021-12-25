//
//  QRViewController.swift
//  etico
//
//  Created by Daniel Torres on 24/12/21.
//

import UIKit

class QRViewController: UIViewController {

    var email: String?
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var card: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.5
        card.layer.shadowOffset = .init(width: 6, height: 6)
        card.layer.shadowRadius = 20

        if let email = email {
            qrImage.image = generateQRCode(from: email)
        }
    }
    

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

}
