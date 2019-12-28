//
//  AddTumoliVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/28.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Kingfisher

class AddTumoliVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var bgView: UIVisualEffectView!
    @IBOutlet weak var possibilityLbl: UILabel!
    @IBOutlet weak var possibilitySlider: UISlider!
    
    // MARK: Variables
    var spot: Spot!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAddTumoli))
        tap.numberOfTapsRequired = 1
        bgView.addGestureRecognizer(tap)
        
        possibilitySlider.minimumValue = 0.01
        possibilitySlider.addTarget(self, action: #selector(sliderDidChangeValue(_:)), for: .valueChanged)
    }
    
    @objc func sliderDidChangeValue(_ sender: UISlider) {
        let possibility = Int(sender.value * 100)
        possibilityLbl.text = "\(possibility)%"
    }
    
    @objc func dismissAddTumoli() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTumoliClicked(_ sender: Any) {
    }
    
}
