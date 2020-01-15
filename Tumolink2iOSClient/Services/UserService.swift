//
//  UserService.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/16.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let UserService = _UserService()

final class _UserService {
    
    // Variables
    var user = User()
    let auth = Auth.auth()
    let db = Firestore.firestore()
    var userListener : ListenerRegistration? = nil
    
    // アプリを利用中のユーザーが、ログイン済みかどうかを確認するためのコンピューテッドプロパティ
    var isGuest : Bool {
        guard let authUser = auth.currentUser else {
            return true
        }
        if authUser.isAnonymous {
            return true
        } else {
            return false
        }
    }
    
    // アプリを利用中のユーザーのデータをFirestoreから取得するためのメソッド
    func getCurrentUser(completion: @escaping (Error?) -> Void) {
        guard let authUser = auth.currentUser else { return }
        
        if authUser.uid != user.id {
            let userRef = db.collection(FirestoreCollectionIds.Users).document(authUser.uid)
            userListener = userRef.addSnapshotListener({ (snap, error) in
                
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let data = snap?.data() else { return }
                self.user = User.init(data: data)
                completion(nil)
            })
        } else {
            completion(nil)
        }
    }
    
    // ログインユーザーのマイスポットを取得するためのメソッド
    func getMySpots(completion: @escaping ([Spot], Error?) -> Void) {
        var count = 0
        var returnArray = [Spot]()
        
        getCurrentUser { (error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(returnArray, error)
                return
            }
            
            let mySpots = self.user.mySpots
            if mySpots.count < 1 {
                completion(returnArray, nil)
                return
            }
            
            for spotId in mySpots {
                self.fetchDocument(spotId: spotId) { (spot, error) in
                    
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        completion(returnArray, error)
                        return
                    }
                    
                    guard let spot = spot else { return }
                    returnArray.append(spot)
                    
                    count += 1
                    if count == mySpots.count {
                        completion(returnArray, nil)
                    }
                }
            }
        }
    }
    
    private func fetchDocument(spotId: String, completion: @escaping (Spot?, Error?) -> Void) {
        let docRef = db.collection(FirestoreCollectionIds.Spots).document(spotId)
        docRef.getDocument { (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let data = snap?.data() else { return }
            var spot = Spot.init(data: data)
            spot.memberStatus = UserService.status(spot: spot)
            completion(spot, nil)
        }
    }
    
    func logoutUser() {
        userListener?.remove()
        userListener = nil
        user = User()
    }
    
    // 各スポットにおけるログインユーザーのステータスを判定するメソッド
    func status(spot: Spot) -> MemberStatus {
        if spot.owner == user.id {
            return MemberStatus.owner
        } else if spot.members.contains(user.id) {
            return MemberStatus.member
        } else if spot.pending.contains(user.id) {
            return MemberStatus.pending
        } else {
            return MemberStatus.unapplied
        }
    }
}
