//
//  AppDelegate.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 27/03/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                
            }
        }
        
        SoundManager.primeSounds()
        
        UINavigationBar.appearance().barTintColor = UIColor.moodBlue
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium), NSForegroundColorAttributeName:UIColor.white]
        
        DataStore.shared.setupLocalNotifs()
        // DataStore.shared.saveContext()
        
        
        for offset in [-60, -3600, -5000, -7200, -10800, -100000] {
            let corrA = Correlation()
            corrA.eventDate = Date().addingTimeInterval(TimeInterval(offset)) // A second ago
            corrA.moodDate = Date()
            let minutes = Int(offset / 60)
            print("minutes \(minutes) weight(): \(corrA.weight())")
        }
        
        /*
        let corrA = Correlation()
        corrA.eventDate = Date().addingTimeInterval(-1) // A second ago
        corrA.moodDate = Date()
        print("corrA.weight(): \(corrA.weight())")
        
        let corrB = Correlation()
        corrB.eventDate = Date().addingTimeInterval(-3600) // An hour ago
        corrB.moodDate = Date()
        print("corrB.weight(): \(corrB.weight())")
        */
        
        print("")
        
        // Test Analysis
        DataAnalyser.sharedAnalyser.anaylseData()
        
        return true
    }
    
    /*
    func setUpLocalNotification(hour: Int, minute: Int) -> Date {
        
        // have to use NSCalendar for the components
        let calendar = NSCalendar(identifier: .gregorian)!;
        
        var dateFire = Date()
        
        // if today's date is passed, use tomorrow
        var fireComponents = calendar.components( [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from:dateFire)
        
        if (fireComponents.hour! > hour
            || (fireComponents.hour == hour && fireComponents.minute! >= minute) ) {
            
            dateFire = dateFire.addingTimeInterval(86400)  // Use tomorrow's date
            fireComponents = calendar.components( [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from:dateFire);
        }
        
        // set up the time
        fireComponents.hour = hour
        fireComponents.minute = minute
        
        // schedule local notification
        dateFire = calendar.date(from: fireComponents)!
        return dateFire
    }
    */
    
    @available(iOS 10.0, *)
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let type = response.notification.request.content.userInfo["type"] as? Int {
            
            DispatchQueue.main.async {
                
                if let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                    
                    if let rootVC = nav.visibleViewController as? ViewController {
                        
                        if type == 0 {
                            // Mood
                            rootVC.presentInputView(type: ItemType.mood)
                        } else if type == 1 {
                            // Event
                            rootVC.presentInputView(type: ItemType.event)
                        }
                    }
                }
            }
            
            
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.alert)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        DataStore.shared.saveContext()
        DataStore.shared.setupLocalNotifs()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        DataStore.shared.resetLocalNotifs()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        DataStore.shared.saveContext()
        DataStore.shared.setupLocalNotifs()
    }
    
    

    

}

