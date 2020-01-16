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
    @IBOutlet weak var userProfileView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupLoginBtn()
        setupProfile()
    }
    
    private func setupProfile() {
        activityIndicator.startAnimating()
        
        UserService.getCurrentUser { (error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "ユーザー情報の取得に失敗しました")
                return
            }
            
            if UserService.isGuest {
                self.usernameTxt.text = "匿名ユーザー"
                self.profileImg.image = UIImage(named: AppImages.NoProfile)
            } else {
                self.usernameTxt.text = UserService.user.username
                
                if let url = URL(string: UserService.user.imageUrl) {
                    let placeholder = UIImage(named: AppImages.Placeholder)
                    let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
                    self.profileImg.kf.indicatorType = .activity
                    self.profileImg.kf.setImage(with: url, placeholder: placeholder, options: options)
                }
            }
            
            self.activityIndicator.stopAnimating()
            self.appearProfileViewWithAnimasion()
        }
    }
    
    private func appearProfileViewWithAnimasion() {
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut], animations: {
            self.userProfileView.alpha = 1.0
        }, completion: nil)
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
