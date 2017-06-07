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
                self.postDatabaseSavedNotification()
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
    
    func postDatabaseSavedNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name.init("kDataStoreSaved"), object: nil)
        }
    }
    
    func newEvent() -> Event {
        
        let newEvent = NSEntityDescription.insertNewObject(forEntityName: "Event", into: persistentContainer.viewContext) as! Event
        
        newEvent.eventID = newUUID()
        newEvent.date = NSDate()
        
        self.setupLocalNotifs()
        
        return newEvent
    }
    
    
    func newMood(type: EventType, customEmoji: String?, note: String?, date: Date?) -> Event? {
        let newMood = self.newEvent()
        newMood.type = Int16(type.rawValue)
        newMood.note = note
        
        if let date = date {
            newMood.date = date as NSDate
        }
        
        return newMood
    }
    
    
    func newEvent(type: EventType, customEmoji: String?, note: String?, date: Date?) -> Event? {
        
        let newEvent = self.newEvent()
        
        newEvent.type = Int16(type.rawValue)
        newEvent.customEmoji = customEmoji
        newEvent.note = note
        
        if let date = date {
            newEvent.date = date as NSDate
        }
        
        return newEvent
    }
    
    func eventFetchRequest(_ predicate:NSPredicate?) -> NSFetchRequest<Event> {
        
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        fetchRequest.predicate = predicate
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
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
    
    func fetchEvents(startDate: Date, endDate: Date) -> [Event]? {
        
        let predicate = NSPredicate(format: "date >= %@ && date <= %@", startDate as NSDate, endDate as NSDate)
        
        let fetchRequest = eventFetchRequest(predicate)
        
        do {
            let results = try self.persistentContainer.viewContext.fetch(fetchRequest)
            
            return results
        } catch {
            return nil
        }
        
        
        return nil
    }
    
    func deleteEvent(event: Event) {
        self.persistentContainer.viewContext.delete(event)
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
        let days = Int(seconds) / (3600 * 24)
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let seconds = Int(seconds) % 60
        
        if days > 0 {
            if days == 1 {
                return "\(days) day"
            }
            return "\(days) days"
        } else
        
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
        
        if let events = self.fetchAllEvents() {
            if let date = events.first?.date {
                
                let tempSince:Int = Int(Date().timeIntervalSince(date as Date))
                
                if tempSince < timeSince {
                    timeSince = tempSince
                    
                    if events.first!.type >= 1000 {
                        // It's an event
                        type = NotifType.mood
                    } else {
                        // It's a mood
                        type = NotifType.event
                    }
                }
            }
        }
        
        var lastCount = 0
        var secondsCount = 3600
        
        for _ in 1...10 {
            
            let content = UNMutableNotificationContent()
            
            var newTime = lastCount + secondsCount
            
            var bodyString = ""
            
            // If the newTime falls between 10pm and 7am then postpone it.
            let calendar = Calendar.current
            
            var hourComponent = calendar.component(.hour, from: Date(timeIntervalSinceNow: TimeInterval(newTime)))
            
            while hourComponent >= 22 || hourComponent <= 7 {
                newTime += 3600
                hourComponent = calendar.component(.hour, from: Date(timeIntervalSinceNow: TimeInterval(newTime)))
            }
            
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
            secondsCount += 900
        }
    }
}




