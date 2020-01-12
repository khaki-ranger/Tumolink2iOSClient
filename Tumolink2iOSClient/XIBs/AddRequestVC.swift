//
//  AddRequestVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/11.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AddRequestVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var bgView: UIVisualEffectView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Valiables
    var spot: Spot!
    var db: Firestore!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAddRequest))
        tap.numberOfTapsRequired = 1
        bgView.addGestureRecognizer(tap)
    }

    @objc func dismissAddRequest() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: Actions
    @IBAction func closeClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func requestClicked(_ sender: Any) {
        activityIndicator.startAnimating()
        
        let title = "メンバー申請"
        let description = "\(UserService.user.username)さんから、\(spot.name)にメンバー申請が来ました。"
        
        // オーナーにInformationを作成する処理
        var information = Information.init(id: "",
                                           infoType: .request,
                                           title: title,
                                           description: description,
                                           from: UserService.user.id,
                                           spotId: spot.id)
        
        let docRef = db.collection(FirestoreCollectionIds.Users).document(spot.owner).collection(FirestoreCollectionIds.Informations).document()
        information.id = docRef.documentID
        
        let data = Information.modelToData(information: information)
        docRef.setData(data) { (error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "リクエストの送信に失敗しました")
                return
            }
            
            // スポットのpending配列にログインユーザーのidを追加する処理
            self.addUserToPendingArray()
        }
    }
    
    private func addUserToPendingArray() {
        let docRef = db.collection(FirestoreCollectionIds.Spots).document(spot.id)
        docRef.updateData([FirestoreArrayIds.Pending: FieldValue.arrayUnion([UserService.user.id])]) { (error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "リクエストの送信に失敗しました")
                return
            }
            
            // 完了後の処理
            self.activityIndicator.stopAnimating()
            self.completionAlert()
        }
    }
    
    private func completionAlert() {
        let alert = UIAlertController(title: "申請完了！", message: "\(spot.name)のオーナーが申請を許可するまでお待ちください。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
