//
//  User.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/16.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct User {
    var id: String
    var email: String
    var username: String
    var imageUrl: String
    var mySpots: [String]
    var hasSetupAccount: Bool
    var isActive: Bool
    var createdAt: Timestamp
    var updatedAt: Timestamp
    
    init(id: String = "",
         email: String = "",
         username: String = "",
         imageUrl: String = "",
         mySpots: [String] = [String](),
         hasSetupAccount: Bool = false,
         isActive: Bool = true,
         createdAt: Timestamp = Timestamp(),
         updatedAt: Timestamp = Timestamp()) {
        
        self.id = id
        self.email = email
        self.username = username
        self.imageUrl = imageUrl
        self.mySpots = mySpots
        self.hasSetupAccount = hasSetupAccount
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(data: [String: Any]) {
        id = data["id"] as? String ?? ""
        email = data["email"] as? String ?? ""
        username = data["username"] as? String ?? ""
        imageUrl = data["imageUrl"] as? String ?? ""
        mySpots = data["mySpots"] as? [String] ?? [String]()
        hasSetupAccount = data["hasSetupAccount"] as? Bool ?? false
        isActive = data["isActive"] as? Bool ?? true
        createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
        updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp()
    }
    
    static func modelToData(user: User) -> [String: Any] {
        let data: [String: Any] = [
            "id" : user.id,
            "email" : user.email,
            "username" : user.username,
            "imageUrl" : user.imageUrl,
            "mySpots" : user.mySpots,
            "hasSetupAccount" : user.hasSetupAccount,
            "isActive" : user.isActive,
            "createdAt" : user.createdAt,
            "updatedAt" : user.updatedAt
        ]
        
        return data
    }
}
