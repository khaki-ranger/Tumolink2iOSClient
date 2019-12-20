//
//  myPageVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/18.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Kingfisher

class MyPageVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var usernameTxt: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupProfile()
    }
    
    private func setupProfile() {
        if UserService.isGuest {
            usernameTxt.text = "匿名ユーザー"
            profileImg.image = UIImage(named: AppImages.NoProfile)
        } else {
            usernameTxt.text = UserService.user.username
            
            if let url = URL(string: UserService.user.imageUrl) {
                let placeholder = UIImage(named: AppImages.Placeholder)
                let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
                profileImg.kf.indicatorType = .activity
                profileImg.kf.setImage(with: url, placeholder: placeholder, options: options)
            }
        }
    }
    
    // MARK: Actions

}
