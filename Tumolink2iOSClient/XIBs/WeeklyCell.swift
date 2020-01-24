//
//  WeeklyCell.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2020/01/24.
//  Copyright © 2020 YoheiTerashima. All rights reserved.
//

import UIKit

protocol WeeklyCellDelegate : class {
    func dayTapped(date: Date)
}

class WeeklyCell: UICollectionViewCell {

    // MARK: Outlets
    @IBOutlet weak var sundayLbl: UILabel!
    @IBOutlet weak var mondayLbl: UILabel!
    @IBOutlet weak var tuesdayLbl: UILabel!
    @IBOutlet weak var wednesdayLbl: UILabel!
    @IBOutlet weak var thursdayLbl: UILabel!
    @IBOutlet weak var fridayLbl: UILabel!
    @IBOutlet weak var saturdayLbl: UILabel!
    
    @IBOutlet weak var sundayIcon: UIView!
    @IBOutlet weak var mondayIcon: UIView!
    @IBOutlet weak var tuesdayIcon: UIView!
    @IBOutlet weak var wednesdayIcon: UIView!
    @IBOutlet weak var thursdayIcon: UIView!
    @IBOutlet weak var fridayIcon: UIView!
    @IBOutlet weak var saturdayIcon: UIView!
    
    // MARK: Valiables
    weak var delegate : WeeklyCellDelegate?
    var calendar = Calendar.current
    var weekly = [Date]()
    var days = [UILabel]()
    var icons = [UIView]()
    let defaultDateColor: UIColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    let currentDateColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    let pastDateColor: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        
        days = [
            sundayLbl,
            mondayLbl,
            tuesdayLbl,
            wednesdayLbl,
            thursdayLbl,
            fridayLbl,
            saturdayLbl
        ]
        
        icons = [
            sundayIcon,
            mondayIcon,
            tuesdayIcon,
            wednesdayIcon,
            thursdayIcon,
            fridayIcon,
            saturdayIcon
        ]
        
        setupTapGesture()
    }
    
    func configureCell(currentDate: Date, weekly: [Date], delegate: WeeklyCellDelegate) {
        self.delegate = delegate
        self.weekly = weekly
        
        let today = calendar.startOfDay(for: Date())
        
        for (index, thisDay) in weekly.enumerated() {
            let day = calendar.component(.day, from: thisDay)
            days[index].text = String(day)
            days[index].isUserInteractionEnabled = true
            icons[index].alpha = 0.0
            if calendar.isDate(currentDate, inSameDayAs: thisDay) {
                days[index].textColor = currentDateColor
                appearIconWithAnimasion(icon: icons[index], value: 1.0)
            } else if thisDay < today {
                days[index].textColor = pastDateColor
                days[index].isUserInteractionEnabled = false
            } else {
                days[index].textColor = defaultDateColor
                appearIconWithAnimasion(icon: icons[index], value: 0.0)
            }
        }
    }
    
    private func appearIconWithAnimasion(icon: UIView, value: CGFloat) {
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut], animations: {
            icon.alpha = value
        }, completion: nil)
    }
    
    private func setupTapGesture() {
        let sundayTap = UITapGestureRecognizer(target: self, action: #selector(sundayTapped(sender:)))
        let mondayTap = UITapGestureRecognizer(target: self, action: #selector(mondayTapped(sender:)))
        let tuesdayTap = UITapGestureRecognizer(target: self, action: #selector(tuesdayTapped(sender:)))
        let wednesdayTap = UITapGestureRecognizer(target: self, action: #selector(wednesdayTapped(sender:)))
        let thursdayTap = UITapGestureRecognizer(target: self, action: #selector(thursdayTapped(sender:)))
        let fridayTap = UITapGestureRecognizer(target: self, action: #selector(fridayTapped(sender:)))
        let saturdayTap = UITapGestureRecognizer(target: self, action: #selector(saturdayTapped(sender:)))
        sundayLbl.addGestureRecognizer(sundayTap)
        mondayLbl.addGestureRecognizer(mondayTap)
        tuesdayLbl.addGestureRecognizer(tuesdayTap)
        wednesdayLbl.addGestureRecognizer(wednesdayTap)
        thursdayLbl.addGestureRecognizer(thursdayTap)
        fridayLbl.addGestureRecognizer(fridayTap)
        saturdayLbl.addGestureRecognizer(saturdayTap)
    }
    
    @objc func sundayTapped(sender: UITapGestureRecognizer) {
        delegate?.dayTapped(date: weekly[0])
    }
    
    @objc func mondayTapped(sender: UITapGestureRecognizer) {
        delegate?.dayTapped(date: weekly[1])
    }
    
    @objc func tuesdayTapped(sender: UITapGestureRecognizer) {
        delegate?.dayTapped(date: weekly[2])
    }
    
    @objc func wednesdayTapped(sender: UITapGestureRecognizer) {
        delegate?.dayTapped(date: weekly[3])
    }
    
    @objc func thursdayTapped(sender: UITapGestureRecognizer) {
        delegate?.dayTapped(date: weekly[4])
    }
    
    @objc func fridayTapped(sender: UITapGestureRecognizer) {
        delegate?.dayTapped(date: weekly[5])
    }
    
    @objc func saturdayTapped(sender: UITapGestureRecognizer) {
        delegate?.dayTapped(date: weekly[6])
    }
    
    // MARK: Actions
}
