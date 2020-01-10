//
//  SearchSpotVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/09.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SearchSpotVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Variables
    var allSpots = [Spot]()
    var filteredSpots = [Spot]()
    var db: Firestore!
    var selectedSpot: Spot!
    
    // MARK: functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        setupTableView()
        setupSearchTxt()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAllSpotsCollection()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disappearView()
        allSpots.removeAll()
        filteredSpots.removeAll()
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifiers.SpotCell, bundle: nil), forCellReuseIdentifier: Identifiers.SpotCell)
    }
    
    // 全てのスポットを取得するためのメソッド
    private func getAllSpotsCollection() {
        activityIndicator.startAnimating()
        fetchCollection { (spots, error) in
            
            if let error = error {
                debugPrint(error)
                self.simpleAlert(title: "エラー", msg: "スポットの取得に失敗しました")
                return
            }
            
            guard let spots = spots else { return }
            
            self.allSpots = spots
            self.activityIndicator.stopAnimating()
            self.appearViewWithAnimasion()
        }
    }
    
    private func fetchCollection(completion: @escaping ([Spot]?, Error?) -> Void) {
        var spots = [Spot]()
        db.spots.getDocuments { (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let documents = snap?.documents else { return }
            
            for document in documents {
                let data = document.data()
                var spot = Spot.init(data: data)
                
                // 各スポットにおけるログインユーザーのステータスを判定
                if spot.owner == UserService.user.id {
                    spot.memberStatus = MemberStatus.owner
                } else if spot.members.contains(UserService.user.id) {
                    spot.memberStatus = MemberStatus.member
                } else if spot.pending.contains(UserService.user.id) {
                    spot.memberStatus = MemberStatus.pending
                } else {
                    spot.memberStatus = MemberStatus.unapplied
                }
                
                spots.append(spot)
            }
            completion(spots, nil)
        }
    }
    
    private func appearViewWithAnimasion() {
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut], animations: {
            self.searchView.alpha = 1.0
        }, completion: nil)
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut], animations: {
            self.tableView.alpha = 1.0
        }, completion: nil)
    }
    
    private func disappearView() {
        searchView.alpha = 0.0
        tableView.alpha = 0.0
    }
    
    private func setupSearchTxt() {
        searchTxt.addTarget(self, action: #selector(searchTxtDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func searchTxtDidChange(_ textField: UITextField) {
        filteredSpots.removeAll()
        tableView.reloadData()
        
        guard let searchTxt = searchTxt.text else { return }
        filteringSpots(searchTxt: searchTxt)
    }
    
    // スポット名に入力した文字列が含まれるかどうかを判定するためのメソッド
    private func filteringSpots(searchTxt: String) {
        allSpots.forEach { (spot) in
            let name = spot.name
            if name.contains(searchTxt) {
                filteredSpots.append(spot)
            }
        }
        tableView.reloadData()
    }
    
    // MARK: Actions
    
}

extension SearchSpotVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.SpotCell, for: indexPath) as? SpotCell {
            cell.configureCell(spot: filteredSpots[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
