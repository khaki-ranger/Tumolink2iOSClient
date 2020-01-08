//
//  SpotUser.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/08.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct SpotUser {
    var id: String
    var spotId: String
    var userId: String
    var isApproved: Bool
    var createdAt: Timestamp
    var updatedAt: Timestamp
    
    init(id: String = "",
         spotId: String = "",
         userId: String = "",
         isApproved: Bool = false,
         createdAt: Timestamp = Timestamp(),
         updatedAt: Timestamp = Timestamp()) {
        
        self.id = id
        self.spotId = spotId
        self.userId = userId
        self.isApproved = isApproved
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(data: [String: Any]) {
        id = data["id"] as? String ?? ""
        spotId = data["spotId"] as? String ?? ""
        userId = data["userId"] as? String ?? ""
        isApproved = data["isApproved"] as? Bool ?? false
        createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
        updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp()
    }
    
    static func modelToData(spotuser: SpotUser) -> [String: Any] {
        let data: [String: Any] = [
            "id" : spotuser.id,
            "spotId" : spotuser.spotId,
            "userId" : spotuser.userId,
            "isApproved" : spotuser.isApproved,
            "createdAt" : spotuser.createdAt,
            "updatedAt" : spotuser.updatedAt
        ]
        
        return data
    }
}
