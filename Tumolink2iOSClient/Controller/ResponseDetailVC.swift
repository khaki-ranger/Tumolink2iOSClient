//
//  ResponseDetailVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/14.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class ResponseDetailVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var spotImg: RoundedImageView!
    @IBOutlet weak var spotnameLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Valiables
    var information: Information!
    var db: Firestore!
    var isRead = false
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        navigationItem.title = "メンバー申請許可"
        
        // 未読の場合は既読に変更する
        activityIndicator.startAnimating()
        if information.isRead == false {
            changeIsRead()
        } else {
            getSpotDocument()
        }
    }
    
    private func changeIsRead() {
        let docRef = db.collection(FirestoreCollectionIds.Users).document(UserService.user.id).collection(FirestoreCollectionIds.Informations).document(information.id)
        docRef.updateData(["isRead": true]) { (error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "お知らせの開封に失敗しました")
                return
            }
            
            self.getSpotDocument()
        }
    }
    
    private func getSpotDocument() {
        let docRef = db.collection(FirestoreCollectionIds.Spots).document(information.spotId)
        docRef.getDocument { (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "データの取得に失敗しました")
                return
            }
            
            guard let data = snap?.data() else { return }
            let spot = Spot.init(data: data)
            
            self.spotnameLbl.text = spot.name
            
            if let url = URL(string: spot.images[0]) {
                let placeholder = UIImage(named: AppImages.Placeholder)
                let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
                self.spotImg.kf.indicatorType = .activity
                self.spotImg.kf.setImage(with: url, placeholder: placeholder, options: options)
            }
            
            let description = "\(spot.name)のメンバーになりました！"
            self.descriptionLbl.attributedText = NSAttributedString(string: description, lineSpacing: 12.0, alignment: .center)
            
            self.activityIndicator.stopAnimating()
            self.appearViewWithAnimasion()
        }
    }
    
    private func appearViewWithAnimasion() {
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut], animations: {
            self.informationView.alpha = 1.0
        }, completion: nil)
    }
    
    private func disappearView() {
        informationView.alpha = 0.0
    }
    
    // MARK: Actions

}
