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
    @IBOutlet weak var memberStatusLbl: UILabel!
    
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
        memberStatusLbl.text = spot.memberStatus.rawValue

        switch spot.memberStatus {
        case .owner:
            memberStatusLbl.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.3176470588, blue: 0.1176470588, alpha: 1)
        case .member:
            memberStatusLbl.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.9568627451, blue: 0.7411764706, alpha: 1)
        case .pending:
            memberStatusLbl.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.9607843137, blue: 0.737254902, alpha: 1)
            memberStatusLbl.textColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        case .unapplied:
            memberStatusLbl.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.537254902, blue: 0.4078431373, alpha: 1)
        }
        
        if let url = URL(string: spot.images[0]) {
            let placeholder = UIImage(named: AppImages.Placeholder)
            let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            spotImg.kf.indicatorType = .activity
            spotImg.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
    }
    
}
