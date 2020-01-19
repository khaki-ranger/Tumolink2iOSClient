//
//  EditUserVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/20.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class EditUserVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Variables
    var db: Firestore!
    var profileImgChenged = false // 画像が変更されたかどうかをチェックするための変数
    var username: String = ""

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        setupProfile()
        setupTapGesture()
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
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
        tap.numberOfTapsRequired = 1
        profileImg.isUserInteractionEnabled = true
        profileImg.addGestureRecognizer(tap)
    }
    
    @objc func imgTapped(_ tap: UITapGestureRecognizer) {
        launchImgPicker()
    }
    
    // MARK: Actions
    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func editClicked(_ sender: Any) {
        guard let image = profileImg.image ,
            let username = usernameTxt.text , username.isNotEmpty else {
                simpleAlert(title: "エラー", msg: "ユーザーネームとプロフィール画像が未設定です")
                return
        }
        
        self.username = username
        
        activityIndicator.startAnimating()
        
        // 画像が変更されたかどうかで処理を分岐する
        if profileImgChenged {
            // 画像が変更された場合はFirestorageにアップする
            uploadImage(image: image)
        } else {
            // 画像が変更されていないのでFirestoreのデータを更新する
            uploadDocument(url: UserService.user.imageUrl)
        }
    }
    
    private func uploadImage(image: UIImage) {
        // 画像名を作成する
        let imageName = UUID()
        // 画像をデータに変更する
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        // Firestoreのリファレンスを作成する
        let imageRef = Storage.storage().reference().child("/userImages/\(imageName).jpg")
        // メタデータを設定する
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
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
                self.uploadDocument(url: url.absoluteString)
            })
        }
    }
    
    private func uploadDocument(url: String) {
        
        let user = User.init(id: UserService.user.id,
                                email: UserService.user.email,
                                username: username,
                                imageUrl: url,
                                mySpots: UserService.user.mySpots)
        
        let docRef = db.collection(FirestoreCollectionIds.Users).document(UserService.user.id)
        let data = User.modelToData(user: user)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "データのアップロードに失敗しました")
                return
            }
            
            // ツモリのデータも変更する
            self.updateTumoliDocuments(imageUrl: url)
        }
    }
    
    private func updateTumoliDocuments(imageUrl: String) {
        let ref = db.tumolis(userId: UserService.user.id)
        ref.getDocuments { (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let documents = snap?.documents else { return }
            
            for document in documents {
                document.reference.updateData([
                    "username" : self.username,
                    "userImg" : imageUrl
                    ]) { (error) in
                    
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        return
                    }
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension EditUserVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImgPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        profileImg.contentMode = .scaleAspectFill
        profileImg.image = image
        profileImgChenged = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
