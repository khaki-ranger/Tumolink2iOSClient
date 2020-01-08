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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Variables
    var spots = [Spot]()
    var db: Firestore!
    var selectedSpot: Spot!
    var count = 0
    
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserService.getCurrentUser()
        setupInitialAnonymouseUser()
        db = Firestore.firestore()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        count = 0
        setupLoginBtn()
        setSpotsListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disappearTableViewWithAnimasion()
        spots.removeAll()
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifiers.SpotCell, bundle: nil), forCellReuseIdentifier: Identifiers.SpotCell)
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
    
    // ログインフローに遷移するためのメソッド
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
    // テーブルに表示されるセルのデータを制御するメソッド
    private func setSpotsListener() {
        guard let authUser = Auth.auth().currentUser else { return }
        
        activityIndicator.startAnimating()

        let collectionRef = db.spotUser(userId: authUser.uid)
        collectionRef.getDocuments { (snap, error) in

            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let documents = snap?.documents else { return }
            
            for document in documents {
                let data = document.data()
                let spotUser = SpotUser.init(data: data)
                self.fetchDocument(spotUser: spotUser, completion: { (spot, error) in
                    
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        return
                    }
                    
                    guard let spot = spot else { return }
                    
                    self.spots.append(spot)
                    self.tableView.reloadData()
                    
                    self.count += 1
                    if self.count == documents.count {
                        self.activityIndicator.stopAnimating()
                        self.appearTableViewWithAnimasion()
                    }
                })
            }
        }
    }
    
    private func fetchDocument(spotUser: SpotUser, completion: @escaping (Spot?, Error?) -> Void) {
        let docRef = db.collection(FirestoreCollectionIds.Spots).document(spotUser.spotId)
        docRef.getDocument { (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let data = snap?.data() else { return }
            let spot = Spot.init(data: data)
            completion(spot, nil)
        }
    }
    
    private func appearTableViewWithAnimasion() {
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut], animations: {
            self.tableView.alpha = 1.0
        }, completion: nil)
    }
    
    private func disappearTableViewWithAnimasion() {
        tableView.alpha = 0.0
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
