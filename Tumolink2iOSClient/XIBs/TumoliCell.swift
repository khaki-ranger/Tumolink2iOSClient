//
//  TumoliCell.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/25.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class TumoliCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var profileImg: CircleImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var possibilityLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Variables

    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(tumoli: Tumoli) {
        possibilityLbl.text = String(tumoli.possibility)
        
        activityIndicator.startAnimating()
        
        let docRef = Firestore.firestore().collection(FirestoreCollectionIds.Users).document(tumoli.userId)
        docRef.addSnapshotListener { (snap, error) in
            
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let data = snap?.data() else { return }
            let user = User.init(data: data)
            self.usernameLbl.text = user.username
            
            if let url = URL(string: user.imageUrl) {
                let placeholder = UIImage(named: AppImages.Placeholder)
                let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
                self.profileImg.kf.indicatorType = .activity
                self.profileImg.kf.setImage(with: url, placeholder: placeholder, options: options)
            }
        }
    }
    
    // MARK: Actions
    
}
