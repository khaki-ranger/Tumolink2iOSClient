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
    var mySpots = [Spot]()
    var db: Firestore!
    var selectedSpot: Spot!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialAnonymouseUser()
        db = Firestore.firestore()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupLoginBtn()
        setupMySpots()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disappearTableViewWithAnimasion()
        mySpots.removeAll()
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
    private func setupMySpots() {
        activityIndicator.startAnimating()
        
        UserService.getMySpots { (mySpots, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "マイスポットの取得に失敗しました")
                return
            }
            
            if mySpots.count > 0 {
                self.mySpots = mySpots
                self.tableView.reloadData()
                self.appearTableViewWithAnimasion()
            }
            
            self.activityIndicator.stopAnimating()
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
        return mySpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.SpotCell, for: indexPath) as? SpotCell {
            cell.configureCell(spot: mySpots[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSpot = mySpots[indexPath.row]
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
