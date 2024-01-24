//
//  RectangleLayer.swift
//  CameraView
//
//  Created by Agung Dwi Saputra on 24/01/24.
//

import Foundation
import UIKit


class RectangleLayer: CALayer {
    
    // Customize properties as needed
    
    override init() {
        super.init()
        setupLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    private func setupLayer() {
        bounds = CGRect(x: 0, y: 0, width: 300, height: 200)
        borderColor = UIColor.systemBlue.cgColor
        borderWidth = 1
    }
}
