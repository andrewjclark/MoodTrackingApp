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
        
        DataStore.shared.resetLocalNotifs()
        
        /*
        let newMood = DataStore.shared.newMood()
        newMood.scale = 1.0 // happy
        
        let sadMood = DataStore.shared.newMood()
        sadMood.scale = -1.0 // sad
        
        let midMood = DataStore.shared.newMood()
        midMood.scale = 0.0 // middle
        
        DataStore.shared.saveContext()
        */
        
        // _ = DataStore.shared.newEvent(type: "", customEmoji: nil, note: nil)
        
        DataStore.shared.saveContext()
        
        DataStore.shared.printAllEvents()
        
        return true
    }
    
    @available(iOS 10.0, *)
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let type = response.notification.request.content.userInfo["type"] as? Int {
            
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController as? ViewController {
                if type == 0 {
                    // Mood
                    rootVC.queryMood()
                } else if type == 1 {
                    // Event
                    rootVC.queryEvent()
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

