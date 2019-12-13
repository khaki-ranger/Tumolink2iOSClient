//
//  SpotVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/13.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit

class SpotVC: UIViewController {
    
    // MARK: Outlets
    
    // MARK: Valiables
    var spot: Spot!

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = spot.name
    }
    
    // MARK: Actions

}
