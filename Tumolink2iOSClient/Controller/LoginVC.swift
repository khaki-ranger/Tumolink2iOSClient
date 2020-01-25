//
//  LoginVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/02.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    @IBAction func forgotPasswordClicked(_ sender: Any) {
        let vc = ForgotPasswordVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        guard let email = emailTxt.text, email.isNotEmpty,
            let password = passwordTxt.text, password.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Please fill out all fields.")
                return
        }
        
        activityIndicator.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                self.activityIndicator.stopAnimating()
                return
            }
            
            UserService.getCurrentUser(completion: { (error) in
                
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                
                self.presentHomeController()
            })
        }
    }
    
    @IBAction func guestClicked(_ sender: Any) {
        self.presentHomeController()
    }
    
    // ホーム画面のトップに遷移するためのメソッド
    fileprivate func presentHomeController() {
        let storyboard = UIStoryboard(name: Storyboard.Main, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.MainVC)
        present(controller, animated: true, completion: nil)
    }
}
