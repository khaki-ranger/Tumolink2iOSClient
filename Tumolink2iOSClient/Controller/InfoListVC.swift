//
//  InfoListVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/11.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseFirestore

class InfoListVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Valiables
    var db: Firestore!
    var listener: ListenerRegistration!
    var informations = [Information]()
    var selectedInformation: Information!

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()

        navigationItem.title = "お知らせ一覧"
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        informations.removeAll()
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupListener() {
        let docRef = db.informations(userId: UserService.user.id)
        listener = docRef.addSnapshotListener({ (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "データの取得に失敗しました")
                return
            }
            
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let information = Information.init(data: data)
                
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, information: information)
                case .modified:
                    self.onDocumentModified(change: change, information: information)
                case .removed:
                    self.onDocumentRemoved(change: change)
                @unknown default:
                    return
                }
            })
        })
    }
    
    // MARK: Actions

}

extension InfoListVC : UITableViewDelegate, UITableViewDataSource {
    
    // データベースの変更に対して実行されるメソッド - begin
    private func onDocumentAdded(change: DocumentChange, information: Information) {
        let newIndex = Int(change.newIndex)
        informations.insert(information, at: newIndex)
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .fade)
    }
    
    private func onDocumentModified(change: DocumentChange, information: Information) {
        if change.newIndex == change.oldIndex {
            // Row change, but remained in the same position
            let index = Int(change.newIndex)
            informations[index] = information
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            // Row changed and changed position
            let newIndex = Int(change.newIndex)
            let oldIndex = Int(change.oldIndex)
            informations.remove(at: oldIndex)
            informations.insert(information, at: newIndex)
            tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
            tableView.reloadRows(at: [IndexPath(row: newIndex, section: 0)], with: .none)
        }
    }
    
    private func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        informations.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: .left)
    }
    // データベースの変更に対して実行されるメソッド - end
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.InfoCell, for: indexPath) as? InfoCell else { return UITableViewCell() }
        cell.configureCell(information: informations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedInformation = informations[indexPath.row]
        // infoTypeによって振る舞いを分岐する
        switch selectedInformation.infoType {
        case .news:
            print("ニュース")
        case .request:
            performSegue(withIdentifier: Segues.ToRequestDetail, sender: self)
        case .response:
            performSegue(withIdentifier: Segues.ToResponseDetail, sender: self)
        case .others:
            print("その他")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ToRequestDetail {
            if let destination = segue.destination as? RequestDetailVC {
                destination.information = selectedInformation
            }
        } else if segue.identifier == Segues.ToResponseDetail {
            if let destination = segue.destination as? ResponseDetailVC {
                destination.information = selectedInformation
            }
        }
    }
}
