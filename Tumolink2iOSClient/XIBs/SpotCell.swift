//
//  SpotCell.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/12.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Kingfisher

class SpotCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var spotImg: UIImageView!
    @IBOutlet weak var spotName: UILabel!

    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(spot: Spot) {
        spotName.text = spot.name
        if let url = URL(string: spot.images[0]) {
            spotImg.kf.setImage(with: url)
        }
    }
    
}
