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
    
    var labels = [UILabel]() // Labels that show the happy/sad symbols
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.gray.cgColor)
            context.setLineWidth(1)
            
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
            
            if let color = self.backgroundColor {
                context.setFillColor(color.cgColor)
            } else {
                context.setFillColor(UIColor.lightGray.cgColor)
            }
            
            count = 0
            
            for result in results {
                
                var circleRadius:CGFloat = 0
                
                let label = labelText[count]
                
                if label.contains("*") {
                    circleRadius = 8
                }
                
                let xPos:CGFloat = self.xPos(dist: dist[count])
                let yPos:CGFloat = self.yPos(scale: result)
                
                let rect = CGRect(x: xPos - circleRadius, y: yPos - circleRadius, width: circleRadius * 2, height: circleRadius * 2)
                
                context.fillEllipse(in: rect)
                count += 1
            }
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
    
    func updateLabels(results: [Float], dist: [Float], labels: [String]) {
        self.results = results
        self.dist = dist
        self.labelText = labels
        
        self.setNeedsDisplay()
        
        self.updateLabels()
    }
    
    private func updateLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()
        
        var count = 0
        
        print("results.count: \(results.count)")
        print("labelText.count: \(labelText.count)")
        print("")
        
        for result in results {
            
            let xPos:CGFloat = self.xPos(dist: dist[count])
            let yPos:CGFloat = self.yPos(scale: result)
            
            print("xPos: \(xPos)")
            print("yPos: \(yPos)")
            
            let label = UILabel()
            
            let emoji = labelText[count].replacingOccurrences(of: "*", with: "")
            
            print("emoji: \(emoji)")
            
            label.text = emoji
            label.font = UIFont.systemFont(ofSize: 14.0)
            
            let attrString = NSAttributedString(string: emoji, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14.0)])
            
            let size = attrString.boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            
            print("size: \(size)")
            
            let rect = CGRect(x: xPos - (size.width / 2) + 1, y: yPos - (size.height / 2), width: size.width, height: size.height)
            
            print("rect: \(rect)")
            
            label.frame = rect
            
            self.addSubview(label)
            
            labels.append(label)
            count += 1
        }
    }
    
}
