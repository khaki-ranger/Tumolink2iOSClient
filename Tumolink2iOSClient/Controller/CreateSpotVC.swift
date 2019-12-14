//
//  CreateSpotVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/14.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class CreateSpotVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var spotImg1: UIImageView!
    @IBOutlet weak var spotImg2: UIImageView!
    @IBOutlet weak var spotImg3: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Variables
    var tappedImageView: UIImageView?
    var name = ""
    // Firestoreにアップロードした画像のURLを格納する配列
    var imageUrls = [String]()

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(imgTapped1(_:)))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(imgTapped2(_:)))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(imgTapped3(_:)))
        tap1.numberOfTapsRequired = 1
        tap2.numberOfTapsRequired = 1
        tap3.numberOfTapsRequired = 1
        spotImg1.isUserInteractionEnabled = true
        spotImg2.isUserInteractionEnabled = true
        spotImg3.isUserInteractionEnabled = true
        spotImg1.addGestureRecognizer(tap1)
        spotImg2.addGestureRecognizer(tap2)
        spotImg3.addGestureRecognizer(tap3)
    }
    
    @objc func imgTapped1(_ tap: UITapGestureRecognizer) {
        tappedImageView = spotImg1
        launchImgPicker()
    }
    
    @objc func imgTapped2(_ tap: UITapGestureRecognizer) {
        tappedImageView = spotImg2
        launchImgPicker()
    }
    
    @objc func imgTapped3(_ tap: UITapGestureRecognizer) {
        tappedImageView = spotImg3
        launchImgPicker()
    }
    
    private func handleError(error: Error, msg: String) {
        debugPrint(error.localizedDescription)
        simpleAlert(title: "エラー", msg: msg)
        return
    }
    
    // MARK: Actions
    @IBAction func createClicked(_ sender: Any) {
    }
    
}

extension CreateSpotVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImgPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        if let spotImgView = tappedImageView {
            spotImgView.contentMode = .scaleAspectFill
            spotImgView.image = image
            uploadImage()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadImage() {
        // UIImageViewからimageを取得する
        guard let image = tappedImageView?.image else {
            simpleAlert(title: "エラー", msg: "画像の取得に失敗しました")
            return
        }
        
        activityIndicator.startAnimating()
        
        // 画像名を作成する
        let imageName = UUID()
        // 画像をデータに変更する
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        // Firestorageのリファレンスを作成する
        let imageRef = Storage.storage().reference().child("/spotImages/\(imageName).jpg")
        // メタデータを設定する
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        // データをFirestorageにアップロードする
        imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            
            if let error = error {
                self.activityIndicator.stopAnimating()
                self.handleError(error: error, msg: "画像のアップロードに失敗しました")
            }
            
            // アップロードが成功したらURLを取得する
            imageRef.downloadURL(completion: { (url, error) in
                
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.handleError(error: error, msg: "画像URLの取得に失敗しました")
                }
                // 画像のURLの取得に成功
                guard let url = url else { return }
                self.imageUrls.append(url.absoluteString)
                print("image upload success! : \(url)")
            })
        }
    }
}
