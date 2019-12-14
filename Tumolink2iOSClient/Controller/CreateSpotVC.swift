//
//  CreateSpotVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/14.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit

class CreateSpotVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var spotImg1: UIImageView!
    @IBOutlet weak var spotImg2: UIImageView!
    @IBOutlet weak var spotImg3: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Variables

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: Actions
    @IBAction func createClicked(_ sender: Any) {
    }
    
}
