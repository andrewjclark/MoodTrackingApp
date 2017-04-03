//
//  DataStore.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 27/03/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications


public enum NotifType: Int {
    case mood = 0
    case event = 1
}

class DataStore {
    
    static let shared = DataStore()
    fileprivate init() {}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "MoodTrackingApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deviceUUID() -> String? {
        if let vendorID = UIDevice.current.identifierForVendor {
            return vendorID.uuidString
        }
        return nil
    }
    
    func newUUID() -> String {
        return UUID().uuidString
    }
    
    func newMood() -> Mood {
        
        let newMood = NSEntityDescription.insertNewObject(forEntityName: "Mood", into: persistentContainer.viewContext) as! Mood
        
        newMood.moodID = newUUID()
        newMood.date = NSDate()
        
        self.setupLocalNotifs()
        
        return newMood
    }
    
    func newEvent() -> Event {
        
        let newEvent = NSEntityDescription.insertNewObject(forEntityName: "Event", into: persistentContainer.viewContext) as! Event
        
        newEvent.eventID = newUUID()
        newEvent.date = NSDate()
        
        self.setupLocalNotifs()
        
        return newEvent
    }
    
    
    func newMood(type: MoodType, customEmoji: String?, note: String?) -> Mood? {
        let newMood = self.newMood()
        newMood.type = Int16(type.rawValue)
        newMood.note = note
        
        return newMood
    }
    
    
    func newEvent(type: EventType, customEmoji: String?, note: String?) -> Event? {
        
        let newEvent = self.newEvent()
        
        newEvent.type = Int16(type.rawValue)
        newEvent.customEmoji = customEmoji
        newEvent.note = note
        
        return newEvent
    }
    
    
    func moodFetchRequest(_ predicate:NSPredicate?) -> NSFetchRequest<Mood> {
        
        let fetchRequest = NSFetchRequest<Mood>(entityName: "Mood")
        fetchRequest.predicate = predicate
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
    func eventFetchRequest(_ predicate:NSPredicate?) -> NSFetchRequest<Event> {
        
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        fetchRequest.predicate = predicate
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
    func fetchAllMoods() -> [Mood]? {
        
        let fetchRequest = moodFetchRequest(NSPredicate(value: true))
        
        do {
            let results = try self.persistentContainer.viewContext.fetch(fetchRequest)
            
            return results
        } catch {
            return nil
        }
    }
    
    func fetchAllEvents() -> [Event]? {
        
        let fetchRequest = eventFetchRequest(NSPredicate(value: true))
        
        do {
            let results = try self.persistentContainer.viewContext.fetch(fetchRequest)
            
            return results
        } catch {
            return nil
        }
    }
    
    
    func deleteMood(mood: Mood) {
        self.persistentContainer.viewContext.delete(mood)
    }
    
    func deleteEvent(event: Event) {
        self.persistentContainer.viewContext.delete(event)
    }
    
    func printAllMoods() {
        let fetchRequest = moodFetchRequest(NSPredicate(value: true))
        print("Start of print")
        
        do {
            let results = try self.persistentContainer.viewContext.fetch(fetchRequest)
            
            print("results.count: \(results.count)")
            
            for result in results {
                print("\(result.moodID) \(result.type) \(result.date)")
            }
            
            print("End of print")
            
        } catch {
            
        }
    }
    
    func printAllEvents() {
        let fetchRequest = eventFetchRequest(NSPredicate(value: true))
        print("Start of event print")
        
        do {
            let results = try self.persistentContainer.viewContext.fetch(fetchRequest)
            
            print("event results.count: \(results.count)")
            
            for result in results {
                print("\(result.type) \(result.customEmoji) \(result.date)")
            }
            
            print("End of event print")
            
        } catch {
            
        }
    }
    
    func timeString(seconds: Int) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let seconds = Int(seconds) % 60
        
        if hours > 0 {
            if hours == 1 {
                return "\(hours) hour"
            }
            return "\(hours) hours"
        } else if minutes > 0 {
            if minutes == 1 {
                return "\(minutes) min"
            }
            return "\(minutes) mins"
        } else {
            if seconds == 1 {
                return "\(seconds) second"
            }
            return "\(seconds) seconds"
        }
        
    }
    
    func resetLocalNotifs() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }
    
    func setupLocalNotifs() {
        
        var type = NotifType.mood
        
        self.resetLocalNotifs()
        
        // Find the date of the most recent item
        
        var timeSince = Int.max
        
        if let moods = self.fetchAllMoods() {
            if let date = moods.first?.date {
                
                let tempSince:Int = Int(Date().timeIntervalSince(date as Date))
                
                if tempSince < timeSince {
                    timeSince = tempSince
                    type = NotifType.event
                }
            }
        }
        
        if let events = self.fetchAllEvents() {
            if let date = events.first?.date {
                
                let tempSince:Int = Int(Date().timeIntervalSince(date as Date))
                
                if tempSince < timeSince {
                    timeSince = tempSince
                    type = NotifType.mood
                }
            }
        }
        
        var lastCount = 0
        var secondsCount = 60 * 60
        
        for _ in 1...10 {
            
            let content = UNMutableNotificationContent()
            
            let newTime = lastCount + secondsCount
            
            var bodyString = ""
            
            // Setup the userInfo so we know what screen to present the user.
            
            content.userInfo = ["type":type.rawValue]
            
            if type == .mood {
                bodyString = "How are you feeling?"
                type = .event
            } else if type == .event {
                bodyString = "What have you been doing?"
                type = .mood
            }
            
            if timeSince < Int.max {
                bodyString += "\nYour last entry was \(timeString(seconds: timeSince + newTime)) ago."
            }
            
            content.body = bodyString
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "com.andrewjclark.moodtrackingapp.localnotification"
            
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: TimeInterval(newTime), repeats: false)
            let request = UNNotificationRequest.init(identifier: "localnotification.\(newTime)seconds", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: { (error) in
                
            })
            
            lastCount = newTime
            secondsCount *= 2
        }
    }
    
    
}
