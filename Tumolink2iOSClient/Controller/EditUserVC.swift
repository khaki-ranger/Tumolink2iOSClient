//
//  EditUserVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/20.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Kingfisher

class EditUserVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Variables
    var profileImgChenged = false // 画像が変更されたかどうかをチェックするための変数

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    @IBAction func editClicked(_ sender: Any) {
        uploadImageThenDocument()
    }
    
    private func uploadImageThenDocument() {
        guard let image = profileImg.image ,
            let username = usernameTxt.text , username.isNotEmpty else {
                simpleAlert(title: "エラー", msg: "ユーザーネームとプロフィール画像が未設定です")
                return
        }
        
        activityIndicator.startAnimating()
        
        
        if profileImgChenged {
            // 画像が変更された場合はFirestorageにアップする
        } else {
            // 画像が変更されていないのでFirestoreのデータを更新する
            uploadDocument(url: UserService.user.imageUrl)
        }
    }
    
    private func uploadDocument(url: String) {
        
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
