//
//  ManageSpotVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/16.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ManageSpotVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var spotNameLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Valiables
    var spot: Spot!
    var isOwner = false
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "スポット管理"
        // ログイン中のユーザーがこのスポットのオーナーかどうかを判定
        if spot.owner == UserService.user.id {
            isOwner = true
        }
        spotNameLbl.text = spot.name
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ToEditSpot {
            if let destination = segue.destination as? CreateSpotVC {
                destination.spotToEdit = spot
            }
        }
    }
    
    // MARK: Actions
    @IBAction func manageMemberClicked(_ sender: Any) {
    }
    
    @IBAction func editSpotClicked(_ sender: Any) {
        if isOwner {
            performSegue(withIdentifier: Segues.ToEditSpot, sender: self)
        } else {
            simpleAlert(title: "エラー", msg: "オーナーだけがスポットの管理が可能です")
        }
    }
    
    @IBAction func deleteSpotClicked(_ sender: Any) {
        confirmDeleteSpot()
    }
    
    private func confirmDeleteSpot() {
        let alert = UIAlertController(title: "削除", message: "\(spot.name)を削除しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.activityIndicator.startAnimating()
            self.changeIsActionValue()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // FirestoreのスポットのisActiveフィールドを変更する処理
    private func changeIsActionValue() {
        if isOwner {
            let docRef = Firestore.firestore().collection(FirestoreCollectionIds.Spots).document(self.spot.id)
            docRef.updateData(["isActive": false], completion: { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    self.simpleAlert(title: "エラー", msg: "スポットの削除に失敗しました")
                    return
                }
                // 値の更新に成功したらホームのトップ画面に遷移する
                self.navigationController?.popToRootViewController(animated: true)
            })
        } else {
            simpleAlert(title: "エラー", msg: "オーナーだけがスポットの削除が可能です")
        }
    }
}
