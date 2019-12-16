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
    func getCurrentUser() {
        guard let authUser = auth.currentUser else { return }
        
        let userRef = db.collection(FirestoreCollectionIds.Users).document(authUser.uid)
        userListener = userRef.addSnapshotListener({ (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let data = snap?.data() else { return }
            self.user = User.init(data: data)
            print(self.user)
        })
    }
    
    func logoutUser() {
        userListener?.remove()
        userListener = nil
        user = User()
    }
}
