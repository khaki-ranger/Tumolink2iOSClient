//
//  SpotImageCell.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/13.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Kingfisher

class SpotImageCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var spotImage: UIImageView!

    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            let placeholder = UIImage(named: AppImages.Placeholder)
            let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            spotImage.kf.indicatorType = .activity
            spotImage.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
    }
}
