//
//  DataViewSummaryCell.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 22/06/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class DataViewSummaryCell:UITableViewCell {
    
    @IBOutlet var emojiLabel: [UILabel]!
    
    @IBOutlet var label: [UILabel]!
    
    func layout(emoji:[String], title:[String], percentage:[Float]) {
        
        if emoji.count == 3 && title.count == 3 && percentage.count == 3 {
            
            
            
            // Find the largest percentage, everything will be relative to that
            var largestPerc:Float = 0
            for perc in percentage {
                if perc > largestPerc {
                    largestPerc = perc
                }
            }
            
            var fontSizes = [Float]()
            for perc in percentage {
                // perc of 0 is size 20
                // perc of 1 is size 70
                let fontSize = 10 + (60 * (perc / largestPerc))
                fontSizes.append(fontSize)
            }
            
            for label in label {
                
                let perc = percentage[label.tag]
                
                let percInt = Int(round(perc * 100))
                
                label.text = "\(title[label.tag])\n\(percInt)%"
                label.font = UIFont.systemFont(ofSize: 14)
                label.textColor = UIColor.white
                
            }
            
            
            for emojiLabel in emojiLabel {
                emojiLabel.text = emoji[emojiLabel.tag]
                emojiLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSizes[emojiLabel.tag]))
            }
            
            
        } else{
            print("Error: Arrays are not correctly sized to layout this DataViewSummaryCell")
        }
        
        // Setup emoji, using the percentage sizes.
        
        
        
        // Setup the labels
        
        
        
        
    }
    
}
