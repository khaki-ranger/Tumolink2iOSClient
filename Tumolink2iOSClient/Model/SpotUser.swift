//
//  SpotUser.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/08.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum MemberStatus: String {
    case owner = "オーナー"
    case member = "メンバー"
    case pending = "承認待ち"
    case unapplied = "未申請"
}

struct SpotUser {
    var id: String
    var spotId: String
    var userId: String
    var status: MemberStatus
    var createdAt: Timestamp
    var updatedAt: Timestamp
    
    init(id: String = "",
         spotId: String = "",
         userId: String = "",
         status: MemberStatus = MemberStatus.unapplied,
         createdAt: Timestamp = Timestamp(),
         updatedAt: Timestamp = Timestamp()) {
        
        self.id = id
        self.spotId = spotId
        self.userId = userId
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(data: [String: Any]) {
        id = data["id"] as? String ?? ""
        spotId = data["spotId"] as? String ?? ""
        userId = data["userId"] as? String ?? ""
        status = data["status"] as? MemberStatus ?? MemberStatus.unapplied
        createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
        updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp()
    }
    
    static func modelToData(spotuser: SpotUser) -> [String: Any] {
        let data: [String: Any] = [
            "id" : spotuser.id,
            "spotId" : spotuser.spotId,
            "userId" : spotuser.userId,
            "status" : spotuser.status.rawValue,
            "createdAt" : spotuser.createdAt,
            "updatedAt" : spotuser.updatedAt
        ]
        
        return data
    }
}
