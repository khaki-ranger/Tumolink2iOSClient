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
    @IBOutlet weak var addEditBtn: RoundedButton!
    
    // MARK: Variables
    var db: Firestore!
    var spotToEdit: Spot?
    var imageUrls = [String]()
    var spotImageViews: [UIImageView] = []
    var tapGestures = [UITapGestureRecognizer]()

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        spotImageViews = [
            spotImg1,
            spotImg2,
            spotImg3
        ]
        
        // spotToEditがnilでない場合は編集
        if let spot = spotToEdit {
            setupEditMode(spot: spot)
        }
        
        setupTapGesture()
    }
    
    private func setupEditMode(spot: Spot) {
        addEditBtn.setTitle("編集", for: .normal)
        
        nameTxt.text = spot.name
        // 画像をセットアップ
        var count = 0
        while count < spot.images.count && count < spotImageViews.count {
            imageUrls.append(spot.images[count])
            if let url = URL(string: spot.images[count]) {
                spotImageViews[count].contentMode = .scaleAspectFill
                spotImageViews[count].kf.setImage(with: url)
            }
            count += 1
        }
    }
    
    private func setupTapGesture() {
        for spotImageview in spotImageViews {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
            tapGesture.numberOfTapsRequired = 1
            spotImageview.isUserInteractionEnabled = true
            spotImageview.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func imgTapped(_ tap: UITapGestureRecognizer) {
        if imageUrls.count < 3 {
            launchImgPicker()
        } else {
            simpleAlert(title: "エラー", msg: "設定できる画像の枚数は3枚までです。\n追加するには画像を削除してください。")
        }
    }
    
    private func handleError(error: Error, msg: String) {
        debugPrint(error.localizedDescription)
        simpleAlert(title: "エラー", msg: msg)
        return
    }
    
    // MARK: Actions
    @IBAction func removeImg1Clicked(_ sender: Any) {
        if imageUrls.count > 0 {
            imageUrls.remove(at: 0)
            resetSpotImageViews()
        }
    }
    
    @IBAction func removeImg2Clicked(_ sender: Any) {
        if imageUrls.count > 1 {
            imageUrls.remove(at: 1)
            resetSpotImageViews()
        }
    }
    
    @IBAction func removeImg3Clicked(_ sender: Any) {
        if imageUrls.count > 2 {
            imageUrls.remove(at: 2)
            resetSpotImageViews()
        }
    }
    
    private func resetSpotImageViews() {
        var count = 0
        while count < 3 {
            if count < imageUrls.count {
                if let url = URL(string: imageUrls[count]) {
                    spotImageViews[count].kf.setImage(with: url)
                }
            } else {
                spotImageViews[count].image = UIImage(named: AppImages.Placeholder)
            }
            count += 1
        }
    }
    
    @IBAction func createClicked(_ sender: Any) {
        uploadDocument()
    }
    
    private func uploadDocument() {
        guard let spotName = nameTxt.text , spotName.isNotEmpty else {
            simpleAlert(title: "エラー", msg: "スポットの名前を入力してください")
            return
        }
        
        guard imageUrls.count > 0 else {
            simpleAlert(title: "エラー", msg: "画像を1枚以上設定してください")
            return
        }
        
        activityIndicator.startAnimating()
        
        var spot = Spot.init(id: "",
                             name: spotName,
                             owner: UserService.user.id,
                             images: imageUrls,
                             members: [String](),
                             pending: [String]())
        
        var docRef: DocumentReference!
        // productToEditがnilかどうかで、編集と新規作成の処理を分岐
        if let spotToEdit = spotToEdit {
            // 編集
            docRef = db.collection(FirestoreCollectionIds.Spots).document(spotToEdit.id)
            spot.id = spotToEdit.id
            spot.members = spotToEdit.members
            spot.pending = spotToEdit.pending
        } else {
            // 新規作成
            docRef = db.collection(FirestoreCollectionIds.Spots).document()
            spot.id = docRef.documentID
        }
        
        let data = Spot.modelToData(spot: spot)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                self.handleError(error: error, msg: "データのアップロードに失敗しました")
            }
            
            if self.spotToEdit == nil {
                // 新規作成の場合は、UserドキュメントのmySpots配列にspotIdを追加する
                self.addSpotIdToMySpotsArray(spot: spot)
            } else {
                // 編集の場合は、tumolisのデータを変更する
                self.updateTumoliDocuments(spot: spot)
            }
        }
    }
    
    // ログインユーザーのUserドキュメントのspots配列にspotIdを追加
    private func addSpotIdToMySpotsArray(spot: Spot) {
        let docRef = db.collection(FirestoreCollectionIds.Users).document(UserService.user.id)
        docRef.updateData([FirestoreArrayIds.MySpots : FieldValue.arrayUnion([spot.id])]) { (error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "マイスポットの登録に失敗しました")
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateTumoliDocuments(spot: Spot) {
        let collectionRef = db.tumolis(spotId: spot.id)
        collectionRef.getDocuments { (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let documents = snap?.documents else { return }
            
            for document in documents {
                document.reference.updateData([
                    "spotname" : spot.name,
                    "spotImg" : spot.images[0]
                ]) { (error) in
                    
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        return
                    }
                }
            }
            
            self.presentHomeController()
        }
    }
    
    // ホーム画面のトップに遷移するためのメソッド
    fileprivate func presentHomeController() {
        let storyboard = UIStoryboard(name: Storyboard.Main, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.MainVC)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        let index = imageUrls.count
        if index < 3 {
            let spotImage = spotImageViews[index]
            spotImage.image = image
            spotImage.contentMode = .scaleAspectFit
            uploadImage(index: index, image: image)
        } else {
            // 画像の枚数が超過していることを知らせる
            simpleAlert(title: "エラー", msg: "設定できる画像の枚数は3枚までです")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadImage(index: Int?, image: UIImage) {
        activityIndicator.startAnimating()
        
        // 画像名を作成する
        let imageName = UUID()
        // 画像をデータに変更する
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        // Firestorageのリファレンスを作成する
        let imageRef = Storage.storage().reference().child("/\(FirestorageDirectories.SpotImages)/\(imageName).jpg")
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
                if let index = index {
                    self.imageUrls.insert(url.absoluteString, at: index)
                    print("image upload success!\nurl : \(url)\nindex : \(index)")
                }
            })
        }
    }
}
