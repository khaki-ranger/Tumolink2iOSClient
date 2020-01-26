//
//  Constants.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/02.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import Foundation

struct Storyboard {
    static let LoginStoryboard = "LoginStoryboard"
    static let Main = "Main"
    static let Home = "Home"
}

struct StoryboardId {
    static let LoginVC = "LoginVC"
    static let MainVC = "MainVC"
    static let HomeVC = "HomeVC"
}

struct AppImages {
    static let GreenCheck = "green_check"
    static let RedCheck = "red_check"
    static let Placeholder = "placeholder"
    static let NoProfile = "no_image"
}

struct Identifiers {
    static let SpotCell = "SpotCell"
    static let SpotImageCell = "SpotImageCell"
    static let TumoliCell = "TumoliCell"
    static let InfoCell = "InfoCell"
    static let TumorirekiCell = "TumorirekiCell"
    static let WeeklyCell = "WeeklyCell"
}

struct Segues {
    static let ToSpot = "ToSpot"
    static let ToEditSpot = "ToEditSpot"
    static let ToEditUser = "ToEditUser"
    static let ToRequestDetail = "ToRequestDetail"
    static let ToResponseDetail = "ToResponseDetail"
    static let ToManageSpot = "ToManageSpot"
}
