//
//  DeleteUserVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/22.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Firebase

class DeleteUserVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Valiables

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: Actions
    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        let alert = UIAlertController(title: "退会", message: "本当に退会しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.unsubscribeUser()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // ユーザーのデータを変更して利用停止にする処理
    private func unsubscribeUser() {
        
        guard let email = emailTxt.text , email.isNotEmpty,
            let password = passwordTxt.text , password.isNotEmpty else {
                simpleAlert(title: "エラー", msg: "メールアドレスとパスワードを入力してください")
                return
        }
        
        activityIndicator.startAnimating()
        
        // ユーザーを再認証する
        guard let authUser = Auth.auth().currentUser else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        authUser.reauthenticate(with: credential) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                return
            }
            // FirestoreのisActiveパラメータの値をfalseに変更する
            self.changeIsActionValue(uid: authUser.uid)
        }
    }
    
    // FirestoreのisActiveパラメータの値をfalseに変更するためのメソッド
    private func changeIsActionValue(uid: String) {
        let docRef = Firestore.firestore().collection(FirestoreCollectionIds.Users).document(UserService.user.id)
        docRef.updateData(["isActive": false], completion: { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "退会処理に失敗しました")
                self.activityIndicator.stopAnimating()
                return
            }
            // FirebaseAuthのユーザーアカウントを削除する
            self.deleteUser()
        })
    }
    
    private func deleteUser() {
        guard let authUser = Auth.auth().currentUser else { return }
        authUser.delete { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                self.activityIndicator.stopAnimating()
                return
            }
            
            // シングルトンオブジェクトを初期化する
            UserService.logoutUser()
            
            // 匿名ユーザーでサインインする
            Auth.auth().signInAnonymously { (result, error) in
                if let error = error {
                    debugPrint(error)
                    Auth.auth().handleFireAuthError(error: error, vc: self)
                }
                // ログイン画面に遷移する
                self.presentLoginController()
            }
        }
    }
    
    // ログインフローに遷移するためのメソッド
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(controller, animated: true, completion: nil)
    }
}
