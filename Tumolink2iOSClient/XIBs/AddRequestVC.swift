//
//  AddRequestVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/11.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import UIKit

class AddRequestVC: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var bgView: UIVisualEffectView!
    
    // MARK: Valiables
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAddRequest))
        tap.numberOfTapsRequired = 1
        bgView.addGestureRecognizer(tap)
    }

    @objc func dismissAddRequest() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: Actions
    @IBAction func closeClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
