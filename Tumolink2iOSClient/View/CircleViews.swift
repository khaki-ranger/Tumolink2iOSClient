//
//  CircleViews.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/22.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        let image = self.image
        self.image = image
    }
    
    override var image: UIImage? {
        get { return super.image }
        set {
            self.contentMode = .scaleAspectFit
            super.image = newValue?.roundImage()
        }
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2.0
    }
}

extension UIImage {
    func roundImage() -> UIImage {
        let minLength: CGFloat = min(self.size.width, self.size.height)
        let rectangleSize: CGSize = CGSize(width: minLength, height: minLength)
        UIGraphicsBeginImageContextWithOptions(rectangleSize, false, 0.0)
        
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: rectangleSize), cornerRadius: minLength).addClip()
        self.draw(in: CGRect(origin: CGPoint(x: (minLength - self.size.width) / 2, y: (minLength - self.size.height) / 2), size: self.size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

class OwnerIconView: CircleImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 3
    }
}

class MypageProfileView: CircleImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 5
    }
}

class CircleShadowButtonView : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = self.frame.height / 2.0
        layer.shadowColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
    }
}
