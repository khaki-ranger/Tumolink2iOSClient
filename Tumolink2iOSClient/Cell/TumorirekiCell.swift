//
//  TumorirekiCell.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/16.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import UIKit

class TumorirekiCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var spotnameLbl: UILabel!
    @IBOutlet weak var possibilityLbl: UILabel!
    
    // MARK: Valibalbes
    
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
        spotnameLbl.text = tumoli.spotname
        possibilityLbl.text = String(tumoli.possibility)
        
        let f = DateFormatter()
        f.setTemplate(.date)
        let date: Date = tumoli.date.dateValue()
        dateLbl.text = f.string(from: date)
    }

}
