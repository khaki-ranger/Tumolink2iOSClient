//
//  ViewController.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/11/29.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Firebase

class HomeVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var loginOutBtn: UIButton!
    @IBOutlet weak var AuthUserTxt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // アプリ起動時にログインしていなかった場合は、
        // Annonymousユーザーとしてログインする
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { (result, error) in
                if let error = error {
                    debugPrint(error)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ログインしているかどうかを判定
        if let user = Auth.auth().currentUser , !user.isAnonymous {
            if let email = user.email {
                AuthUserTxt.text = "\(email)としてログイン中"
            }
            loginOutBtn.setTitle("ログアウト", for: .normal)
        } else if let user = Auth.auth().currentUser, user.isAnonymous {
            AuthUserTxt.text = "匿名ユーザーとしてログイン中"
        } else {
            loginOutBtn.setTitle("ログイン", for: .normal)
            AuthUserTxt.text = "ログインしていません"
        }
    }
    
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func loginOutClicked(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        if user.isAnonymous {
            presentLoginController()
        } else {
            do {
                try Auth.auth().signOut()
                Auth.auth().signInAnonymously { (result, error) in
                    if let error = error {
                        debugPrint(error)
                    }
                    self.presentLoginController()
                }
            } catch {
                debugPrint(error)
                
            }
        }
    }
}

