//
//  ForgotPasswordVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/11.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var emailTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: Actions
    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetClicked(_ sender: Any) {
        guard let email = emailTxt.text else {
            simpleAlert(title: "エラー", msg: "メールアドレスを入力してください")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.handleFireAuthError(error: error)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
