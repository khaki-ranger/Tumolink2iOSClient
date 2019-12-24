//
//  RoundedViews.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/03.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit

class RoundedButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
    }
}

class RoundedShadowView : UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        layer.shadowColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
    }
}

class FullRoundedShadowView : RoundedShadowView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = self.frame.height / 2.0
    }
}

class RoundedImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
    }
}

class RoundedTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
    }
}
