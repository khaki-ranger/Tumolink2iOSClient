//
//  RequestDetailVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/12.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class RequestDetailVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var profileImg: CircleImageView!
    @IBOutlet weak var usernameLbl: UILabel!
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
        navigationItem.title = "メンバー申請"
        
        // 未読の場合は既読に変更する
        activityIndicator.startAnimating()
        if information.isRead == false {
            changeIsRead()
        } else {
            getUserDocument()
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
            
            self.getUserDocument()
        }
    }
    
    private func getUserDocument() {
        let docRef = db.collection(FirestoreCollectionIds.Users).document(information.from)
        docRef.getDocument { (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "データの取得に失敗しました")
                return
            }
            
            guard let data = snap?.data() else { return }
            let user = User.init(data: data)
            
            self.usernameLbl.text = user.username
            
            if let url = URL(string: user.imageUrl) {
                let placeholder = UIImage(named: AppImages.Placeholder)
                let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
                self.profileImg.kf.indicatorType = .activity
                self.profileImg.kf.setImage(with: url, placeholder: placeholder, options: options)
            }
            
            self.getSpotDocument(user: user)
        }
    }
    
    private func getSpotDocument(user: User) {
        let docRef = db.collection(FirestoreCollectionIds.Spots).document(information.spotId)
        docRef.getDocument { (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "データの取得に失敗しました")
                return
            }
            
            guard let data = snap?.data() else { return }
            let spot = Spot.init(data: data)
            
            let description = "\(user.username)さんから、\(spot.name)への\nメンバー申請が来ました！"
            
            self.descriptionLbl.attributedText = NSAttributedString(string: description, lineSpacing: 12.0, alignment: .center)
            
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
    @IBAction func permitClicked(_ sender: Any) {
    }
    
}
