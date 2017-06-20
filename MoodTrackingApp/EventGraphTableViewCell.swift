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
    var name = ""
    
    convenience init(averageLinearMood: Float, date: Date?) {
        
        self.init()
        
        var newMoodEmoji = DataFormatter.emoji(typeInt: 0)
        
        if averageLinearMood >= 0.8 {
            // Excited
            newMoodEmoji = DataFormatter.emoji(typeInt: EventType.excited.rawValue)
            name = "excited"
        } else if averageLinearMood >= 0.5 {
            // Happy
            newMoodEmoji = DataFormatter.emoji(typeInt: EventType.happy.rawValue)
            name = "happy"
        } else if averageLinearMood >= 0.3 {
            // Calm
            newMoodEmoji = DataFormatter.emoji(typeInt: EventType.calm.rawValue)
            name = "calm"
        } else if averageLinearMood >= -0.3 {
            // Neutral
            newMoodEmoji = DataFormatter.emoji(typeInt: EventType.neutral.rawValue)
            name = "neutral"
        } else if averageLinearMood >= -0.5 {
            // Down
            newMoodEmoji = DataFormatter.emoji(typeInt: EventType.down.rawValue)
            name = "down"
        } else if averageLinearMood >= -0.8 {
            // Sad
            newMoodEmoji = DataFormatter.emoji(typeInt: EventType.sad.rawValue)
            name = "sad"
        } else {
            // Depressed
            newMoodEmoji = DataFormatter.emoji(typeInt: EventType.depressed.rawValue)
            name = "depressed"
        }
        
        // Generate this new average mood
        self.emoji = newMoodEmoji.emoji
        self.linearMood = averageLinearMood
        
        if let date = date {
            self.date = date
        }
    }
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
        
        let bundle = DataFormatter.emoji(typeInt: Int(event.type))
        
        newGraphEvent.emoji = bundle.emoji
        newGraphEvent.linearMood = bundle.linearMood
        
        if let date = event.date {
            newGraphEvent.date = date as Date
        }
        
        if event.type >= 1000 {
            // Event
            newGraphEvent.type = ItemType.event
        } else {
            // Mood
            newGraphEvent.type = ItemType.mood
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
                    let moodEmoji = DataFormatter.emoji(typeInt: Int(event.type))
                    
                    if let date = event.date {
                        let moodDate = df.string(from: date as Date)
                        
                        if currentDate != moodDate {
                            // New date! Add the linear mood.
                            
                            if moodCount > 0 {
                                
                                let averageLinearMood = moodAverage / Float(moodCount)
                                
                                let newGraphEvent = GraphEvent(averageLinearMood: averageLinearMood, date: lastDate)
                                newEvents.append(newGraphEvent)
                            }
                            
                            moodAverage = 0
                            moodCount = 0
                            
                            currentDate = moodDate
                            lastDate = date as Date
                        }
                        
                        if let linearMood = moodEmoji.linearMood {
                            // Adding to the current one
                            moodAverage += linearMood
                            moodCount += 1
                        }
                    }
                }
            }
            
            // Deal with the final mood
            
            if moodCount > 0 {
                let averageLinearMood = moodAverage / Float(moodCount)
                
                let newGraphEvent = GraphEvent(averageLinearMood: averageLinearMood, date: lastDate)
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
