//
//  GraphView.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 27/03/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class GraphView:UIView {
    
    var results = [Float]() // Values between 0 and 1
    var dist = [Float]() // Values between 0 and 1
    var labelText = [String]() // If this string contains a '*' then we should put a gray circle behind it
    var timeText = [String]() // If this string is not empty it will be written underneath the result, centered.
    
    var labels = [UILabel]() // Labels that show the happy/sad symbols
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(4)
            
            // Get the max time and min time
            var count = 0
            
            // let width:CGFloat = self.bounds.width / CGFloat(results.count - 1)
            
            if results.count > 1 {
                for result in results {
                    
                    if count == 0 {
                        //let xPos:CGFloat = ((CGFloat(dist[count]) * 0.8) + 0.1) * self.bounds.width
                        let xPos:CGFloat = self.xPos(dist: dist[count])
                        //let yPos:CGFloat = (((CGFloat(result) * 0.8) + 0.1) * self.bounds.height)
                        let yPos:CGFloat = self.yPos(scale: result)
                        
                        context.move(to: CGPoint(x: xPos, y: yPos))
                    } else if count < results.count {
                        
                        let lastResult = results[count - 1]
                        let lastXPos:CGFloat = self.xPos(dist: dist[count - 1])
                        let lastYPos:CGFloat = self.yPos(scale: lastResult)
                        
                        let lastLinePoint = CGPoint(x: lastXPos, y: lastYPos)
                        
                        let xPos:CGFloat = self.xPos(dist: dist[count])
                        let yPos:CGFloat = self.yPos(scale: result)
                        
                        let newPoint = CGPoint(x: xPos, y: yPos)
                        let diffWidth:CGFloat = 0
                        
                        let control1 = CGPoint(x: lastLinePoint.x + diffWidth, y: lastLinePoint.y)
                        let control2 = CGPoint(x: newPoint.x - diffWidth, y: newPoint.y)
                        
                        context.addCurve(to: newPoint, control1: control1, control2: control2)
                        
                    } else {
                        let xPos:CGFloat = self.xPos(dist: dist[count])
                        let yPos:CGFloat = self.yPos(scale: result)
                        
                        context.addLine(to: CGPoint(x: xPos, y: yPos))
                    }
                    
                    count += 1
                }
            }
            
            context.strokePath()
            
            /*
             // Draw circle behind
            context.setFillColor(UIColor.moodBlue.cgColor)
            
            count = 0
            
            for result in results {
                
                var circleRadius:CGFloat = 0
                
                let label = labelText[count]
                
                if label.contains("*") {
                    circleRadius = 14
                }
                
                let xPos:CGFloat = self.xPos(dist: dist[count])
                let yPos:CGFloat = self.yPos(scale: result)
                
                let rect = CGRect(x: xPos - circleRadius, y: yPos - circleRadius, width: circleRadius * 2, height: circleRadius * 2)
                
                context.fillEllipse(in: rect)
                count += 1
            }
             */
        }
    }
    
    func xPos(dist: Float) -> CGFloat {
        let xPos:CGFloat = ((CGFloat(dist) * 0.9) + 0.05) * self.bounds.width
        return xPos
    }
    
    func yPos(scale: Float) -> CGFloat {
        let yPos:CGFloat = ((CGFloat(scale) * 0.8) + 0.1) * self.bounds.height
        return yPos
    }
    
    func updateLabels(results: [Float], dist: [Float], labels: [String], timeLabels: [String]) {
        self.results = results
        self.dist = dist
        self.labelText = labels
        self.timeText = timeLabels
        
        self.setNeedsDisplay()
        
        self.updateLabels()
    }
    
    private func updateLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()
        
        var count = 0
        
        for result in results {
            
            let xPos:CGFloat = self.xPos(dist: dist[count])
            let yPos:CGFloat = self.yPos(scale: result)
            
            let label = UILabel()
            
            let emoji = labelText[count].replacingOccurrences(of: "*", with: "")
            
            let font = UIFont.systemFont(ofSize: 26.0)
            
            label.text = emoji
            label.font = font
            
            let attrString = NSAttributedString(string: emoji, attributes: [NSFontAttributeName:font])
            
            let size = attrString.boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            
            let rect = CGRect(x: xPos - (size.width / 2) + 1, y: yPos - (size.height / 2), width: size.width, height: size.height)
            
            label.frame = rect
            
            self.addSubview(label)
            
            labels.append(label)
            
            if timeText.count > count {
                let string = timeText[count]
                
                // Add time text
                
                let timeFont = UIFont.systemFont(ofSize: 12.0)
                
                let timeLabel = UILabel()
                timeLabel.textColor = UIColor.white
                timeLabel.text = string
                timeLabel.font = timeFont
                timeLabel.textAlignment = NSTextAlignment.center
                
                let attrString = NSAttributedString(string: string, attributes: [NSFontAttributeName:timeFont])
                
                let textSize = attrString.boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
                
                let newRect = CGRect(x: xPos - (textSize.width / 2) + 1, y: self.frame.height - textSize.height + 2, width: textSize.width, height: textSize.height)
                
                timeLabel.frame = newRect
                
                self.addSubview(timeLabel)
                labels.append(timeLabel)
            }
            
            count += 1
        }
    }
    
}
