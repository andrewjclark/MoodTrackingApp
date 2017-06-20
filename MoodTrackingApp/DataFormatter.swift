//
//  DataFormatter.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 27/03/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

public enum ItemType {
    case mood
    case event
}

public enum EventType: Int {
    case unknown = 0
    
    // Mood Events
    case neutral = 1
    
    // Happy
    case calm = 10
    case happy = 11
    case excited = 12
    
    // Anxious / Frustrated
    case nervous = 20
    case anxious = 21
    case angry = 22
    
    // Sad / Depressed
    case down = 30
    case sad = 31
    case depressed = 32
    
    // Misc
    case sick = 40
    case bored = 41
    case tired = 42
    case inspired = 43
    
    
    
    case unknownevent = 1000
    
    // Wasted Time
    case wastedtime = 1001
    
    // Foods
    case food_healthy = 1010
    case food_junk = 1011
    case food_sweet = 1012
    
    // Work / Study
    
    case study = 1020
    case work = 1021
    case created = 1022 // need study?
    
    // Exercise
    case walk = 1030
    case exercise = 1031
    case spiritual = 1032
    
    // Exploring / Consumption
    case media = 1040
    case adventure = 1041
    case travel = 1042
    
    // Social
    case social_friend = 1050
    case social_event = 1051
    case social_party = 1052
    
    // Love
    case date = 1060
    case sex = 1061
    case kink = 1062
    
    // Stimulants
    case caffeine = 1070
    case alcohol = 1071
    case drugs = 1072
    
    // Misc
    case period = 1080
    case medication = 1081 // medication
    case tragedy = 1082
    case slept = 1083
}


class EmojiBundle:CustomStringConvertible, Hashable {
    var emoji = ""
    var name = ""
    var typeInt = 0
    var type = ItemType.mood
    var aliases = [String]()
    
    var description: String {
        return emoji + "(" + name + ")"
    }
    
    var hashValue: Int {
        return typeInt
    }
    
    static func ==(lhs: EmojiBundle, rhs: EmojiBundle) -> Bool {
        return lhs.typeInt == rhs.typeInt && lhs.type == rhs.type
    }
}

class DataFormatter {
    
    class func bundleForEvent(type: EventType) -> EmojiBundle {
        let emojiBundle = emoji(typeInt: type.rawValue)
        
        let bundle = EmojiBundle()
        bundle.emoji = emojiBundle.emoji
        bundle.name = emojiBundle.name
        bundle.typeInt = type.rawValue
        bundle.type = ItemType.event
        return bundle
    }
    
    class func emoji(typeInt: Int) -> (emoji: String, name: String, linearMood: Float?, type: ItemType) {
        
        if let type = EventType(rawValue: typeInt) {
            
            switch type {
                
                // Moods
            case .happy:
                return("☺️", "happy", 0.9, .mood)
            case .inspired:
                return("😍", "inspired", 1.0, .mood)
            case .excited:
                return("😆", "excited", 1.0, .mood)
            case .calm:
                return("🙂", "calm", 0.4, .mood)
            case .neutral:
                return("😶", "neutral", 0.0, .mood)
            case .sad:
                return("😢", "sad", -0.75, .mood)
            case .down:
                return("😕", "down", -0.75, .mood)
            case .anxious:
                return("😖", "anxious", -0.75, .mood)
            case .nervous:
                return("😥", "nervous", -0.3, .mood)
            case .depressed:
                return("😭", "depressed", -1.0, .mood)
            case .angry:
                return("😡", "angry", -1.0, .mood)
            case .bored:
                return("🙄", "bored", 0.0, .mood)
            case .sick:
                return("🤒", "sick", nil, .mood)
            case .tired:
                return("😴", "tired", nil, .mood)
                
                // Events
            case .created:
                return("🎨", "creativity", nil, .event)
            case .social_friend:
                return("👥", "friend", nil, .event)
            case .social_party:
                return("🎉", "party", nil, .event)
            case .travel:
                return("✈️", "travel", nil, .event)
            case .exercise:
                return("💪🏻", "exercise", nil, .event)
            case .walk:
                return("🚶", "walk", nil, .event)
            case .alcohol:
                return("🍹", "alcohol", nil, .event)
            case .caffeine:
                return("☕️", "caffeine", nil, .event)
            case .food_healthy:
                return("🍎", "food (healthy)", nil, .event)
            case .food_junk:
                return("🍔", "food (junk)", nil, .event)
            case .food_sweet:
                return("🍰", "food (sweet)", nil, .event)
            case .media:
                return("📺", "media", nil, .event)
            case .period:
                return("🚫", "period", nil, .event)
            case .spiritual:
                return("⛪️", "spiritual", nil, .event)
            case .study:
                return("📖", "study", nil, .event)
            case .work:
                return("💵", "work", nil, .event)
            case .date:
                return("🌹", "date", nil, .event)
            case .drugs:
                return("☠️", "drugs", nil, .event)
            case .sex:
                return("💗", "sex", nil, .event)
            case .kink:
                return("⛓", "kink", nil, .event)
            case .social_event:
                return("👨‍👩‍👧‍👦", "group", nil, .event)
            case .adventure:
                return("🗺", "adventure", nil, .event)
            case .wastedtime:
                return("📱", "wasted time", nil, .event)
            case .tragedy:
                return("💔", "tragedy", nil, .event)
            case .slept:
                return("💤", "slept", nil, .event)
            case .medication:
                return("💊", "medication", nil, .event)
            default:
                break
            }
        }
        
        return ("?", "null", nil, .mood)
    }
    
    class func shortDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        return dateFormatter.string(from: date as Date)
    }
    
    class func integerEndingLetters(string: String) -> String {
        
        if string == "11" || string == "12" || string == "13" {
            return "th"
        }
        
        if let last = string.characters.last {
            if last == "1" {
                return "st"
            } else if last == "2" {
                return "nd"
            } else if last == "3" {
                return "rd"
            }
        }
        
        return "th"
    }
}
