//
//  Tumoli.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/25.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Tumoli {
    var id: String
    var userId: String
    var username: String
    var userImg: String
    var spotId: String
    var possibility: Int
    var isActive: Bool
    var date: Timestamp
    var createdAt: Timestamp
    var updatedAt: Timestamp
    
    init(id: String = "",
         userId: String = "",
         username: String = "",
         userImg: String = "",
         spotId: String = "",
         possibility: Int = 0,
         isActive: Bool = true,
         date: Timestamp = Timestamp(),
         createdAt: Timestamp = Timestamp(),
         updatedAt: Timestamp = Timestamp()) {
        
        self.id = id
        self.userId = userId
        self.username = username
        self.userImg = userImg
        self.spotId = spotId
        self.possibility = possibility
        self.isActive = isActive
        self.date = date
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(data: [String: Any]) {
        id = data["id"] as? String ?? ""
        userId = data["userId"] as? String ?? ""
        username = data["username"] as? String ?? ""
        userImg = data["userImg"] as? String ?? ""
        spotId = data["spotId"] as? String ?? ""
        possibility = data["possibility"] as? Int ?? 0
        isActive = data["isActive"] as? Bool ?? true
        date = data["date"] as? Timestamp ?? Timestamp()
        createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
        updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp()
    }
    
    static func modelToData(tumoli: Tumoli) -> [String: Any] {
        let data: [String: Any] = [
            "id" : tumoli.id,
            "userId" : tumoli.userId,
            "username" : tumoli.username,
            "userImg" : tumoli.userImg,
            "spotId" : tumoli.spotId,
            "possibility" : tumoli.possibility,
            "isActive" : tumoli.isActive,
            "date" : tumoli.date,
            "createdAt" : tumoli.createdAt,
            "updatedAt" : tumoli.updatedAt
        ]
        
        return data
    }
}
