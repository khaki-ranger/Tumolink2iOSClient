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
}
