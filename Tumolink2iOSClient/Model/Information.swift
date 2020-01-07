//
//  Information.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/07.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum InfoType {
    case news
    case request
    case others
    
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
    var isRead: Bool
    var isActive: Bool
    var createdAt: Timestamp
    var updatedAt: Timestamp
    
    init(id: String = "",
         infoType: InfoType = InfoType.others,
         details: String = "",
         from: String = "",
         isRead: Bool = false,
         isActive: Bool = false,
         createdAt: Timestamp = Timestamp(),
         updatedAt: Timestamp = Timestamp()) {
        
        self.id = id
        self.infoType = infoType
        self.details = details
        self.from = from
        self.isRead = isRead
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(data: [String: Any]) {
        let infoTypeFromFirestore = InfoType(name: data["InfoType"] as! String)
        
        id = data["String"] as? String ?? ""
        infoType = infoTypeFromFirestore ?? InfoType.others
        details = data["String"] as? String ?? ""
        from = data["String"] as? String ?? ""
        isRead = data["Bool"] as? Bool ?? false
        isActive = data["Bool"] as? Bool ?? false
        createdAt = data["Timestamp"] as? Timestamp ?? Timestamp()
        updatedAt = data["Timestamp"] as? Timestamp ?? Timestamp()
    }
    
    static func modelToData(information: Information) -> [String: Any] {
        let data: [String: Any] = [
            "id" : information.id,
            "InfoType" : information.infoType,
            "details" : information.details,
            "from" : information.from,
            "isRead" : information.isRead,
            "isActive" : information.isActive,
            "createdAt" : information.createdAt,
            "updatedAt" : information.updatedAt
        ]
        
        return data
    }
}
