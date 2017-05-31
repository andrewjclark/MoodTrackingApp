//
//  EventGraphTableViewCell.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 31/05/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class EventGraphTableViewCell:UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var graphView: GraphView!
    
    var events = [Event]()
    var type = GroupType.day
    
    func layout(events: [Event], title: String) {
        
        self.events = events
        
        mainView.backgroundColor = UIColor.clear
        mainView.layer.borderWidth = 1.0
        mainView.layer.borderColor = UIColor.white.cgColor
        
        graphView.backgroundColor = UIColor.moodBlue
        
        mainLabel.text = title
        
        if events.count > 0 {
            infoLabel.text = nil
        } else {
            infoLabel.text = "No Data"
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.drawLine()
        }
    }
    
    func drawLine() {
        
        if events.count > 0 {
            
            var subResults = [Any]()
            
            /*
            if events.count > 10 {
                subResults = Array(events[0...10])
            } else {
                subResults = events
            }
             */
            
            subResults = events
            
            var width:Float = 0.5
            
            if subResults.count > 1 {
                width = 1.0 / Float(subResults.count - 1)
            }
            
            var items = [Float]()
            var dists = [Float]()
            var labels = [String]()
            var timeLabels = [String]()
            
            var count = 0
            var lastResult:Float = 0.5
            var timeLabelFreq = Int(round(Float(subResults.count) / Float(7)))
            
            if timeLabelFreq < 1 {
                timeLabelFreq = 1
            }
            
            var lastTimeLabel = ""
            
            let df = DateFormatter()
            df.dateFormat = "h a"
            
            if self.type == .month {
                df.dateFormat = "d"
            }
            
            
            for result in subResults {
                
                if let result = result as? Event {
                    
                    if result.type >= 1000 {
                        // Event
                        let eventEmoji = DataFormatter.emoji(typeInt: Int(result.type))
                        
                        labels.append(eventEmoji.emoji + "*")
                        
                        items.append(Float(lastResult))
                        
                        let xPos:Float = 0 + (width * Float(count))
                        
                        dists.append(xPos)
                    } else {
                        // Mood
                        
                        let moodEmoji = DataFormatter.moodEmoji(typeInt: Int(result.type))
                        
                        labels.append(moodEmoji.emoji)
                        
                        let scale = (moodEmoji.linearMood - 1) / -2
                        
                        lastResult = scale
                        items.append(Float(scale))
                        
                        var xPos:Float = 0 + (width * Float(count))
                        
                        if subResults.count == 1 {
                            xPos = 0.5
                        }
                        
                        dists.append(xPos)
                    }
                    
                    var newTimeLabel = ""
                    
                    // Add date as timelabel
                    if count % timeLabelFreq == 0 || count == subResults.count - 1 {
                        
                        // If the last time label is the same then don't show it?
                        
                        if let date = result.date {
                            
                            newTimeLabel = df.string(from: date as Date)
                            
                            if newTimeLabel == lastTimeLabel && count != subResults.count - 1 {
                                newTimeLabel = ""
                            }
                        }
                    }
                    
                    if newTimeLabel != "" {
                        lastTimeLabel = newTimeLabel
                    }
                    
                    timeLabels.append(newTimeLabel.lowercased())
                    
                    
                    
                    count += 1
                }
            }
            
            // Update the labels
            
            graphView.updateLabels(results: items, dist: dists, labels: labels, timeLabels: timeLabels)
            
        } else {
            // Clear it out
            graphView.updateLabels(results: [Float](), dist: [Float](), labels: [String](), timeLabels: [String]())
        }
    }
    
}
