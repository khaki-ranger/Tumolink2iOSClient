//
//  RegisterVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/02.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passCheckImg: UIImageView!
    @IBOutlet weak var confirmPassCheckImg: UIImageView!
    
    // MARK: Variables
    var email: String = ""
    var username: String = ""
    var password: String = ""
    var userImgUrl: String = ""
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapgesture()
        setupPasswordCheck()
    }
    
    private func setupTapgesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
        tap.numberOfTapsRequired = 1
        userImg.isUserInteractionEnabled = true
        userImg.addGestureRecognizer(tap)
    }
    
    @objc func imgTapped(_ tap: UITapGestureRecognizer) {
        launchImgPicker()
    }
    
    private func setupPasswordCheck() {
        passwordTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        confirmPasswordTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let passTxt = passwordTxt.text else { return }
        
        // 確認用パスワードが入力されたらチェックマークを表示する
        if textField == confirmPasswordTxt {
            passCheckImg.isHidden = false
            confirmPassCheckImg.isHidden = false
        } else {
            if passTxt.isEmpty {
                passCheckImg.isHidden = true
                confirmPassCheckImg.isHidden = true
                confirmPasswordTxt.text = ""
            }
        }
        
        // パスワードと確認用パスワードが一致していたら、チェックマークの色をグリーンに変える
        if passwordTxt.text == confirmPasswordTxt.text {
            passCheckImg.image = UIImage(named: AppImages.GreenCheck)
            confirmPassCheckImg.image = UIImage(named: AppImages.GreenCheck)
        } else {
            passCheckImg.image = UIImage(named: AppImages.RedCheck)
            confirmPassCheckImg.image = UIImage(named: AppImages.RedCheck)
        }
    }
    
    // MARK: Actions
    @IBAction func registerClicked(_ sender: Any) {
        guard let email = emailTxt.text, email.isNotEmpty,
            let username = usernameTxt.text, username.isNotEmpty,
            let password = passwordTxt.text, password.isNotEmpty else {
                simpleAlert(title: "Error", msg: "Please fill out all fields.")
                return
        }
        
        guard let confirmPassword = confirmPasswordTxt.text, confirmPassword == password else {
            simpleAlert(title: "Error", msg: "Passwords do not match.")
            return
        }
        
        self.email = email
        self.username = username
        self.password = password
        
        activityIndicator.startAnimating()
        
        if let userImg = userImg.image {
            uploadImageThenDocument(image: userImg)
        } else {
            userImgUrl = ""
            uploadDocument()
        }
    }
    
    private func uploadImageThenDocument(image: UIImage) {
        // 画像名を作成する
        let imageName = UUID()
        // 画像をデータに変更する
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        // Firestoreのリファレンスを作成する
        let imageRef = Storage.storage().reference().child("/userImages/\(imageName).jpg")
        // メタデータを設定する
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        // データをFirestorageにアップロードする
        imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "画像のアップロードに失敗しました")
                return
            }
            // 画像のアップロードに成功したらURLを取得する
            imageRef.downloadURL(completion: { (url, error) in
                
                if let error = error {
                    debugPrint(error.localizedDescription)
                    self.simpleAlert(title: "エラー", msg: "画像URLの取得に失敗しました")
                    return
                }
                
                // 画像URLの取得に成功
                guard let url = url else { return }
                // FirestoreのcategoriesコレクションにURLをアップロードして更新、および作成する
                self.uploadDocument()
                self.userImgUrl = url.absoluteString
            })
        }
    }
    
    private func uploadDocument() {
        guard let authUser = Auth.auth().currentUser else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        authUser.link(with: credential) { (result, error) in
            if let error = error {
                debugPrint(error)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                self.activityIndicator.stopAnimating()
                return
            }
            
            // アプリ内でユーザーを管理するためのオブジェクトを作成
            guard let firUser = result?.user else { return }
            let appUser = User.init(id: firUser.uid,
                                    email: self.email,
                                    username: self.username,
                                    imageUrl: self.userImgUrl,
                                    hasSetupAccount: true,
                                    isActive: true)
            self.createFirestoreUser(user: appUser)
        }
    }
    
    // FirestoreのUsersコレクションにユーザーのデータを作成するためのメソッド
    func createFirestoreUser(user: User) {
        let newUserRef = Firestore.firestore().collection(FirestoreCollectionIds.Users).document(user.id)
        let data = User.modelToData(user: user)
        newUserRef.setData(data) { (error) in
            if let error = error {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                debugPrint(error.localizedDescription)
            } else {
                UserService.getCurrentUser(completion: { (erorr) in
                    
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        return
                    }
                    
                    self.presentHomeController()
                })
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    // ホーム画面のトップに遷移するためのメソッド
    fileprivate func presentHomeController() {
        let storyboard = UIStoryboard(name: Storyboard.Main, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.MainVC)
        present(controller, animated: true, completion: nil)
    }
}

extension RegisterVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImgPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        userImg.contentMode = .scaleAspectFill
        userImg.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
