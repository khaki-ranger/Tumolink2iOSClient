//
//  TumoliCell.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/25.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class TumoliCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var profileImg: CircleImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var possibilityLbl: UILabel!
    @IBOutlet weak var fullroundedShadowView: FullRoundedShadowView!
    
    // MARK: Variables

    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(tumoli: Tumoli) {
        usernameLbl.text = tumoli.username
        possibilityLbl.text = String(tumoli.possibility)
        if let url = URL(string: tumoli.userImg) {
            let placeholder = UIImage(named: AppImages.Placeholder)
            let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            self.profileImg.kf.indicatorType = .activity
            self.profileImg.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
        
        // ログインユーザーはセルの背景色を変える
        if tumoli.userId == UserService.user.id {
            fullroundedShadowView.backgroundColor = #colorLiteral(red: 1, green: 0.6705882353, blue: 0.568627451, alpha: 1)
        }
    }
    
    // MARK: Actions
    
}
