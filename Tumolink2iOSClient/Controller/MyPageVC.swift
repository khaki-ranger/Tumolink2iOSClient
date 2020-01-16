//
//  myPageVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/18.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseAuth
import FirebaseFirestore

class MyPageVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var usernameTxt: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var logoutBtn: FullRoundedButton!
    @IBOutlet weak var userProfileView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Valiables
    var tumolis = [Tumoli]()
    var db: Firestore!
    var listener: ListenerRegistration!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        setupProfile()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupLoginBtn()
        setupProfile()
        setTumoliListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        tumolis.removeAll()
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupProfile() {
        activityIndicator.startAnimating()
        
        UserService.getCurrentUser { (error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "ユーザー情報の取得に失敗しました")
                return
            }
            
            if UserService.isGuest {
                self.usernameTxt.text = "匿名ユーザー"
                self.profileImg.image = UIImage(named: AppImages.NoProfile)
            } else {
                self.usernameTxt.text = UserService.user.username
                
                if let url = URL(string: UserService.user.imageUrl) {
                    let placeholder = UIImage(named: AppImages.Placeholder)
                    let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
                    self.profileImg.kf.indicatorType = .activity
                    self.profileImg.kf.setImage(with: url, placeholder: placeholder, options: options)
                }
            }
            
            self.activityIndicator.stopAnimating()
            self.appearProfileViewWithAnimasion()
        }
    }
    
    private func appearProfileViewWithAnimasion() {
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut], animations: {
            self.userProfileView.alpha = 1.0
        }, completion: nil)
    }
    
    private func setupLoginBtn() {
        if let user = Auth.auth().currentUser , !user.isAnonymous {
            logoutBtn.setTitle("ログアウト", for: .normal)
        }  else {
            logoutBtn.setTitle("ログイン", for: .normal)
        }
    }
    
    // ログインフローに遷移するためのメソッド
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
    // ツモ履歴を表示させるためのメソッド
    private func setTumoliListener() {
        let collectionRef = db.tumolis(userId: UserService.user.id)
        listener = collectionRef.addSnapshotListener({ (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "ツモリのデータの取得に失敗しました")
                return
            }
            
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let tumoli = Tumoli.init(data: data)
                
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, tumoli: tumoli)
                case .modified:
                    self.onDocumentModified(change: change, tumoli: tumoli)
                case .removed:
                    self.onDocumentRemoved(change: change)
                @unknown default:
                    return
                }
            })
        })
    }
    
    // MARK: Actions
    @IBAction func logoutClicked(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        if user.isAnonymous {
            presentLoginController()
        } else {
            do {
                try Auth.auth().signOut()
                UserService.logoutUser()
                Auth.auth().signInAnonymously { (result, error) in
                    if let error = error {
                        debugPrint(error)
                        Auth.auth().handleFireAuthError(error: error, vc: self)
                    }
                    self.presentLoginController()
                }
            } catch {
                debugPrint(error)
                Auth.auth().handleFireAuthError(error: error, vc: self)
            }
        }
    }
    
}

extension MyPageVC : UITableViewDelegate, UITableViewDataSource {
    
    // データベースの変更に対して実行されるメソッド - begin
    private func onDocumentAdded(change: DocumentChange, tumoli: Tumoli) {
        let newIndex = Int(change.newIndex)
        tumolis.insert(tumoli, at: newIndex)
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .fade)
    }
    
    private func onDocumentModified(change: DocumentChange, tumoli: Tumoli) {
        if change.newIndex == change.oldIndex {
            // Row change, but remained in the same position
            let index = Int(change.newIndex)
            tumolis[index] = tumoli
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            // Row changed and changed position
            let newIndex = Int(change.newIndex)
            let oldIndex = Int(change.oldIndex)
            tumolis.remove(at: oldIndex)
            tumolis.insert(tumoli, at: newIndex)
            tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
            tableView.reloadRows(at: [IndexPath(row: newIndex, section: 0)], with: .none)
        }
    }
    
    private func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        tumolis.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: .left)
    }
    // データベースの変更に対して実行されるメソッド - end
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tumolis.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.TumorirekiCell, for: indexPath) as? TumorirekiCell else { return UITableViewCell() }
        cell.configureCell(tumoli: tumolis[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
