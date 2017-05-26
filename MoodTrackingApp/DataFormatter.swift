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
    
    // Activity
    case study = 100
    case work = 101
    case created = 102
    case dancing = 103
    case social_friend = 104
    case social = 105
    case travel = 106
    case chores = 107
    case wander = 108
    case spiritual = 109
    case social_event = 110
    case exploring = 111
    case party = 112
    
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
    case food_snack = 306
    
    // Media
    case audio = 400
    case media = 401
    case music = 402
    case videogames = 403
    case reading = 404
    
    // Medical
    case period_ended = 500
    case period_started = 501
    case pills = 502
    case sick = 503
    
    // Daily Life
    case bathed = 600
    case woke = 601
    case sleep = 602
    case gotup = 603
    case gotintobed = 604
    case wastingtime = 605
    
    // Big life events
    case love = 700 // fell in love
    case tragedy = 701 // breakup or a death
    
    // Adult activites
    case date = 1000
    case drugs = 1001
    case sex = 1002
    case kink = 1003
    case toilet = 1004
    
    static let count: Int = {
        return 1004
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
    case relaxed = 107
    
    case excited = 200
    case positive = 201
    case optimistic = 202
    
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
    case scared = 606
    
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
    case jetlagged = 1015
    case flat = 1016
    
    static let count: Int = {
        return 1016
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
    
    class func bundleForMood(type: MoodType) -> EmojiBundle {
        let emoji = moodEmoji(type: type)
        
        let bundle = EmojiBundle()
        bundle.emoji = emoji.emoji
        bundle.name = emoji.name
        bundle.typeInt = type.rawValue
        bundle.type = ItemType.mood
        
        return bundle
    }
    
    class func eventEmoji(typeInt: Int) -> (emoji: String, name: String, aliases: [String]) {
        
        if let type = EventType(rawValue: typeInt) {
            return eventEmoji(type: type)
        }
        
        return ("?", "null", [String]())
    }
    
    class func eventEmoji(type: EventType) -> (emoji: String, name: String, aliases: [String]) {
        switch type {
        case .unknown:
            return("❓", "unknown", [String]())
        case .created:
            return("🎨", "created", ["drew", "painted", "paint", "composed", "draw", "designed", "doodled", "prototyped", "design", "guitar", "played", "piano", "violin", "ukulele", "drums", "poem", "poet", "wrote", "write", "art", "artistic", "programming", "designing", "writing", "composing", "drawing", "painting"])
        case .dancing:
            return("💃", "dancing", ["dance", "danced"])
        case .social_friend:
            return("👥", "friend", ["friend"])
        case .social:
            return("🎉", "social", ["party", "partied", "pub", "munch", "drinking", "drunk", "friends", "friend", "coffee", "lunch", "dinner", "drinks", "drink"])
        case .travel:
            return("✈️", "travel", ["flew", "plane"])
        case .chores:
            return("⏳", "chores", ["dishes", "cleaned", "vacuumed", "washed", "tidied", "garbage", "clothes"])
        case .exercise:
            return("💪🏻", "exercise", ["gym", "run", "yoga", "martial", "martial arts", "boxing", "kick boxing", "karate", "dancing", "work out", "worked out", "trx", "jogged", "jog"])
        case .sport:
            return("⚽️", "sport", ["played", "soccer", "football", "cricket", "tennis", "olympics"])
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
        case .food_snack:
            return("🍪", "food (snack)", ["crackers", "roll", "nuts", "fruit"])
        case .audio:
            return("🎧", "audio", ["podcast", "audiobook", "audio book", "audible", "meditation"])
        case .media:
            return("📺", "media", ["tv", "film", "cinema", "movie", "tv series", "youtube", "webseries", "netflix", "hulu", "documentary", "comedy", "drama", "romance", "action"])
        case .music:
            return("🎼", "music", ["music", "spotify", "apple music", "pandora", "radio", "danced", "song", "sang", "sung", "whistle"])
        case .videogames:
            return("🎮", "videogames", ["play", "played", "xbox", "playstation", "nintendo", "switch", "ds", "minecraft", "twitch", "youtube"])
        case .reading:
            return("📖", "reading", ["read", "book", "poem", "poet"])
        case .period_ended:
            return("⭕️", "period (ended)", ["period", "cycle", "ended", "finished"])
        case .period_started:
            return("💢", "period (started)", ["period", "cycle", "started", "began", "begun"])
        case .pills:
            return("💊", "pills", ["medication", "anti-depressant"])
        case .sick:
            return("🚑", "sick", ["ill", "vomit", "sneeze", "cough", "uti", "sore"])
        case .bathed:
            return("🛁", "bathed", ["washed", "showered", "cleaned"])
        case .woke:
            return("⏰", "woke up", ["awoke"])
        case .gotup:
            return("🌅", "got up", ["get out of bed", "bed", "sleep"])
        case .gotintobed:
            return("🛏", "got into bed", ["went to bed", "got in bed", "bed", "sleep"])
        case .sleep:
            return("💤", "sleep", ["snoozed", "napped", "nap", "slept", "crashed", "passed out", "pass out"])
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
        case .wander:
            return("🌅", "wander", ["wander"])
        case .love:
            return("💘", "fell in love", ["love", "met someone", "met someone new", "smitten", "crush"])
        case .tragedy:
            return("💔", "tragedy", ["death", "died", "break up", "broke up", "betrayed", "cheated", "disaster"])
        case .social_event:
            return("👨‍👩‍👧‍👦", "social event", ["went, friends, group, lunch, social, socialise"])
        case .exploring:
            return("🗺", "exploring", ["explored", "wandered", "wander", "explore"])
        case .toilet:
            return("🚽", "toilet", ["poo", "wee", "pooped", "urianted", "piss", "shit"])
        case .wastingtime:
            return("📱", "wasted time", ["waste time", "played on phone", "dawdled", "nothing", "bored"])
        case .party:
            return("🎉", "party", ["party", "concert", "gig", "rave"])
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
        case .relaxed:
            return("🙂", "relaxed", 0.5, 0.0, MoodSuperType.happy)
        case .excited:
            return("😆", "excited", 1.0, 1.0, MoodSuperType.excited)
        case .positive:
            return("😃", "positive", 0.6, 0.33, MoodSuperType.excited)
        case .optimistic:
            return("😃", "optimistic", 0.6, 0.33, MoodSuperType.excited)
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
        case .scared:
            return("😨", "scared", -1.0, 0.5, MoodSuperType.anxious)
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
            return("🙃", "moody", 0.0, 0.0, MoodSuperType.bodily)
        case .jetlagged:
            return("😴", "jet lagged", 0.0, 0.0, MoodSuperType.bodily)
        case .flat:
            return("😐", "flat", -0.1, 0.0, MoodSuperType.bodily)
        }
    }
    
    
    class func shortDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        return dateFormatter.string(from: date as Date)
    }
    
    class func allMoods() -> [MoodType] {
        
        var stringItems = [String]()
        var nameToMood = [String:MoodType]()
        var moods = [MoodType]()
        
        for scale in 1...MoodType.count {
            if let type = MoodType(rawValue: scale) {
                let mood = DataFormatter.moodEmoji(type: type)
                stringItems.append(mood.name)
                nameToMood[mood.name] = type
            }
        }
        
        stringItems.sort()
        
        for string in stringItems {
            if let moodType = nameToMood[string] {
                moods.append(moodType)
            }
        }
        
        return moods
    }
    
    class func allEvents() -> [EventType] {
        
        var stringItems = [String]()
        var nameToEvent = [String:EventType]()
        var events = [EventType]()
        
        for scale in 1...EventType.count {
            if let type = EventType(rawValue: scale) {
                let event = DataFormatter.eventEmoji(type: type)
                stringItems.append(event.name)
                nameToEvent[event.name] = type
            }
        }
        
        stringItems.sort()
        
        for string in stringItems {
            if let eventType = nameToEvent[string] {
                events.append(eventType)
            }
        }
        
        return events
    }
    
    class func allBundles() -> [EmojiBundle] {
        var bundles = [EmojiBundle]()
        
        for item in allItems() {
            if let item = item as? MoodType {
                bundles.append(bundleForMood(type: item))
            } else if let item = item as? EventType {
                bundles.append(bundleForEvent(type: item))
            }
        }
        
        return bundles
    }
    
    class func allItems() -> [Any] {
        
        var stringItems = [String]()
        var nameToEvent = [String:Any]()
        var items = [Any]()
        
        // Get the events
        for scale in 1...EventType.count {
            if let type = EventType(rawValue: scale) {
                let item = DataFormatter.eventEmoji(type: type)
                stringItems.append(item.name)
                nameToEvent[item.name] = type
            }
        }
        
        // Get the moods
        for scale in 1...MoodType.count {
            if let type = MoodType(rawValue: scale) {
                let item = DataFormatter.moodEmoji(type: type)
                stringItems.append(item.name)
                nameToEvent[item.name] = type
            }
        }
        
        stringItems.sort()
        
        for string in stringItems {
            if let item = nameToEvent[string] {
                items.append(item)
            }
        }
        
        return items
    }
    
    
    
}
