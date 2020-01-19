//
//  SettingsVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/19.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var logoutBtn: UIButton!
    
    // MARK: Valiables
    
    // MARK: functions
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLoginBtn()
    }
    
    private func setupLoginBtn() {
        if let user = Auth.auth().currentUser , !user.isAnonymous {
            logoutBtn.setTitle("ログアウト", for: .normal)
        }  else {
            logoutBtn.setTitle("ログイン", for: .normal)
        }
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
    
    // ログインフローに遷移するためのメソッド
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func returnClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
