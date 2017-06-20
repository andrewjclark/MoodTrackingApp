//
//  SettingsHelper.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 19/06/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

public enum SettingsKey: String { // NSNumber objecs, null infers different things,
    case notifications = "SettingsKey.notifications"
}

class SettingsHelper {
    class func isSettingEnabled(key: SettingsKey) -> Bool {
        
        let def = UserDefaults.standard
        
        if let obj = def.object(forKey: key.rawValue) as? NSNumber {
            return obj.boolValue
        }
        
        if key == .notifications {
            // Notifications default to true
            return true
        }
        
        return false
    }
    
    class func flipSetting(key: SettingsKey) {
        let def = UserDefaults.standard
        
        var currentValue = isSettingEnabled(key: key)
        
        let number = NSNumber(value: !currentValue)
        
        def.set(number, forKey: key.rawValue)
        def.synchronize()
        
    }
    
}
