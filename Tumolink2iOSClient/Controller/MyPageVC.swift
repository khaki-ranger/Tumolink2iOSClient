//
//  myPageVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/18.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseAuth

class MyPageVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var usernameTxt: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var logoutBtn: FullRoundedButton!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupLoginBtn()
        if let username = usernameTxt.text {
            if username != UserService.user.username {
                setupProfile()
            }
        }
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
    
    private func setupLoginBtn() {
        if let user = Auth.auth().currentUser , !user.isAnonymous {
            logoutBtn.setTitle("ログアウト", for: .normal)
        }  else {
            logoutBtn.setTitle("ログイン", for: .normal)
        }
    }
    
    // ログインフローに遷移するためのメソッド
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func logoutClicked(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        if user.isAnonymous {
            presentLoginController()
        } else {
            do {
                try Auth.auth().signOut()
                UserService.logoutUser()
                Auth.auth().signInAnonymously { (result, error) in
                    if let error = error {
                        debugPrint(error)
                        Auth.auth().handleFireAuthError(error: error, vc: self)
                    }
                    self.presentLoginController()
                }
            } catch {
                debugPrint(error)
                Auth.auth().handleFireAuthError(error: error, vc: self)
            }
        }
    }
    
}
