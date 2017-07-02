//
//  DataAnalyser.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 19/06/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit


class EventCount:CustomStringConvertible {
    var type = 0
    var count = 0
    
    var description: String {
        return "type: \(type) count: \(count)"
    }
}

class DataAnalyser {
    var highestAllTime:Event?
    var lowestAllTime:Event?
    var averageMood:GraphEvent?
    
    var eventCounts = [EventCount]()
    var moodsCounts = [EventCount]()
    var eventCorrelations = [EventCorrelation]()
    var topEventCorrelations = [EventCorrelation]()
    var numberOfSignificantCorrelations = 0
    
    var totalEventCount = 0
    var totalMoodCount = 0
    
    var moodBreakDown = [Int:Int]() // Integer mood counts for grouping by linearMood // -2 for sad, -1 for down, 0 for neutral, 1 for calm/good, 2 for great
    var totalMoodsBreakdown = 0
    
    static let sharedAnalyser = DataAnalyser()
    private init () {}
    
    func anaylseData() {
        shallowAnalysis()
        performCausalAnalysis()
    }
    
    private func shallowAnalysis() {
        
        if let fetched = DataStore.shared.fetchEvents(startDate: Date().startOfDay(offset: -30), endDate: Date()) {
            print(fetched.count)
            
            // Iterate through all of the moods. Get the high. Low. And average
            
            var highestMoodEvent:Event?
            var highestMood:Float = 0
            
            var lowestMoodEvent:Event?
            var lowestMood:Float = 0
            
            var averageMood:Float = 0
            var moodCount = 0
            
            // These variables are used for talling the day and processing this.
            
            var occurenceCount = [Int:Int]()
            var moodOccurenceCount = [Int:Int]()
            
            self.moodBreakDown.removeAll()
            
            let df = DateFormatter()
            df.dateFormat = "DD MMM YYYY"
            
            for event in fetched {
                
                let emoji = DataFormatter.emoji(typeInt: Int(event.type))
                
                if let linearMood = emoji.linearMood {
                    if linearMood >= highestMood {
                        highestMoodEvent = event
                        highestMood = linearMood
                    } else if linearMood <= lowestMood {
                        lowestMoodEvent = event
                        lowestMood = linearMood
                    }
                    
                    averageMood += linearMood
                    moodCount += 1
                    
                    var moodType:Int = 0
                    
                    if linearMood > 0.4 {
                        moodType = 1
                    } else if linearMood < -0.4 {
                        moodType = -1
                    }
                    
                    if var c = moodBreakDown[moodType] {
                        c += 1
                        moodBreakDown[moodType] = c
                    } else {
                        moodBreakDown[moodType] = 1
                    }
                    
                }
                
                if let date = event.date {
                    
                    //df.dateFormat = "d/M/YYY hh:mm a"
                    //df.dateFormat = "D"
                    
                    df.dateFormat = "hh:mm a"
                    
                    print(df.string(from: date as Date))
                }
                
                //print(emoji.name)
                
                
                if emoji.type == .event {
                    if var c = occurenceCount[Int(event.type)] {
                        c += 1
                        occurenceCount[Int(event.type)] = c
                    } else {
                        occurenceCount[Int(event.type)] = 1
                    }
                } else if emoji.type == .mood {
                    if var c = moodOccurenceCount[Int(event.type)] {
                        c += 1
                        moodOccurenceCount[Int(event.type)] = c
                    } else {
                        moodOccurenceCount[Int(event.type)] = 1
                    }
                }
            }
            
            var newOccs = [EventCount]()
            
            var eventCount = 0
            
            for (type, count) in occurenceCount {
                let newOcc = EventCount()
                newOcc.type = type
                newOcc.count = count
                eventCount += count
                
                newOccs.append(newOcc)
            }
            
            newOccs.sort(by: { (eventA, eventB) -> Bool in
                return eventA.count > eventB.count
            })
            
            self.eventCounts = newOccs
            self.totalEventCount = eventCount
            
            var newMoodOccs = [EventCount]()
            
            var newMoodCount = 0
            
            for (type, count) in moodOccurenceCount {
                let newOcc = EventCount()
                newOcc.type = type
                newOcc.count = count
                newMoodCount += count
                
                newMoodOccs.append(newOcc)
            }
            
            newMoodOccs.sort(by: { (eventA, eventB) -> Bool in
                return eventA.count > eventB.count
            })
            
            self.moodsCounts = newMoodOccs
            self.totalMoodCount = newMoodCount
            
            // Mood Summary - ensure there is a -2,-1,0,1,2 of each mood summary
            
            for number in -1...1 {
                if moodBreakDown[number] == nil {
                    moodBreakDown[number] = 0
                }
            }
            
            self.totalMoodsBreakdown = moodCount
            
//            print("highestMoodEvent: \(highestMoodEvent)")
//            print("lowestMoodEvent: \(lowestMoodEvent)")
//            print("newOccs: \(newOccs)")
//            print("totalEventCount: \(totalEventCount)")
//            print("moodBreakDown: \(moodBreakDown)")
            
            self.highestAllTime = highestMoodEvent
            self.lowestAllTime = lowestMoodEvent
            self.averageMood = nil
            
            if moodCount > 0 {
                averageMood = averageMood / Float(moodCount)
                self.averageMood = GraphEvent(averageLinearMood: averageMood, date: nil)
            }
        }
    }
    
    private func performCausalAnalysis() {
        
        if let fetchedEvents = DataStore.shared.fetchEvents(startDate: Date().startOfDay(offset: -30), endDate: Date()) {
            print(fetchedEvents.count)
            
            var eventBuffer = [Event]()
            var correlations = [Correlation]()
            
            for event in fetchedEvents.reversed() {
                
                if let eventDate = event.date {
                    if event.type >= 1000 {
                        // This is an event, add it to the buffer.
                        eventBuffer.append(event)
                    } else {
                        // This is a mood!
                        // Clear the buffer, Krunk
                        
                        // Remove any buffered events that are too much earlier than this event.
                        eventBuffer = eventBuffer.filter({ (event) -> Bool in
                            
                            if let bufferDate = event.date {
                                
//                                print("bufferDate      : \(bufferDate)")
//                                print("eventDate       : \(eventDate)")
                                
                                let interval:TimeInterval = 3 * 60 * 60 * -1
//                                print("eventDate - \(interval): \((eventDate as Date).addingTimeInterval(interval))")
                                
                                if (bufferDate as Date) > (eventDate as Date).addingTimeInterval(interval) {
                                    // It's within the range
                                    return true
                                }
                            }
                            
                            return false
                        })
                        
                        for bufferedEvent in eventBuffer {
                            if let bufferedEventDate = bufferedEvent.date {
                                
                                let correlation = Correlation()
                                
                                // Assign the buffered event details
                                correlation.eventType = Int(bufferedEvent.type)
                                correlation.eventDate = bufferedEventDate as Date
                                
                                // Assign the mood we found
                                correlation.moodType = Int(event.type)
                                correlation.moodDate = eventDate as Date
                                
                                // Now we have a correlation object that links this buffered event with the mood we found. Add it to the correlations array.
                                correlations.append(correlation)
                            }
                        }
                        
                        //eventBuffer.removeAll()
                    }
                }
            }
            
            //print("correlations: \(correlations)")
            
            self.eventCorrelations = summariseCorrelations(correlations: correlations)
            self.topEventCorrelations = self.eventCorrelations
            
            self.topEventCorrelations.sort(by: { (eventA, eventB) -> Bool in
                return eventA.correlationConfidence() > eventB.correlationConfidence()
            })
            
            
            // See how many of these topEventCorrelations are significant, set numberOfSignificantCorrelations
            
            self.numberOfSignificantCorrelations = 0
            
            for correlation in self.topEventCorrelations {
                if correlation.correlationConfidence() > 0.3 {
                    self.numberOfSignificantCorrelations += 1
                } else {
                    break
                }
            }
            
//            print("self.eventCorrelations: \(self.eventCorrelations)")
//            print("self.topEventCorrelations: \(self.topEventCorrelations)")
//            print("numberOfSignificantCorrelations: \(numberOfSignificantCorrelations)")
        }
    }
    
    
    func summariseCorrelations(correlations: [Correlation]) -> [EventCorrelation] {
        
        // We now have a bunch of correlations between events and moods. We want to distill this down and determine the average change in mood caused by each event type.
        
        var eventShift = [Int:[Correlation]]() // This dict groups together all of the linear moods caused by each eventType. We can then average them out
        
        for correlation in correlations {
            
            let moodType = correlation.eventType
            let eventType = correlation.moodType
            
            if let linearMood = DataFormatter.emoji(typeInt: eventType).linearMood {
                
                if var floatArray = eventShift[moodType] {
                    floatArray.append(correlation)
                    eventShift[moodType] = floatArray
                } else {
                    eventShift[moodType] = [correlation]
                }
            }
        }
        
        var eventCorrelations = [EventCorrelation]()
        
        for (eventType, correlationArray) in eventShift {
            
            let newEventCorrelation = EventCorrelation()
            newEventCorrelation.eventType = eventType
            
            var floatArray = [Float]()
            var weightArray = [Float]()
            
            for correlation in correlationArray {
                if let linearMood = DataFormatter.emoji(typeInt: correlation.moodType).linearMood {
                    floatArray.append(linearMood)
                    weightArray.append(correlation.weight())
                }
            }
            
            // Add up the linear moods
            var averageLinearMood:Float = 0
            
            if floatArray.count > 0 && floatArray.count == weightArray.count {
                
                // Add up the weighted average. We do this by multiplying each floatMood by it's weight, then divide all of that by the sum of all of the weights
                
                var weightToDivide:Float = 0
                
                for index in 0...floatArray.count-1 {
                    
                    let linearMood = floatArray[index]
                    let weight = weightArray[index]
                    
                    averageLinearMood += linearMood * weight
                    weightToDivide += weight
                }
                
                averageLinearMood = averageLinearMood / weightToDivide
                
                // Now we have the average, we can determine the standard deviation
                
                var deviance:Float = 0
                
                for float in floatArray {
                    let difference = float - averageLinearMood
                    
                    deviance += pow(difference, 2)
                }
                
                deviance = deviance / Float(floatArray.count)
                
                let standardDeviation = sqrt(deviance)
                
                newEventCorrelation.standardDeviation = standardDeviation
                newEventCorrelation.averageLinearMood = averageLinearMood
                newEventCorrelation.linearMoodCount = floatArray.count
                
                eventCorrelations.append(newEventCorrelation)
            }
        }
        
        //print("eventShift: \(eventShift)")
        
        //print("eventCorrelations: \(eventCorrelations)")
        
        eventCorrelations.sort { (eventA, eventB) -> Bool in
            return eventA.correlationStrength() > eventB.correlationStrength()
        }
        
        return eventCorrelations
    }
}

class EventCorrelation: CustomStringConvertible {
    var eventType = 0
    var averageLinearMood:Float = 0
    var linearMoodCount = 0 // The number of correlations that resulted in the averageLinearMood
    var standardDeviation:Float = 0
    
    func correlationStrength() -> Float {
        
        var tempLinearMood = averageLinearMood
        
        if tempLinearMood < 0 {
            tempLinearMood *= -1
        }
        
        return tempLinearMood
    }
    
    func correlationConfidence() -> Float {
        
        let sampleSizeConfidence:Float = 1 - pow(0.9, Float(self.linearMoodCount))
        
        var standardDeviationConfidence:Float = 1 - self.standardDeviation
        
        if standardDeviationConfidence < 0 {
            standardDeviationConfidence = 0
        }
        
        let overallConfidence = sampleSizeConfidence * standardDeviationConfidence
        
        return overallConfidence
    }
    
    var description: String {
        
        let eventEmoji = DataFormatter.emoji(typeInt: eventType)
        
        return "EventType \(eventEmoji.emoji) -> \(averageLinearMood) (\(linearMoodCount))"
    }
    
}

class Correlation: CustomStringConvertible {
    var eventType = 0
    var eventDate = Date()
    
    var moodType = 0
    var moodDate = Date()
    
    var strength:Float = 0
    
    func weight() -> Float {
        // Look at different between the eventDate and moodDate and return a weight
        let secondsCount = Int(moodDate.timeIntervalSinceReferenceDate) - Int(eventDate.timeIntervalSinceReferenceDate) - (60 * 60) // Offset by one hour, this produce a period of one hour where the weight is 1
        
        // A topEnd of 2 hours produces a weight decay of 2 hours from 1 to 0, combined with the offset in secondsCount, this results in a 3 hourm window, where the first hour is locked at 1 and then decays to 0.
        let topEnd = 2 * 60 * 60
        
        let resultWeight = topEnd - secondsCount
        
        var weight:Float = Float(resultWeight) / Float(topEnd)
        
        // Clip these weighting results.
        if weight > 1 {
            weight = 1
        } else if weight < 0 {
            weight = 0
        }
        
//        print("secondsCount: \(secondsCount)")
//        print("topEnd: \(topEnd)")
//        print("resultWeight: \(resultWeight)")
//        print("weight: \(weight)")
        
        return weight
    }
    
    
    var description: String {
        
        let eventEmoji = DataFormatter.emoji(typeInt: eventType)
        let moodEmoji = DataFormatter.emoji(typeInt: moodType)
        
        return "EventType \(eventEmoji.emoji) (\(eventType)) lead to MoodType \(moodEmoji.emoji) (\(moodType))"
    }
}
