//
//  AddTumoliVC.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/28.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class AddTumoliVC: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var bgView: UIVisualEffectView!
    @IBOutlet weak var possibilityLbl: UILabel!
    @IBOutlet weak var possibilitySlider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Variables
    var spot: Spot!
    var possibility = 50
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTapGesture()
        setupSlider()
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAddTumoli))
        tap.numberOfTapsRequired = 1
        bgView.addGestureRecognizer(tap)
    }
    
    private func setupSlider() {
        possibilitySlider.minimumValue = 0.01
        possibilitySlider.addTarget(self, action: #selector(sliderDidChangeValue(_:)), for: .valueChanged)
    }
    
    @objc func sliderDidChangeValue(_ sender: UISlider) {
        possibility = Int(sender.value * 100)
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
        uploadDocument()
    }
    
    private func uploadDocument() {
        
        activityIndicator.startAnimating()
        
        var tumoli = Tumoli.init(id: "",
                                 userId: UserService.user.id,
                                 spotId: spot.id,
                                 possibility: possibility,
                                 isActive: true,
                                 date: Timestamp())
        
        let docRef = Firestore.firestore().collection(FirestoreCollectionIds.Tumolis).document()
        tumoli.id = docRef.documentID
        
        let data = Tumoli.modelToData(tumoli: tumoli)
        docRef.setData(data, merge: true) { (error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "エラー", msg: "データのアップロードに失敗しました")
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
