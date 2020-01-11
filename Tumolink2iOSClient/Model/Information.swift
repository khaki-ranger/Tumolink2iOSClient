//
//  Information.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/07.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum InfoType: String {
    case news = "news"
    case request = "request"
    case others = "other"
    
    init?(name: String) {
        switch name {
        case "news":
            self = .news
        case "request":
            self = .request
        case "others":
            self = .others
        default:
            return nil
        }
    }
}

struct Information {
    var id: String
    var infoType: InfoType
    var details: String
    var from: String
    var spotId: String
    var isRead: Bool
    var isActive: Bool
    var createdAt: Timestamp
    var updatedAt: Timestamp
    
    init(id: String = "",
         infoType: InfoType = InfoType.others,
         details: String = "",
         from: String = "",
         spotId: String = "",
         isRead: Bool = false,
         isActive: Bool = false,
         createdAt: Timestamp = Timestamp(),
         updatedAt: Timestamp = Timestamp()) {
        
        self.id = id
        self.infoType = infoType
        self.details = details
        self.from = from
        self.spotId = spotId
        self.isRead = isRead
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(data: [String: Any]) {
        let infoTypeFromFirestore = InfoType(name: data["InfoType"] as! String)
        
        id = data["id"] as? String ?? ""
        infoType = infoTypeFromFirestore ?? InfoType.others
        details = data["details"] as? String ?? ""
        from = data["from"] as? String ?? ""
        spotId = data["spotId"] as? String ?? ""
        isRead = data["isRead"] as? Bool ?? false
        isActive = data["isActive"] as? Bool ?? false
        createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
        updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp()
    }
    
    static func modelToData(information: Information) -> [String: Any] {
        let data: [String: Any] = [
            "id" : information.id,
            "InfoType" : information.infoType.rawValue,
            "details" : information.details,
            "from" : information.from,
            "spotId" : information.spotId,
            "isRead" : information.isRead,
            "isActive" : information.isActive,
            "createdAt" : information.createdAt,
            "updatedAt" : information.updatedAt
        ]
        
        return data
    }
}
