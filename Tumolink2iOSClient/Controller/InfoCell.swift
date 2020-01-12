//
//  InfoCell.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/12.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import UIKit

class InfoCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var isReadedLbl: RoundedLabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    // MARK: Valiables

    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureCell(information: Information) {
        if information.isRead == true {
            isReadedLbl.text = "既読"
            isReadedLbl.backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.9607843137, blue: 0.737254902, alpha: 1)
            isReadedLbl.textColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        }
        titleLbl.text = information.title
        
        let f = DateFormatter()
        f.setTemplate(.full)
        let createdAt: Date = information.createdAt.dateValue()
        dateLbl.text = f.string(from: createdAt)
    }
    
    // MARK: Accions

}
