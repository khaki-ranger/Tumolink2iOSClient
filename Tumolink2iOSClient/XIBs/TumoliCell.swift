//
//  TumoliCell.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/25.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit

class TumoliCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var profileImg: CircleImageView!
    @IBOutlet weak var usernameTxt: UILabel!
    
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
        print(tumoli)
    }
    
    // MARK: Actions
    
}
