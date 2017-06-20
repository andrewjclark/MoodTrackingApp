//
//  GraphView.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 27/03/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class GraphItem {
    var emoji:String = ""
    var value:Float = 0 // Can be between -1 and 1
    var label:String = ""
}

class GraphView:UIView {
    
    var items = [GraphItem]()
    
    var labels = [UILabel]() // Labels that show the happy/sad symbols
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            
            // Draw the mid line
            if items.count > 0 {
                let guide1XPos = xPos(x: 0.0)
                let guide1YPos = yPos(scale: 0.5)
                
                let guide2XPos = xPos(x: 1.0)
                let guide2YPos = yPos(scale: 0.5)
                
                context.setStrokeColor(UIColor.white.withAlphaComponent(0.5).cgColor)
                context.setLineWidth(1)
                
                context.move(to: CGPoint(x: guide1XPos, y: guide1YPos))
                
                context.addLine(to: CGPoint(x: guide2XPos, y: guide2YPos))
                
                context.strokePath()
            }
            
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(3)
            
            // Get the max time and min time
            var count = 0
            
            if items.count > 1 {
                for item in items {
                    
                    if count == 0 {
                        
                        let xPos:CGFloat = self.xPos(index: count)
                        
                        let yPos:CGFloat = self.yPos(scale: item.value)
                        
                        context.move(to: CGPoint(x: xPos, y: yPos))
                    } else if count < items.count {
                        
                        let lastResult = items[count - 1]
                        let lastXPos:CGFloat = self.xPos(index: count - 1)
                        let lastYPos:CGFloat = self.yPos(scale: lastResult.value)
                        
                        let lastLinePoint = CGPoint(x: lastXPos, y: lastYPos)
                        
                        let xPos:CGFloat = self.xPos(index: count)
                        let yPos:CGFloat = self.yPos(scale: item.value)
                        
                        let newPoint = CGPoint(x: xPos, y: yPos)
                        let diffWidth:CGFloat = 0
                        
                        let control1 = CGPoint(x: lastLinePoint.x + diffWidth, y: lastLinePoint.y)
                        let control2 = CGPoint(x: newPoint.x - diffWidth, y: newPoint.y)
                        
                        context.addCurve(to: newPoint, control1: control1, control2: control2)
                        
                    } else {
                        let xPos:CGFloat = self.xPos(index: count)
                        let yPos:CGFloat = self.yPos(scale: item.value)
                        
                        context.addLine(to: CGPoint(x: xPos, y: yPos))
                    }
                    
                    count += 1
                }
            }
            
            context.strokePath()
        }
    }
    
    func xPos(index: Int) -> CGFloat {
        if items.count >= 2 {
            // Determine the x pos
            return xPos(x: CGFloat(index) /  CGFloat(items.count - 1))
        } else {
            return xPos(x: 0.5)
        }
    }
    
    func xPos(x: CGFloat) -> CGFloat {
        return ((x * 0.9) + 0.05) * self.bounds.width
    }
    
    func yPos(scale: Float) -> CGFloat {
        let yPos:CGFloat = ((CGFloat(scale) * 0.7) + 0.1) * self.bounds.height
        return yPos
    }
    
    func updateLabel(items: [GraphItem]) {
        self.items = items
        
        self.setNeedsDisplay()
        
        self.updateLabels()
    }
    
    private func updateLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()
        
        var count = 0
        
        for item in items {
            
            let xPos:CGFloat = self.xPos(index: count)
            let yPos:CGFloat = self.yPos(scale: item.value)
            
            let label = UILabel()
            
            let emoji = item.emoji.replacingOccurrences(of: "*", with: "")
            
            let font = UIFont.systemFont(ofSize: 26.0)
            
            label.text = emoji
            label.font = font
            
            let attrString = NSAttributedString(string: emoji, attributes: [NSFontAttributeName:font])
            
            let size = attrString.boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            
            let rect = CGRect(x: xPos - (size.width / 2) + 1, y: yPos - (size.height / 2), width: size.width, height: size.height)
            
            label.frame = rect
            
            self.addSubview(label)
            
            labels.append(label)
            
            let string = item.label
            
            // Add time text
            
            let timeFont = UIFont.systemFont(ofSize: 12.0)
            
            let timeLabel = UILabel()
            timeLabel.textColor = UIColor.white
            timeLabel.text = string
            timeLabel.font = timeFont
            timeLabel.textAlignment = NSTextAlignment.center
            
            let labelAttrString = NSAttributedString(string: string, attributes: [NSFontAttributeName:timeFont])
            
            let textSize = labelAttrString.boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            
            let newRect = CGRect(x: xPos - (textSize.width / 2) + 1, y: self.frame.height - textSize.height + 2, width: textSize.width, height: textSize.height)
            
            timeLabel.frame = newRect
            
            self.addSubview(timeLabel)
            labels.append(timeLabel)
            
            count += 1
        }
    }
    
}
