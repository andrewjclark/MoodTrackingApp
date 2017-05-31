//
//  ViewController.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 27/03/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

public enum GroupType {
    case day
    case month
}

class EventRange:CustomStringConvertible {
    var startDate = Date()
    var endDate = Date()
    var events = [Event]()
    var type = GroupType.day
    
    var description: String {
        let df = DateFormatter()
        df.timeStyle = DateFormatter.Style.short
        df.dateStyle = DateFormatter.Style.short
        
        return "EventRange: \(df.string(from: startDate)) to \(df.string(from: endDate)) with type \(type) and \(events.count) events"
    }
    
    func startDateString() -> String {
        let df = DateFormatter()
        df.dateFormat = "EEE, d MMM"
        
        if type == .day {
            if startDate.startOfDay == Date().startOfDay {
                // This is todays date! Try and post it now.
                return "Today"
            } else {
                return df.string(from: startDate)
            }
        } else {
            // Month
            df.dateFormat = "MMMM, YYYY"
            return df.string(from: startDate)
        }
    }
}


class ViewController: MoodViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let kSectionNewMood = -1
    let kSectionNewEvent = -1
    
    let kSectionDays = 0
    let kSectionMoods = -1
    
    let kSectionsCount = 1
    
    var results = [Event]()
    var resultsByDay = [EventRange]()
    
    var viewType = GroupType.month
    
    @IBOutlet weak var newButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.moodBlue
        tableView.backgroundColor = UIColor.moodBlue
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        newButton.clipsToBounds = true
        newButton.layer.cornerRadius = 44
        newButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        /*
        newButton.layer.shadowColor = UIColor.black.cgColor
        newButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        newButton.layer.shadowOpacity = 1.0
        */
        
        for cellName in ["EventTableViewCell", "EventGraphTableViewCell"] {
            let nib = UINib(nibName: cellName, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: cellName)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.dataStoreSaved), name: NSNotification.Name.init("kDataStoreSaved"), object: nil)
    }
    
    func dataStoreSaved() {
        self.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func date(item: Any) -> NSDate {
        if let item = item as? Event {
            if let date = item.date {
                return date
            }
        }
        
        return NSDate()
    }
    
    func updateDataSource() {
        if let fetchedEvents = DataStore.shared.fetchAllEvents() {
            
            self.results = fetchedEvents
            
            /*
            // Sort these items
            self.results.sort(by: { (first, second) -> Bool in
                
                let date1 = self.date(item: first)
                let date2 = self.date(item: second)
                
                return date1.compare(date2 as Date) == ComparisonResult.orderedDescending
            })
            */
            
            self.resultsByDay.removeAll()
            
            let df = DateFormatter()
            df.timeStyle = DateFormatter.Style.none
            df.dateStyle = DateFormatter.Style.short
            
            /*
             
            var currentDateString = ""
            var currentDay = [Event]()
            
            // Iterate through the results and add them to days as needed.
            
            for event in fetchedEvents {
                if let date = event.date {
                    
                    let dateString = df.string(from: date as Date)
                    
                    print("dateString: \(dateString) vs \(currentDateString)")
                    
                    if dateString != currentDateString {
                        // It's a new day
                        print("new day")
                        
                        if currentDay.count > 0 {
                            resultsByDay.append(currentDay)
                        }
                        
                        currentDay = [event] // Replace contents
                        
                        currentDateString = dateString
                    } else {
                        print("add to current day")
                        
                        currentDay.append(event)
                    }
                    
                    print("currentDay.count: \(currentDay.count)")
                }
            }
            */
            
            // Determine start date for all these days
            
            
            
            df.timeStyle = DateFormatter.Style.medium
            df.dateStyle = DateFormatter.Style.medium
            
            let currentDate = Date()
            
            var eventRanges = [EventRange]()
            
            // Get event ranges for each preceeding day.
            if viewType == .day {
                for number in 0...60 {
                    
                    let newStartDate = currentDate.startOfDay(offset: number * -1)
                    
                    let newRange = EventRange()
                    newRange.startDate = newStartDate
                    newRange.endDate = newStartDate.endOfDay
                    newRange.type = GroupType.day
                    
                    eventRanges.append(newRange)
                }
                
                df.dateFormat = "DD MMM YYYY"
            } else if viewType == .month {
                for number in 0...10 {
                    
                    let newStartDate = currentDate.firstDayOfMonth(offset: number * -1).startOfDay
                    
                    let newRange = EventRange()
                    newRange.startDate = newStartDate
                    newRange.endDate = newStartDate.lastMomentOfMonth()
                    newRange.type = GroupType.month
                    
                    eventRanges.append(newRange)
                }
                
                df.dateFormat = "MMM YYYY"
            }
            
           // We now have the ranges and need to iterate through the events and dump them in there if the days line up.
            
            var eventRangeLookup = [String:EventRange]()
            
            for range in eventRanges {
                let string = df.string(from: range.startDate)
                
                
                if eventRangeLookup[string] != nil {
                    print("Duplicate?!")
                }
                
                eventRangeLookup[string] = range
            }
            
            
            for event in fetchedEvents {
                if let date = event.date {
                    
                    let dateString = df.string(from: date as Date)
                    
                    if let range = eventRangeLookup[dateString] {
                        range.events.insert(event, at: 0) // The events list ought to be from earliest event to latest, ie, the earlier in the array then the closer to startDate it is. We fetch objects from most recent first and iterate, therefore we insert them at the start, rather than append them.
                    }
                }
            }
            
            
            print("eventRangeLookup: \(eventRangeLookup)")
            print("")
            
            resultsByDay = eventRanges
            
            
            
            
            
            
            print("resultsByDay: \(resultsByDay)")
        }
    }
    
    func reload() {
        DispatchQueue.main.async {
            self.updateDataSource()
            self.tableView.reloadData()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return kSectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == kSectionNewMood || section == kSectionNewEvent {
            return 1
        } else if section == kSectionMoods {
            return results.count
        } else if section == kSectionDays {
            return resultsByDay.count
        }
            
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == kSectionDays {
            return tableView.frame.width / (400 / 200)
        }
        
        return 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == kSectionDays {
            
            let graphCell = tableView.dequeueReusableCell(withIdentifier: "EventGraphTableViewCell", for: indexPath) as! EventGraphTableViewCell
            
            if let days = resultsByDay[indexPath.row].events as? [Event] {
                
                graphCell.type = resultsByDay[indexPath.row].type
                
                // Find the average mood from this range.
                
                var count:Int = 0
                var moodSum:Float = 0
                
                for event in days {
                    if event.type > 0 && event.type < 1000 {
                        // It's a mood
                        
                        let emoji = DataFormatter.moodEmoji(typeInt: Int(event.type))
                        
                        moodSum += emoji.linearMood
                        count += 1
                    }
                }
                
                var averageMoodEmoji:String?
                
                if count > 0 {
                    let averageMood = moodSum / Float(count)
                    
                    if averageMood >= -1 {
                        // Sad
                        averageMoodEmoji = DataFormatter.moodEmoji(type: EventType.sad).emoji
                    }
                    
                    if averageMood >= -0.6 {
                        // Down
                        averageMoodEmoji = DataFormatter.moodEmoji(type: EventType.down).emoji
                    }
                    
                    if averageMood >= -0.2 {
                        // Neutral
                        averageMoodEmoji = DataFormatter.moodEmoji(type: EventType.neutral).emoji
                    }
                    
                    if averageMood >= 0.2 {
                        // Calm
                        averageMoodEmoji = DataFormatter.moodEmoji(type: EventType.calm).emoji
                    }
                    
                    if averageMood >= 0.6 {
                        // Great
                        averageMoodEmoji = DataFormatter.moodEmoji(type: EventType.excited).emoji
                    }
                }
                
                let dateString = resultsByDay[indexPath.row].startDateString()
                
                if let averageMoodEmoji = averageMoodEmoji {
                    graphCell.layout(events: days, title: "\(averageMoodEmoji) \(dateString)")
                } else {
                    graphCell.layout(events: days, title: dateString)
                }
            }
            
            graphCell.backgroundColor = UIColor.clear
            
            return graphCell
            
            // EventGraphTableViewCell
            
        } else if indexPath.section == kSectionMoods {
            
            let eventCell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell
            
            let event = results[indexPath.row]
            
            let eventEmoji = DataFormatter.emoji(typeInt: Int(event.type))
            
            eventCell.emojiLabel.text = eventEmoji.emoji
            eventCell.mainLabel.text = eventEmoji.name.capitalized
            
            let df = DateFormatter()
            df.timeStyle = DateFormatter.Style.short
            df.dateStyle = DateFormatter.Style.none
            
            if let date = event.date {
                eventCell.secondaryLabel.text = df.string(from: date as Date)
            } else {
                eventCell.secondaryLabel.text = "?"
            }
            
            eventCell.backgroundColor = UIColor.clear
            
            return eventCell
        } else if indexPath.section == kSectionNewMood {
            // Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "+ Enter New Mood"
            return cell
        } else if indexPath.section == kSectionNewEvent {
            // Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "+ Enter New Event"
            return cell
        } else {
            // Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Missing Cell"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == kSectionNewMood {
            presentInputView(type: ItemType.mood)
            // self.queryMood()
        } else if indexPath.section == kSectionNewEvent {
            presentInputView(type: ItemType.event)
            // self.queryEvent()
        } else if indexPath.section == kSectionDays {
            
            let range = resultsByDay[indexPath.row]
            
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DayViewController") as? DayViewController {
                
                vc.eventRange = range
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == kSectionDays {
            return [UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Clear", handler: { (action, indexPath) in
                
                let range = self.resultsByDay[indexPath.row]
                
                let alertView = UIAlertController(title: "Delete All Events?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                
                alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                    
                }))

                alertView.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (action) in
                    
                    for event in range.events {
                        DataStore.shared.deleteEvent(event: event)
                    }
                    
                    range.events = [Event]()
                    
                    DataStore.shared.saveContext()
                    
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }))
                
                self.present(alertView, animated: true, completion: { 
                    
                })
            })]
        }
        
        return nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            
        }) { (context) in
            self.reload()
        }
    }
    
    @IBAction func userPressedAddButton(_ sender: UIButton) {
        self.presentInputView(type: ItemType.mood)
    }
    
}


extension Date {
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func firstDayOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func lastMomentOfMonth() -> Date {
        
        return Calendar.current.date(byAdding: DateComponents(month: 1, second: -1), to: self.firstDayOfMonth())!
    }
    
    func firstDayOfMonth(offset: Int) -> Date {
        let calendar: Calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        components.month! += offset
        components.setValue(1, for: .day)
        return calendar.date(from: components)!
    }
    
    
    
    var middleOfDay: Date {
        var components = DateComponents()
        components.hour = 12
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    func startOfDay(offset: Int) -> Date {
        var components = DateComponents()
        components.day = offset
        
        return Calendar.current.date(byAdding: components, to: self.startOfDay)!
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    func addMinutes(offset: Int) -> Date {
        var components = DateComponents()
        components.minute = offset
        return Calendar.current.date(byAdding: components, to: self)!
    }
}
