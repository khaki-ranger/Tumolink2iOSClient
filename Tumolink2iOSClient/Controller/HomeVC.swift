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
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // テストのためにスポットのダミーデータを設定
        let spot = Spot.init(id: "hogehoge",
                             name: "ギークオフィス恵比寿",
                             owner: "YoheiTerashima",
                             description: "東京の恵比寿にある、ギーク達が集まる場所だよ",
                             images: ["https://www.tumolink.com/images/spaces/space_1.jpg"],
                             address: "東京都渋谷区恵比寿",
                             isPublic: true,
                             isActive: true,
                             timeStamp: Timestamp())
        spots.append(spot)
        
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ログインしているかどうかを判定
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
    
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func loginClicked(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        if user.isAnonymous {
            presentLoginController()
        } else {
            do {
                try Auth.auth().signOut()
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
    
}
