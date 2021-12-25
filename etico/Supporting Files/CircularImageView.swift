//
//  CircularImageView.swift
//  etico
//
//  Created by Daniel Torres on 25/12/21.
//

import Foundation
import UIKit

class CircularImageView: UIImageView {
    override func layoutSubviews(){
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}
