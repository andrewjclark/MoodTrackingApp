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
    case menstrual = 41
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
        let emoji = eventEmoji(type: type)
        
        let bundle = EmojiBundle()
        bundle.emoji = emoji.emoji
        bundle.name = emoji.name
        bundle.aliases = emoji.aliases
        bundle.typeInt = type.rawValue
        bundle.type = ItemType.event
        return bundle
    }
    
    class func emoji(typeInt: Int) -> (emoji: String, name: String, aliases: [String]) {
        
        if typeInt >= 1000 {
            // Event
            if let type = EventType(rawValue: typeInt) {
                return eventEmoji(type: type)
            }
        } else {
            // Mood
            if let type = EventType(rawValue: typeInt) {
                
                let moodEmoji = self.moodEmoji(type: type)
                return (moodEmoji.emoji, moodEmoji.name, [String]())
            }
        }
        
        return ("?", "null", [String]())
    }
    
    class func eventEmoji(typeInt: Int) -> (emoji: String, name: String, aliases: [String]) {
        
        if let type = EventType(rawValue: typeInt) {
            return eventEmoji(type: type)
        }
        
        return ("?", "null", [String]())
    }
    
    class func eventEmoji(type: EventType) -> (emoji: String, name: String, aliases: [String]) {
        switch type {
        case .created:
            return("🎨", "created", ["drew", "painted", "paint", "composed", "draw", "designed", "doodled", "prototyped", "design", "guitar", "played", "piano", "violin", "ukulele", "drums", "poem", "poet", "wrote", "write", "art", "artistic", "programming", "designing", "writing", "composing", "drawing", "painting"])
        case .social_friend:
            return("👥", "friend", ["friend"])
        case .social_party:
            return("🎉", "social", ["party", "partied", "pub", "munch", "drinking", "drunk", "friends", "friend", "coffee", "lunch", "dinner", "drinks", "drink"])
        case .travel:
            return("✈️", "travel", ["flew", "plane"])
        case .exercise:
            return("💪🏻", "exercise", ["gym", "run", "yoga", "martial", "martial arts", "boxing", "kick boxing", "karate", "dancing", "work out", "worked out", "trx", "jogged", "jog"])
        case .walk:
            return("🚶", "walk", ["walked", "strolled", "explored", "wandered"])
        case .alcohol:
            return("🍹", "alcohol", ["beer", "wine", "cocktails", "drinks", "drunk", "tipsy", "port", "shots", "tequila", "drink"])
        case .caffeine:
            return("☕️", "caffeine", ["coffee", "tea", "energy drink", "red bull", "monster", "redbull"])
        case .food_healthy:
            return("🍎", "food (healthy)", ["apple", "banana", "fruit", "salad", "breakfast", "lunch", "dinner", "sandwich", "roll", "subway", "chicken", "chinese", "thai"])
        case .food_junk:
            return("🍔", "food (junk)", ["fast food", "junk food", "mcdonalds", "burgerking", "hungry jacks", "mexican", "taco", "nando", "popcorn"])
        case .food_sweet:
            return("🍰", "food (sweet)", ["sugar", "candy", "lollies", "lolly", "lollipop", "jelly", "icecream", "cake", "pie", "dessert"])
        case .media:
            return("📺", "media", ["tv", "film", "cinema", "movie", "tv series", "youtube", "webseries", "netflix", "hulu", "documentary", "comedy", "drama", "romance", "action"])
        case .period:
            return("⭕️", "period (ended)", ["period", "cycle", "ended", "finished"])
        case .spiritual:
            return("⛪️", "spiritual", ["yoga", "meditated", "meditation"])
        case .study:
            return("📖", "study", ["studied", "practised", "prepped"])
        case .work:
            return("💵", "work", ["worked", "job", "employer", "contract", "meeting"])
        case .date:
            return("🌹", "date", ["met for coffee", "met for drinks", "hung out", "hookup", "hook up", "hang out", "kissed", "hold hands", "held hands"])
        case .drugs:
            return("☠️", "drugs", ["weed", "pot", "smoked", "marijuana", "green", "pills", "acid", "did drugs", "got high", "got stoned", "high", "stoned", "tripped"])
        case .sex:
            return("💗", "sex", ["fucked", "blowjob", "anal", "oral", "pounded", "slammed", "dommed", "dominated", "orgasm", "cum", "masturbate"])
        case .kink:
            return("⛓", "kink", ["spanked", "spank", "choked", "choke", "tied", "rope", "fisted", "cum", "orgasm", "teased", "munch", "event", "party", "dungeon", "master", "submissive", "dom", "domme"])
        case .social_event:
            return("👨‍👩‍👧‍👦", "social event", ["went, friends, group, lunch, social, socialise"])
        case .adventure:
            return("🗺", "adventure", ["adventure", "exploring", "explored", "wandered", "wander", "explore"])
        case .wastedtime:
            return("📱", "wasted time", ["waste time", "played on phone", "dawdled", "nothing", "bored"])
        default:
            return("❓", "unknown", [String]())
        }
    }
    
    class func moodEmoji(typeInt: Int) -> (emoji: String, name: String, linearMood: Float, tense:Float) {
        
        if let type = EventType(rawValue: typeInt) {
            return moodEmoji(type: type)
        }
        
        return("?", "null", 0.0, 0.0)
    }
    
    class func moodEmoji(type: EventType) -> (emoji: String, name: String, linearMood: Float, tense:Float) {
        
        switch type {
        case .happy:
            return("☺️", "happy", 0.9, 0.0)
        case .inspired:
            return("😍", "inspired", 1.0, 0.4)
        case .excited:
            return("😆", "excited", 1.0, 1.0)
        case .calm:
            return("🙂", "calm", 0.40, 0.0)
        case .neutral:
            return("😶", "neutral", 0.0, 0.0)
        case .sad:
            return("😢", "sad", -0.75, 0.0)
        case .down:
            return("😕", "down", -0.75, 0.0)
        case .anxious:
            return("😖", "anxious", -0.75, 1.0)
        case .nervous:
            return("😥", "nervous", -0.3, 0.33)
        case .depressed:
            return("😭", "depressed", -1.0, -1.0)
        case .angry:
            return("😡", "angry", -1.0, 0.0)
        case .menstrual:
            return("🤒", "menstrual", -1.0, 0.0)
        case .sick:
            return("🤒", "sick", -1.0, 0.0)
        case .tired:
            return("😴", "tired", 0.0, 0.0)
        default:
            return("?", "unknown", 0.0, 0.0)
        }
    }
    
    
    class func shortDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        return dateFormatter.string(from: date as Date)
    }
}
