//
//  DataViewCorrelationCell.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 22/06/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class DataViewCorrelationCell:UITableViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var secondaryLabel: UILabel!
    
    func layout(leftEmoji: String, joinTerm: String, rightEmoji: String, detail: String) {
        
        let emojiFont = UIFont.systemFont(ofSize: 30)
        let joinFont = UIFont.systemFont(ofSize: 20)
        
        let attrString = NSMutableAttributedString(string: leftEmoji, attributes: [NSFontAttributeName : emojiFont])
        
        attrString.append(NSAttributedString(string: " \(joinTerm) ", attributes: [NSFontAttributeName : joinFont, NSForegroundColorAttributeName:UIColor.white]))
        
        attrString.append(NSAttributedString(string: rightEmoji, attributes: [NSFontAttributeName : emojiFont]))
        
        mainLabel.attributedText = attrString
        
        
        secondaryLabel.text = detail
        secondaryLabel.font = UIFont.systemFont(ofSize: 14)
        secondaryLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        
    }
}
