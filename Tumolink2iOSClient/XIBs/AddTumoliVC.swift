//
//  AddTumoliVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/28.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class AddTumoliVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var bgView: UIVisualEffectView!
    @IBOutlet weak var possibilityLbl: UILabel!
    @IBOutlet weak var possibilitySlider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addEditBtn: RoundedButton!
    @IBOutlet weak var deleteBtn: RoundedButton!
    
    // MARK: Variables
    var spot: Spot!
    var tumoliToEdit: Tumoli!
    var possibility = 50
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapGesture()
        setupSlider()
        
        // tumoliToEditがnilでない場合は編集
        if let tumoli = tumoliToEdit {
            setupEditMode(tumoli: tumoli)
        } else {
            deleteBtn.isHidden = true
        }
    }
    
    private func setupEditMode(tumoli: Tumoli) {
        addEditBtn.setTitle("変更", for: .normal)
        
        possibility = tumoli.possibility
        possibilityLbl.text = "\(possibility)%"
        possibilitySlider.setValue(Float(possibility) / 100, animated: false)
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAddTumoli))
        tap.numberOfTapsRequired = 1
        bgView.addGestureRecognizer(tap)
    }
    
    private func setupSlider() {
        possibilitySlider.minimumValue = 0.01
        possibilitySlider.addTarget(self, action: #selector(sliderDidChangeValue(_:)), for: .valueChanged)
    }
    
    @objc func sliderDidChangeValue(_ sender: UISlider) {
        possibility = Int(sender.value * 100)
        possibilityLbl.text = "\(possibility)%"
    }
    
    @objc func dismissAddTumoli() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        let alert = UIAlertController(title: "削除", message: "ツモリを削除しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.activityIndicator.startAnimating()
            self.changeIsActiveValue()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // FirestoreのisActiveの値を変更する処理
    private func changeIsActiveValue() {
        guard let tumoli = tumoliToEdit else { return }
        
        let docRef = Firestore.firestore().collection(FirestoreCollectionIds.Tumolis).document(tumoli.id)
        docRef.updateData(["isActive": false]) { (error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "ツモリの削除に失敗しました")
                return
            }
            
            // 遷移元のtumoliToEditプロパティをnilにする
            let naviVC = self.presentingViewController as! UINavigationController
            guard let prevVC = naviVC.viewControllers[naviVC.viewControllers.count - 1] as? SpotVC else {
                return
            }
            prevVC.tumoliToEdit = nil
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addTumoliClicked(_ sender: Any) {
        uploadDocument()
    }
    
    private func uploadDocument() {
        
        activityIndicator.startAnimating()
        
        var tumoli = Tumoli.init(id: "",
                                 userId: UserService.user.id,
                                 username: UserService.user.username,
                                 userImg: UserService.user.imageUrl,
                                 spotId: spot.id,
                                 possibility: possibility,
                                 isActive: true,
                                 date: Timestamp())
        
        var docRef: DocumentReference!
        // tumoliToEditがnilかどうかで、編集と新規作成の処理を分岐
        if let tumoliToEdit = tumoliToEdit {
            // 編集
            docRef = Firestore.firestore().collection(FirestoreCollectionIds.Tumolis).document(tumoliToEdit.id)
            tumoli.id = tumoliToEdit.id
        } else {
            // 新規作成
            docRef = Firestore.firestore().collection(FirestoreCollectionIds.Tumolis).document()
            tumoli.id = docRef.documentID
        }
        
        let data = Tumoli.modelToData(tumoli: tumoli)
        docRef.setData(data, merge: true) { (error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "データのアップロードに失敗しました")
                return
            }
            
            // 遷移元のaddTumoliBtnの位置と透明度を変更する
            let naviVC = self.presentingViewController as! UINavigationController
            guard let prevVC = naviVC.viewControllers[naviVC.viewControllers.count - 1] as? SpotVC else {
                return
            }
            prevVC.disappearTumoliBtn()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
