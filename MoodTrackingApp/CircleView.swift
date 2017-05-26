//
//  CircleView.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 23/05/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

protocol CircleViewDelegate:class {
    func userSelected(indexPath: IndexPath?, item: CircleItem?)
}

class CircleView:UIView {
    
    var delegate:CircleViewDelegate?
    
    var dataSet = [[CircleItem]]()
    
    var selectedItem:IndexPath?
    
    let NoOfGlasses = 8
    let π:CGFloat = CGFloat(M_PI)
    
    var labels = [UILabel]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
        self.backgroundColor = UIColor.clear
    }
    
    func drawSegment(row: Int, section: Int, numberOfSegments: Int, numberOfRings: Int, color: UIColor, context: CGContext, emoji: String) {
        
        let geoSet = calculateAngles(row: row, section: section, numberOfSegments: numberOfSegments, numberOfRings: numberOfRings)
        
        let path = UIBezierPath(arcCenter: geoSet.center,
                                radius: geoSet.radiusMiddle,
                                startAngle: geoSet.startAngle,
                                endAngle: geoSet.endAngle,
                                clockwise: true)
        
        path.lineWidth = geoSet.arcWidth
        color.setStroke()
        path.stroke()
        
        context.strokePath()
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let context = UIGraphicsGetCurrentContext() {
            
            let numberOfRings = dataSet.count
            
            var sectionCount = 0
            
            for section in dataSet {
                
                var itemCount = 0
                
                for item in section {
                    
                    var color = UIColor(white: 0.8, alpha: 0.5)
                    
                    if let selectedItem = selectedItem {
                        if itemCount == selectedItem.row && sectionCount == selectedItem.section {
                            color = UIColor(red: 0.25, green: 0.25, blue: 1.0, alpha: 1.0)
                        }
                    }
                    
                    self.drawSegment(row: itemCount, section: sectionCount, numberOfSegments: section.count, numberOfRings: dataSet.count, color: color, context: context, emoji:"A")
                    
                    itemCount += 1
                }
                
                sectionCount += 1
            }
        }
    }
    
    func drawEmoji() {
        
        
        // Remove all the labels
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()
        
        
        let numberOfRings = dataSet.count
        
        var sectionCount = 0
        
        for section in dataSet {
            
            var itemCount = 0
            
            for item in section {
                
                var emojiString = ""
                
                if let string = item.emoji {
                    emojiString = string
                }
                    
                self.drawEmoji(row: itemCount, section: sectionCount, numberOfSegments: section.count, numberOfRings: dataSet.count, color: UIColor.red, emoji:emojiString)
                
                itemCount += 1
            }
            
            sectionCount += 1
        }
    }
    
    func drawEmoji(row: Int, section: Int, numberOfSegments: Int, numberOfRings: Int, color: UIColor, emoji: String) {
        
        let geoSet = calculateAngles(row: row, section: section, numberOfSegments: numberOfSegments, numberOfRings: numberOfRings)
        
        let label = UILabel()
        
        label.text = emoji
        
        let fontSize:CGFloat = 30
        
        label.font = UIFont.systemFont(ofSize: fontSize)
        
        let attrString = NSAttributedString(string: emoji, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize)])
        
        let size = attrString.boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        //print("size: \(size)")
        
        let rect = CGRect(x: geoSet.segmentCenterPoint.x - (size.width / 2) + 1, y: geoSet.segmentCenterPoint.y - (size.height / 2), width: size.width, height: size.height)
        
        label.frame = rect
        label.alpha = 1.0
        self.addSubview(label)
        
        labels.append(label)
    }
    
    func calculateAngles(row: Int, section: Int, numberOfSegments: Int, numberOfRings: Int) -> (startAngle: CGFloat, endAngle: CGFloat, radius:CGFloat, radiusMiddle:CGFloat, arcWidth: CGFloat, center:CGPoint, segmentCenterPoint:CGPoint) {
        
        let idealBorder:CGFloat = 5.0
        
        let ringSpokes = numberOfRings * 2
        
        let radius:CGFloat = (self.bounds.width / CGFloat(ringSpokes)) * (CGFloat(section) + 1)
        
        var arcWidth: CGFloat = (self.bounds.width / CGFloat(ringSpokes)) - 5
        
        if section == 0 {
            arcWidth = radius
        }
        
        let segmentSize:CGFloat = (2 * π) / CGFloat(numberOfSegments)
        let circumference = 2 * π * radius
        
        let borderAngle = ((idealBorder + 1) / circumference) * (2 * π) // Not sure why this works
        
        let originAngle:CGFloat = (π * (1/6)) * -5
        
        var startAngle = originAngle + CGFloat(row) * segmentSize + (borderAngle / 2)
        var endAngle = startAngle + (segmentSize - borderAngle)
        
        if section == 0 {
            startAngle = 0
            endAngle = segmentSize
        }
        
        // Find the center arc position for this.
        
        let midAngle = (startAngle + endAngle) / 2
        let emojiRadius = radius - (arcWidth / 2)
        
        let center = CGPoint(x:self.bounds.width/2, y: self.bounds.width/2)
        
        var opposite =  CGFloat(sinf(Float(midAngle)) * Float(emojiRadius))
        var adjacent =  CGFloat(cosf(Float(midAngle)) * Float(emojiRadius))
        
        if section == 0 {
            opposite = 0
            adjacent = 0
        }
        
        return (startAngle: startAngle, endAngle: endAngle, radius:radius, radiusMiddle: radius - (arcWidth / 2), arcWidth:arcWidth, center:center, segmentCenterPoint:CGPoint(x: center.x + adjacent, y: center.y + opposite))
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            processTouch(location: location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            processTouch(location: location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            processTouch(location: location)
        }
    }
    
    
    
    func processTouch(location: CGPoint) {
        let center = CGPoint(x:self.bounds.width/2, y: self.bounds.width/2)
        
        let xDist = location.x - center.x
        let yDist = location.y - center.y
        
        let angle = atan2(yDist, xDist)
        //print("angle: \(angle)")
        
        let distance = sqrt(yDist*yDist + xDist*xDist)
        //print("distance: \(distance)")
        
        // Determine which ring it is in, given the dataSet
        
        let ringSpokes = dataSet.count * 2
        
        // If there are 3 rings then
        
        var arcWidth: CGFloat = (self.bounds.width / CGFloat(ringSpokes)) - 5
        
        // The inner radius
        let radius:CGFloat = (self.bounds.width / CGFloat(ringSpokes))
        
//        print("arcWidth: \(arcWidth)")
//        print("radius: \(radius)")
        
        var section = Int(distance / radius)
        
        var currentSelectedItem = IndexPath(item: 1000, section: 1000)
        
        if let selectedItem = selectedItem {
            currentSelectedItem = selectedItem
        }
        
        if section > dataSet.count - 1 {
            //print("Out of bounds!")
            //selectedItem = nil
        } else {
            //print("section: \(section)")
            
            // Look at how the angle divides
            
            let items = dataSet[section]
            
            // Size of a single item is
            let angleSize:CGFloat = (2 * π) / CGFloat(items.count)
            
            //print("angleSize: \(angleSize)")
            
            let originAngle:CGFloat = (π * (1/6)) * -5
            
            var consolidatedAngle = angle - originAngle
            
            if consolidatedAngle < 0 {
                consolidatedAngle += (2 * π)
            }
            
            var itemIndex = Int((consolidatedAngle) / angleSize)
            
            //print("angle - originAngle: \(angle - originAngle)")
            
            //print("itemIndex: \(itemIndex)")
            
            // We now have an itemIndex and a section
            selectedItem = IndexPath(row: itemIndex, section: section)
        }
        
        if selectedItem != currentSelectedItem {
            
            if let selectedItem = selectedItem {
                let item = dataSet[selectedItem.section][selectedItem.row]
                
                delegate?.userSelected(indexPath: selectedItem, item: item)
            } else {
                delegate?.userSelected(indexPath: nil, item: nil)
            }
            
            // Reload the view
            self.setNeedsDisplay()
        }
    }
    
    func currentSelectedItem() -> (indexPath: IndexPath?, item: CircleItem?) {
        if let selectedItem = selectedItem {
            let item = dataSet[selectedItem.section][selectedItem.row]
            
            return (indexPath: selectedItem, item: item)
        } else {
            return (indexPath: nil, item: nil)
        }
    }
}

extension UIColor {
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}

