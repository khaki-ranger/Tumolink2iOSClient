//
//  Extensions.swift
//  Tumolink2iOSClient
//
//  Created by 寺島 洋平 on 2019/12/02.
//  Copyright © 2019 YoheiTerashima. All rights reserved.
//

import UIKit
import Firebase

extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension UIViewController {
    
    func simpleAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func setupTabBarBadge() {
        guard let authUser = Auth.auth().currentUser else { return }
        let docRef = Firestore.firestore().fetchUnreadInfomations(userId: authUser.uid)
        docRef.getDocuments { (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let documents = snap?.documents else { return }
            let unreadInfoCounts = documents.count
            
            if let tabItems = self.tabBarController?.tabBar.items {
                if unreadInfoCounts > 0 {
                    tabItems[1].badgeValue = String(unreadInfoCounts)
                } else {
                    tabItems[1].badgeValue = nil
                }
            }
            
        }
    }
}

extension DateFormatter {
    // テンプレートの定義(例)
    enum Template: String {
        case date = "yMd"     // 2017/1/1
        case time = "Hms"     // 12:39:22
        case full = "yMdkHms" // 2017/1/1 12:39:22
        case onlyHour = "k"   // 17時
        case era = "GG"       // "西暦" (default) or "平成" (本体設定で和暦を指定している場合)
        case weekDay = "EEEE" // 日曜日
    }
    
    func setTemplate(_ template: Template) {
        // optionsは拡張用の引数だが使用されていないため常に0
        dateFormat = DateFormatter.dateFormat(fromTemplate: template.rawValue, options: 0, locale: .current)
    }
}

extension NSAttributedString {
    convenience init(string: String, lineSpacing: CGFloat, alignment: NSTextAlignment) {
        var attributes: [NSAttributedString.Key: Any] = [:]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        attributes.updateValue(paragraphStyle, forKey: .paragraphStyle)
        self.init(string: string, attributes: attributes)
    }
}
