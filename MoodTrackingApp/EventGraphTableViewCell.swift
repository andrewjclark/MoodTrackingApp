//
//  EventGraphTableViewCell.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 31/05/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class GraphEvent:Equatable {
    var emoji = ""
    var linearMood:Float?
    var date = Date()
    var type = ItemType.mood
}

func ==(lhs: GraphEvent, rhs: GraphEvent) -> Bool {
    return lhs.linearMood == rhs.linearMood && lhs.emoji == rhs.emoji && lhs.date == rhs.date
}



public enum DisplayFormat {
    case time
    case weekday
    case day
}

class EventGraphTableViewCell:UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var graphView: GraphView!
    
    var rawEvents = [Event]()
    
    var type = GroupType.day
    
    var displayFormat = DisplayFormat.time
    
    func layout(events: [Event], title: String) {
        
        self.rawEvents = events
        
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
        
        // Average the data as needed.
        processEvents()
        
        DispatchQueue.main.async { [weak self] in
            self?.drawLine()
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        setSelected(highlighted, animated: animated)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            mainView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            graphView.backgroundColor = UIColor.clear
        } else {
            mainView.backgroundColor = UIColor.clear
            graphView.backgroundColor = UIColor.clear
        }
    }
    
    func processEvents() {
        // events = newEvents
    }
    
    func graphEvent(event: Event) -> GraphEvent {
        
        let newGraphEvent = GraphEvent()
        
        if event.type >= 1000 {
            // Event
            let bundle = DataFormatter.eventEmoji(typeInt: Int(event.type))
            
            newGraphEvent.emoji = bundle.emoji
            newGraphEvent.type = .event
        } else {
            // Mood
            let bundle = DataFormatter.moodEmoji(typeInt: Int(event.type))
            
            newGraphEvent.emoji = bundle.emoji
            newGraphEvent.linearMood = bundle.linearMood
            
            newGraphEvent.type = .mood
        }
        
        if let date = event.date {
            newGraphEvent.date = date as Date
        }
        
        return newGraphEvent
    }
    
    
    func graphEvents(rawEvents: [Event]) -> [GraphEvent] {
        
        var newEvents = [GraphEvent]()
        
        if self.type == .month || self.type == .custom {
            
            // This is a month, need to average it out.
            let df = DateFormatter()
            df.dateFormat = "DD MMM YYYY"
            
            var currentDate = ""
            var lastDate = Date()
            var moodAverage:Float = 0
            var moodCount = 0
            
            for event in rawEvents {
                
                if event.type < 1000 {
                    // It's a mood
                    let moodEmoji = DataFormatter.moodEmoji(typeInt: Int(event.type))
                    
                    if let date = event.date {
                        let moodDate = df.string(from: date as Date)
                        
                        if currentDate != moodDate {
                            // New date! Add it if needed.
                            
                            if moodCount > 0 {
                                let averageMood = moodAverage / Float(moodCount)
                                
                                var newMoodEmoji = DataFormatter.moodEmoji(typeInt: 0)
                                
                                if averageMood >= -1 {
                                    // Sad
                                    newMoodEmoji = DataFormatter.moodEmoji(type: EventType.sad)
                                }
                                
                                if averageMood >= -0.6 {
                                    // Down
                                    newMoodEmoji = DataFormatter.moodEmoji(type: EventType.down)
                                }
                                
                                if averageMood >= -0.2 {
                                    // Neutral
                                    newMoodEmoji = DataFormatter.moodEmoji(type: EventType.neutral)
                                }
                                
                                if averageMood >= 0.2 {
                                    // Calm
                                    newMoodEmoji = DataFormatter.moodEmoji(type: EventType.calm)
                                }
                                
                                if averageMood >= 0.6 {
                                    // Great
                                    newMoodEmoji = DataFormatter.moodEmoji(type: EventType.excited)
                                }
                                
                                // Add this new average mood
                                
                                let newGraphEvent = GraphEvent()
                                newGraphEvent.emoji = newMoodEmoji.emoji
                                newGraphEvent.date = lastDate
                                newGraphEvent.linearMood = averageMood
                                
                                newEvents.append(newGraphEvent)
                            }
                            
                            moodAverage = 0
                            moodCount = 0
                            
                            currentDate = moodDate
                            lastDate = date as Date
                        }
                        
                        // Adding to the current one
                        moodAverage += moodEmoji.linearMood
                        moodCount += 1
                    }
                }
            }
            
            // Deal with the final mood
            
            if moodCount > 0 {
                let averageMood = moodAverage / Float(moodCount)
                
                var newMoodEmoji = DataFormatter.moodEmoji(typeInt: 0)
                var newMoodType = 0
                
                if averageMood >= -1 {
                    // Sad
                    newMoodEmoji = DataFormatter.moodEmoji(type: EventType.sad)
                    newMoodType = EventType.sad.rawValue
                }
                
                if averageMood >= -0.6 {
                    // Down
                    newMoodEmoji = DataFormatter.moodEmoji(type: EventType.down)
                    newMoodType = EventType.down.rawValue
                }
                
                if averageMood >= -0.2 {
                    // Neutral
                    newMoodEmoji = DataFormatter.moodEmoji(type: EventType.neutral)
                    newMoodType = EventType.neutral.rawValue
                }
                
                if averageMood >= 0.2 {
                    // Calm
                    newMoodEmoji = DataFormatter.moodEmoji(type: EventType.calm)
                    newMoodType = EventType.calm.rawValue
                }
                
                if averageMood >= 0.6 {
                    // Great
                    newMoodEmoji = DataFormatter.moodEmoji(type: EventType.excited)
                    newMoodType = EventType.excited.rawValue
                }
                
                // Add this new average mood
                
                let newGraphEvent = GraphEvent()
                newGraphEvent.emoji = newMoodEmoji.emoji
                newGraphEvent.date = lastDate as Date
                newGraphEvent.linearMood = averageMood
                
                newEvents.append(newGraphEvent)
            }
            
        } else if self.type == .day {
            for event in rawEvents {
                newEvents.append(self.graphEvent(event: event))
            }
        }
        
        return newEvents
    }
    
    func drawLine() {
        
        let newEvents = graphEvents(rawEvents: rawEvents)
        
        var graphItems = [GraphItem]()
        
        let df = DateFormatter()
        var capitaliseDate = false
        var dateNeedsEndingLetters = false
        
        if displayFormat == .time {
            df.dateFormat = "h a"
        } else if displayFormat == .weekday {
            df.dateFormat = "EEE d"
            capitaliseDate = true
        } else if displayFormat == .day {
            
            if type == .month {
                df.dateFormat = "d"
                dateNeedsEndingLetters = true
            } else {
                df.dateFormat = "MMM d"
                dateNeedsEndingLetters = false
                capitaliseDate = true
            }
        }
        
        if newEvents.count > 0 {
            
            var count = 0
            var lastResult:Float = 0.5
            var timeLabelFreq = Int(round(Float(newEvents.count) / Float(7)))
            
            if timeLabelFreq < 1 {
                timeLabelFreq = 1
            }
            
            var lastTimeLabel = ""
            var lastEmojiLabel = ""
            
            
            
            for result in newEvents {
                
                let newGraphItem = GraphItem()
                
                if result.type == .event {
                    // Event
                    newGraphItem.emoji = result.emoji
                    
                    lastEmojiLabel = result.emoji
                    
                    newGraphItem.value = lastResult
                    
                } else {
                    // Mood
                    
                    var shouldShowEmoji = false
                    
                    if newEvents.count > 7 {
                        
                        // Only log changes in direction...
                        
                        if result != newEvents.first && result != newEvents.last {
                            // We are somewhere in the middle
                            
                            if let index = newEvents.index(of: result) {
                                let previousEvent = newEvents[index-1]
                                let nextEvent = newEvents[index+1]
                                
                                // Now, look at these events...
                                // If the prev is smaller than current and next is also smaller then we have changed direction
                                
                                if let currentValue = result.linearMood, let prevValue = previousEvent.linearMood, let nextValue = nextEvent.linearMood {
                                    
                                    if prevValue <= currentValue && nextValue < currentValue {
                                        // Changed direction!
                                        shouldShowEmoji = true
                                    } else if prevValue >= currentValue && nextValue > currentValue {
                                        // Changed direction!
                                        shouldShowEmoji = true
                                    }
                                    
                                } else {
                                    shouldShowEmoji = true
                                }
                            }
                        } else {
                            // We are the first or last. Show em
                            shouldShowEmoji = true
                        }
                        
                        /*
                         // Conditionally set the emoji
                         if lastEmojiLabel != result.emoji {
                         shouldShowEmoji = true
                         newGraphItem.emoji = result.emoji
                         } else if result == newEvents.last {
                         shouldShowEmoji = true
                         }
                         */
                        
                    } else {
                        // Always set the emoji
                        shouldShowEmoji = true
                    }
                    
                    if shouldShowEmoji {
                        newGraphItem.emoji = result.emoji
                    }
                    
                    lastEmojiLabel = result.emoji
                    
                    // newGraphItem.emoji = result.emoji
                    
                    if let linearMood = result.linearMood {
                        let scale = (linearMood - 1) / -2
                        newGraphItem.value = Float(scale)
                        lastResult = scale
                    } else {
                        newGraphItem.value = lastResult
                    }
                }
                
                var newTimeLabel = ""
                
                // Add date as timelabel
                if count % timeLabelFreq == 0 || count == rawEvents.count - 1 {
                    
                    // If the last time label is the same then don't show it
                    let date = result.date
                    newTimeLabel = df.string(from: date as Date)
                    
                    if dateNeedsEndingLetters {
                        newTimeLabel += DataFormatter.integerEndingLetters(string: newTimeLabel)
                    }
                    
                    if newTimeLabel == lastTimeLabel && count != rawEvents.count - 1 {
                        newTimeLabel = ""
                    }
                    
                }
                
                if newTimeLabel != "" {
                    lastTimeLabel = newTimeLabel
                }
                
                if capitaliseDate {
                    newGraphItem.label = newTimeLabel.lowercased().capitalized
                } else {
                    newGraphItem.label = newTimeLabel.lowercased()
                }
                
                graphItems.append(newGraphItem)
                
                count += 1
            }
            
            // Update the labels
            graphView.updateLabel(items: graphItems)
            
        } else {
            // Clear it out
            graphView.updateLabel(items: [GraphItem]())
        }
    }
    
}
