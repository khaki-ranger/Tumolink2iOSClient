//
//  ViewController.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/11/29.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Firebase

class HomeVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var loginBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    var spots = [Spot]()
    var db: Firestore!
    var listener: ListenerRegistration!
    var selectedSpot: Spot!
    
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserService.getCurrentUser()
        setupInitialAnonymouseUser()
        db = Firestore.firestore()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupLoginBtn()
        setSpotsListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        spots.removeAll()
        tableView.reloadData()
    }
    
    private func setupInitialAnonymouseUser() {
        // アプリ起動時にログインしていなかった場合は、
        // Annonymousユーザーとしてログインする
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { (result, error) in
                if let error = error {
                    debugPrint(error)
                    Auth.auth().handleFireAuthError(error: error, vc: self)
                }
            }
        }
    }
    
    private func setupLoginBtn() {
        if let user = Auth.auth().currentUser {
            print("login as \(user.uid)")
        } else {
            print("currentUser is nil")
        }
        
        if let user = Auth.auth().currentUser , !user.isAnonymous {
            loginBtn.title = "ログアウト"
        }  else {
            loginBtn.title = "ログイン"
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifiers.SpotCell, bundle: nil), forCellReuseIdentifier: Identifiers.SpotCell)
    }
    
    // ログインフローに遷移するためのメソッド
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
    // テーブルに表示されるセルのデータを制御するメソッド
    private func setSpotsListener() {
        listener = db.spots.addSnapshotListener({ (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let spot = Spot.init(data: data)
                
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, spot: spot)
                case .modified:
                    self.onDocumentModified(change: change, spot: spot)
                case .removed:
                    self.onDocumentRemoved(change: change)
                @unknown default:
                    return
                }
            })
        })
    }
    
    // MARK: Actions
    @IBAction func loginClicked(_ sender: Any) {
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

extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    
    // データベースの変更に対して実行されるメソッド - begin
    private func onDocumentAdded(change: DocumentChange, spot: Spot) {
        let newIndex = Int(change.newIndex)
        spots.insert(spot, at: newIndex)
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .fade)
    }
    
    private func onDocumentModified(change: DocumentChange, spot: Spot) {
        if change.newIndex == change.oldIndex {
            // Row change, but remained in the same position
            let index = Int(change.newIndex)
            spots[index] = spot
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            // Row changed and changed position
            let newIndex = Int(change.newIndex)
            let oldIndex = Int(change.oldIndex)
            spots.remove(at: oldIndex)
            spots.insert(spot, at: newIndex)
            tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    
    private func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        spots.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: .left)
    }
    // データベースの変更に対して実行されるメソッド - end
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.SpotCell, for: indexPath) as? SpotCell {
            cell.configureCell(spot: spots[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSpot = spots[indexPath.row]
        performSegue(withIdentifier: Segues.ToSpot, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ToSpot {
            if let destination = segue.destination as? SpotVC {
                destination.spot = selectedSpot
            }
        }
    }
    
}
