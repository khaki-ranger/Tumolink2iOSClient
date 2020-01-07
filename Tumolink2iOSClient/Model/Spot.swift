//
//  Spot.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/12.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Spot {
    var id: String
    var name: String
    var owner: String
    var description: String
    var images: [String]
    var address: String
    var isPublic: Bool
    var isActive: Bool
    var timeStamp: Timestamp
    
    init(
        id: String,
        name: String,
        owner: String,
        images: [String],
        description: String = "",
        address: String = "",
        isPublic: Bool = true,
        isActive: Bool = true,
        timeStamp: Timestamp = Timestamp()) {
        
        self.id = id
        self.name = name
        self.owner = owner
        self.images = images
        self.description = description
        self.address = address
        self.isPublic = isPublic
        self.isActive = isActive
        self.timeStamp = timeStamp
    }
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.owner = data["owner"] as? String ?? ""
        self.images = data["images"] as? [String] ?? [String]()
        self.description = data["description"] as? String ?? ""
        self.address = data["address"] as? String ?? ""
        self.isPublic = data["isPublic"] as? Bool ?? true
        self.isActive = data["isActive"] as? Bool ?? true
        self.timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp()
    }
    
    static func modelToData(spot: Spot) -> [String: Any] {
        let data : [String: Any] = [
            "id": spot.id,
            "name": spot.name,
            "owner": spot.owner,
            "images": spot.images,
            "description": spot.description,
            "address": spot.address,
            "isPublic": spot.isPublic,
            "isActive": spot.isActive,
            "timeStamp": spot.timeStamp
        ]
        
        return data
    }
}
