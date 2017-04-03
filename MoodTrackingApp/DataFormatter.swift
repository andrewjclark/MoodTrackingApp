//
//  DataFormatter.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 27/03/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

public enum EventType: Int {
    case unknown = 0
    
    // Activity
    case study = 100
    case work = 101
    case created = 102
    case dancing = 103
    case family = 104
    case social = 105
    case travel = 106
    case chores = 107
    case hobby = 108
    case church = 109
    
    // Physical
    case exercise = 200
    case sport = 201
    case walk = 202
    
    // Food & Drink
    case alcohol = 300
    case caffeine = 301
    case food_healthy = 303
    case food_junk = 304
    case food_sweet = 305
    
    // Media
    case audio = 400
    case media = 401
    case music = 402
    case videogames = 403
    
    // Medical
    case period_ended = 500
    case period_started = 501
    case pills = 502
    case sick = 503
    
    // Daily Life
    case bathed = 600
    case woke = 601
    case gotup = 602
    case sleep = 603
    
    // Big life events
    case love = 700 // fell in love
    case tragedy = 701 // breakup or a death
    
    // Adult activites
    case date = 1000
    case drugs = 1001
    case sex = 1002
    case kink = 1003
    
    static let count: Int = {
        return 1003
    }()
}


public enum MoodType: Int {
    
    case unknown = 0
    
    case happy = 100
    case elated = 102
    case silly = 103
    case artistic = 104
    case creative = 105
    case inspired = 106
    
    case excited = 200
    case positive = 201
    
    case grateful = 300
    case homesick = 301
    case nostalgic = 302
    case pleased = 303
    
    case bored = 400
    case calm = 401
    case contented = 402
    case neutral = 403
    case restless = 404
    
    case sad = 500
    case lonely = 501
    case numb = 502
    case down = 503
    case overwhelmed = 504
    
    case anxious = 600
    case fearful = 601
    case afraid = 602
    case nervous = 603
    case paranoid = 604
    case surprised = 605
    
    case depressed = 700
    case negative = 701
    case selfdestructive = 702
    case suicidal = 703
    case disappointed = 704
    case guilty = 705
    case regretful = 706
    
    case angry = 800
    case aggravated = 801
    case annoyed = 802
    case frustrated = 803
    case jealous = 804
    case resentful = 805
    case destructive = 806
    case confused = 807
    
    case dizzy = 1000
    case drunk = 1001
    case exhausted = 1002
    case high = 1003
    case horny = 1004
    case hungover = 1005
    case hungry = 1006
    case menstrual = 1007
    case sick = 1008
    case sleepy = 1009
    case sore = 1010
    case thirsty = 1011
    case tipsy = 1012
    case tired = 1013
    case moody = 1014
    
    static let count: Int = {
        return 1013
    }()
}

public enum MoodSuperType: Int {
    case none = 0
    case neutral
    case happy // happy present
    case excited // happy future
    case grateful // happy past
    case sad // sad present
    case anxious // sad future
    case depressed // sad past
    case angry
    case bodily
}

class DataFormatter {
    
    class func eventEmoji(typeInt: Int) -> (emoji: String, name: String) {
        
        if let type = EventType(rawValue: typeInt) {
            return eventEmoji(type: type)
        }
        
        return ("?", "null")
    }
    
    class func eventEmoji(type: EventType) -> (emoji: String, name: String) {
        switch type {
        case .unknown:
            return("❓", "unknown")
        case .created:
            return("🎨", "created")
        case .dancing:
            return("💃", "dancing")
        case .family:
            return("👨‍👩‍👧‍👦", "family")
        case .social:
            return("🎉", "social")
        case .travel:
            return("✈️", "travel")
        case .chores:
            return("⏳", "chores")
        case .exercise:
            return("💪🏻", "exercise")
        case .sport:
            return("⚽️", "sport")
        case .walk:
            return("🏃", "walk")
        case .alcohol:
            return("🍹", "alcohol")
        case .caffeine:
            return("☕️", "caffeine")
        case .food_healthy:
            return("🍏", "food (healthy)")
        case .food_junk:
            return("🍔", "food (junk)")
        case .food_sweet:
            return("🍰", "food (sweet)")
        case .audio:
            return("🎧", "audio")
        case .media:
            return("📺", "media")
        case .music:
            return("🎼", "music")
        case .videogames:
            return("🎮", "videogames")
        case .period_ended:
            return("⭕️", "period (ended)")
        case .period_started:
            return("💢", "period (started)")
        case .pills:
            return("💊", "pills")
        case .sick:
            return("🚑", "sick")
        case .bathed:
            return("🛁", "bathed")
        case .woke:
            return("⏰", "woke up")
        case .gotup:
            return("🌅", "got up")
        case .sleep:
            return("💤", "sleep")
        case .church:
            return("⛪️", "church")
        case .study:
            return("📖", "study")
        case .work:
            return("💵", "work")
        case .date:
            return("🌹", "date")
        case .drugs:
            return("☠️", "drugs")
        case .sex:
            return("💗", "sex")
        case .kink:
            return("⛓", "kink")
        case .hobby:
            return("🔬", "hobby")
        case .love:
            return("💘", "fell in love")
        case .tragedy:
            return("💔", "tragedy")
        }
    }
    
    class func moodEmoji(typeInt: Int) -> (emoji: String, name: String, linearMood: Float, tense:Float, superType: MoodSuperType) {
        
        if let type = MoodType(rawValue: typeInt) {
            return moodEmoji(type: type)
        }
        
        return("? ", "null", 0.0, 0.0, MoodSuperType.neutral)
    }
    
    class func moodEmoji(type: MoodType) -> (emoji: String, name: String, linearMood: Float, tense:Float, superType: MoodSuperType) {
        
        switch type {
            
        case .unknown:
            return("?", "unknown", 0.0, 0.0, MoodSuperType.none)
        case .happy:
            return("☺️", "happy", 1.0, 0.0, MoodSuperType.happy)
        case .elated:
            return("😆", "elated", 1.0, 0.0, MoodSuperType.happy)
        case .silly:
            return("😋", "silly", 0.2, 0.0, MoodSuperType.happy)
        case .artistic:
            return("😍", "artistic", 0.75, 0.0, MoodSuperType.happy)
        case .creative:
            return("😍", "creative", 0.8, 0.2, MoodSuperType.happy)
        case .inspired:
            return("😍", "inspired", 1.0, 0.4, MoodSuperType.happy)
        case .excited:
            return("😆", "excited", 1.0, 1.0, MoodSuperType.excited)
        case .positive:
            return("😃", "positive", 0.6, 0.33, MoodSuperType.excited)
        case .grateful:
            return("😙", "grateful", 0.3, -0.5, MoodSuperType.grateful)
        case .homesick:
            return("😔", "homesick", -0.2, -1.0, MoodSuperType.grateful)
        case .nostalgic:
            return("😌", "nostalgic", 0.2, -1.0, MoodSuperType.grateful)
        case .pleased:
            return("😁", "pleased", 0.5, -0.3, MoodSuperType.grateful)
        case .bored:
            return("😕", "bored", -0.2, 0.0, MoodSuperType.neutral)
        case .restless:
            return("🤔", "restless", -0.2, 0.0, MoodSuperType.neutral)
        case .calm:
            return("🙂", "calm", 0.1, 0.0, MoodSuperType.neutral)
        case .contented:
            return("🙂", "contented", 0.2, 0.0, MoodSuperType.neutral)
        case .neutral:
            return("😶", "neutral", 0.0, 0.0, MoodSuperType.neutral)
        case .sad:
            return("😭", "sad", -0.75, 0.0, MoodSuperType.sad)
        case .lonely:
            return("🤐", "lonely", -0.8, 0.0, MoodSuperType.sad)
        case .numb:
            return("😐", "numb", -0.2, 0.0, MoodSuperType.sad)
        case .down:
            return("😭", "down", -0.75, 0.0, MoodSuperType.sad)
        case .overwhelmed:
            return("😑", "overwhelmed", -0.8, 0.0, MoodSuperType.sad)
        case .anxious:
            return("😖", "anxious", -0.75, 1.0, MoodSuperType.anxious)
        case .fearful:
            return("😨", "fearful", -1.0, 0.5, MoodSuperType.anxious)
        case .afraid:
            return("😱", "afraid", -0.8, 0.7, MoodSuperType.anxious)
        case .nervous:
            return("😥", "nervous", -0.3, 0.33, MoodSuperType.anxious)
        case .paranoid:
            return("😰", "paranoid", -0.3, 1.0, MoodSuperType.anxious)
        case .surprised:
            return("😨", "surprised", 0.0, 0.0, MoodSuperType.anxious)
        case .depressed:
            return("😭", "depressed", -1.0, -1.0, MoodSuperType.depressed)
        case .negative:
            return("😞", "negative", -0.5, 0.5, MoodSuperType.depressed)
        case .selfdestructive:
            return("😪", "self_destructive", -1.0, 0.4, MoodSuperType.depressed)
        case .suicidal:
            return("😪", "suicidal", -1.0, 0.8, MoodSuperType.depressed)
        case .disappointed:
            return("☹️", "disappointed", -0.75, -0.3, MoodSuperType.depressed)
        case .guilty:
            return("😓", "guilty", -0.33, -1.0, MoodSuperType.depressed)
        case .regretful:
            return("🙄", "regretful", -0.5, -0.8, MoodSuperType.depressed)
        case .angry:
            return("😡", "angry", -1.0, 0.0, MoodSuperType.angry)
        case .aggravated:
            return("😤", "aggravated", 0.0, 0.0, MoodSuperType.angry)
        case .annoyed:
            return("😠", "annoyed", -1.0, 0.0, MoodSuperType.angry)
        case .frustrated:
            return("😤", "frustrated", -0.75, 0.0, MoodSuperType.angry)
        case .jealous:
            return("😒", "jealous", -0.5, 0.0, MoodSuperType.angry)
        case .resentful:
            return("😒", "resentful", -0.7, 0.2, MoodSuperType.angry)
        case .destructive:
            return("👿", "destructive", -1.0, 0.5, MoodSuperType.angry)
        case .confused:
            return("😕", "confused", -0.2, 0.0, MoodSuperType.angry)
        case .dizzy:
            return("😵", "dizzy", 0.0, 0.0, MoodSuperType.bodily)
        case .drunk:
            return("😝", "drunk", 0.5, 0.0, MoodSuperType.bodily)
        case .exhausted:
            return("😴", "exhausted", 0.0, 0.0, MoodSuperType.bodily)
        case .high:
            return("😲", "high", 0.3, 0.0, MoodSuperType.bodily)
        case .horny:
            return("😈", "horny", 0.5, 0.0, MoodSuperType.bodily)
        case .hungover:
            return("🤒", "hungover", -0.5, 0.0, MoodSuperType.bodily) // needs better emoji
        case .hungry:
            return("😛", "hungry", 0.0, 0.0, MoodSuperType.bodily)
        case .menstrual:
            return("🤒", "menstrual", -1.0, 0.0, MoodSuperType.bodily)
        case .sick:
            return("🤒", "sick", -1.0, 0.0, MoodSuperType.bodily)
        case .sleepy:
            return("😴", "sleepy", 0.0, 0.0, MoodSuperType.bodily)
        case .sore:
            return("🤕", "sore", -0.2, 0.0, MoodSuperType.bodily)
        case .thirsty:
            return("😛", "thirsty", 0.0, 0.0, MoodSuperType.bodily)
        case .tipsy:
            return("😜", "tipsy", 0.9, 0.0, MoodSuperType.bodily)
        case .tired:
            return("😴", "tired", 0.0, 0.0, MoodSuperType.bodily)
        case .moody:
            return("🙃", "tired", 0.0, 0.0, MoodSuperType.bodily)
        }
    }
    
    
    class func shortDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        return dateFormatter.string(from: date as Date)
    }
}
