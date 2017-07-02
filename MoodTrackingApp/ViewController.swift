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
    case months
    case summary
    case custom
}

class EventRange:CustomStringConvertible {
    var startDate = Date()
    var endDate:Date?
    var events = [Event]()
    var type = GroupType.day
    
    var description: String {
        let df = DateFormatter()
        df.timeStyle = DateFormatter.Style.short
        df.dateStyle = DateFormatter.Style.short
        
        if let endDate = endDate {
            return "EventRange: \(df.string(from: startDate)) to \(df.string(from: endDate)) with type \(type) and \(events.count) events"
        } else {
            return "EventRange: \(df.string(from: startDate)) to INFINITY with type \(type) and \(events.count) events"
        }
    }
    
    func startDateString() -> String {
        
        if type == .summary {
            return "Summary"
        }
        
        let df = DateFormatter()
        df.dateFormat = "EEE, d MMM"
        
        if type == .day {
            if startDate.startOfDay == Date().startOfDay {
                // This is todays date! Try and post it now.
                return "Today"
            } else {
                return df.string(from: startDate)
            }
        } else if type == .custom {
            
            // Determine how many days ago this is
            let calendar = NSCalendar.current
            
            let date1 = startDate.startOfDay
            var date2 = Date().startOfDay
            
            if let endDate = self.endDate {
                date2 = endDate
                
                if endDate.endOfDay == date2.endOfDay {
                    // We are doing all of this relative to the current day
                    
                    let components = calendar.dateComponents([.day], from: date1, to: date2)
                    
                    if let day = components.day {
                        return "Last \(day) days"
                    } else {
                        return "?"
                    }
                }
            }
            
            df.dateFormat = "d MMM"
            
            return "\(df.string(from: date1)) to \(df.string(from: date2))"
        } else {
            
            // Month
            df.dateFormat = "MMMM, YYYY"
            return df.string(from: startDate)
        }
    }
    
    func numberOfDays() -> Int {
        
        // Determine how many days ago this is
        let calendar = NSCalendar.current
        
        let date1 = startDate.startOfDay
        var date2 = Date().startOfDay
        
        if let endDate = self.endDate {
            date2 = endDate
        }
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        if let day = components.day {
            return day
        }
        
        return 0
    }
    
    func performFetch() {
        if let endDate = endDate {
            if let fetchedEvents = DataStore.shared.fetchEvents(startDate: self.startDate, endDate: endDate) {
                self.events = fetchedEvents
            }
        } else {
            if let fetchedEvents = DataStore.shared.fetchEvents(startDate: self.startDate, endDate: Date()) {
                self.events = fetchedEvents
            }
        }
    }
    
    func subType() -> GroupType {
        switch type {
        case .day:
            return .day
        case .month:
            return .day
        case .months:
            return .month
        case .summary:
            return .summary
        case .custom:
            return .day
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
    
    var eventRange:EventRange? // This defines the scope of the fetch event. If null then just show everything.
    
    var resultsByDay = [EventRange]() // Uses the fetched events from eventRange and groups them
    
    var summaryRange:GroupType? // If this is nil then show it as a normal view, however if it is non null then this is the top level view controller and should show a top menu and refetch when it changes.
    
    @IBOutlet weak var newButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.moodBlue
        tableView.backgroundColor = UIColor.moodBlue
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        newButton.clipsToBounds = false
        newButton.layer.cornerRadius = 44
        newButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        newButton.layer.shadowColor = UIColor.black.cgColor
        newButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        newButton.layer.shadowRadius = 10
        newButton.layer.shadowOpacity = 0.33
        
        for cellName in ["EventTableViewCell", "EventGraphTableViewCell"] {
            let nib = UINib(nibName: cellName, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: cellName)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.dataStoreSaved), name: NSNotification.Name.init("kDataStoreSaved"), object: nil)
        
        // Setup the eventrange and the settings / analysis buttons
        if eventRange == nil {
            self.summaryRange = GroupType.summary
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "66_Gear"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.userPressedSettings))
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "69_Light"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.userPressedData))
        }
        
        updateTitle()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.userPressedBack))
    }
    
    func userPressedSettings() {
        // SettingsViewController
        
        if let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            // Put
            let navCon = UINavigationController(rootViewController: settingsVC)
            self.present(navCon, animated: true) {
                
            }
        }
    }
    
    func userPressedData() {
        // DataAnalysisViewController
        
        if let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DataAnalysisViewController") as? DataAnalysisViewController {
            // Put
            let navCon = UINavigationController(rootViewController: settingsVC)
            self.present(navCon, animated: true) {
                
            }
        }
    }
    
    func userTappedTitle() {
        if summaryRange != nil {
            // Show menu
            
            let alertView = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alertView.addAction(UIAlertAction(title: "Summary", style: UIAlertActionStyle.default, handler: { (action) in
                self.summaryRange = GroupType.summary
                self.reload()
                self.updateTitle()
            }))
            
            alertView.addAction(UIAlertAction(title: "Months", style: UIAlertActionStyle.default, handler: { (action) in
                self.summaryRange = GroupType.months
                self.reload()
                self.updateTitle()
            }))
            
            alertView.addAction(UIAlertAction(title: "Days", style: UIAlertActionStyle.default, handler: { (action) in
                self.summaryRange = GroupType.month
                self.reload()
                self.updateTitle()
            }))
            
            alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                
            }))
            
            present(alertView, animated: true, completion: {
                
            })
            
        }
    }
    
    func userPressedBack() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        }
    }
    
    func updateTitle() {
        var newTitle = ""
        
        if summaryRange != nil {
            newTitle = "  "
        }
        
        if let summaryRange = summaryRange {
            switch summaryRange {
            case .summary:
                newTitle += "Summary"
            case .months:
                newTitle += "Months"
            case .month:
                newTitle += "Days"
            default:
                newTitle += "???"
            }
            
        } else if let eventRange = eventRange {
            newTitle += eventRange.startDateString()
        }
        
        let newTitleAttr = NSMutableAttributedString(string: newTitle, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium), NSForegroundColorAttributeName:UIColor.white])
        
        // Add a down arrow
        if summaryRange != nil {
            newTitleAttr.append(NSAttributedString(string: " ▼", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium), NSForegroundColorAttributeName:UIColor.white.withAlphaComponent(0.5)]))
        }
        
        // Setup the UILabel
        
        if let label = navigationItem.titleView as? UILabel {
            label.removeFromSuperview()
        }
        
        // Setup title tap
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(ViewController.userTappedTitle))
        
        let titleView = UILabel()
        titleView.attributedText = newTitleAttr
        titleView.backgroundColor = UIColor.clear
        titleView.isUserInteractionEnabled = true
        self.navigationItem.titleView = titleView
        titleView.sizeToFit()
        
        if summaryRange != nil {
            if let titleView = self.navigationItem.titleView {
                titleView.addGestureRecognizer(tapRec)
            }
        }
        
        navigationController?.navigationBar.barStyle = UIBarStyle.blackOpaque
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.moodBlue
        navigationController?.navigationBar.isTranslucent = false
    }
    
    
    func userPressedReload() {
        self.reload()
    }
    
    func dataStoreSaved() {
        //self.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    override func prefersHiddenNavBar() -> Bool {
        return false
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
        
        if let summaryRange = summaryRange {
            
            // Create an event range
            let newRange = EventRange()
            
            switch summaryRange {
            case .summary:
                newRange.startDate = Date().firstDayOfMonth(offset: -3)
            case .months:
                newRange.startDate = Date().firstDayOfMonth(offset: -12)
            case .month:
                newRange.startDate = Date().firstDayOfMonth(offset: -3)
            default:
                newRange.startDate = Date().firstDayOfMonth(offset: -3)
            }
            
            newRange.type = summaryRange
            
            self.eventRange = newRange
        }
        
        if let eventRange = eventRange {
            // We have an event range, use these events
            print("eventRange.type: \(eventRange.type)")
            print("eventRange.startDate: \(eventRange.startDate)")
            print("eventRange.endDate: \(eventRange.endDate)")
            
            // We need to fetch these results.
            
            eventRange.performFetch()
            
            if eventRange.type == .summary {
                
                // Get events for today
                
                var newResultsByDay = [EventRange]()
                
                
                let todayStartDate = Date().startOfDay
                let weekStartDate = Date().startOfDay(offset: -7)
                let monthStartDate = Date().startOfDay(offset: -30)
                let thisMonthStartDate = Date().firstDayOfMonth(offset: 0).startOfDay
                let lastMonthStartDate = Date().firstDayOfMonth(offset: -1).startOfDay
                
                
                let dayRange = EventRange()
                dayRange.startDate = todayStartDate
                dayRange.endDate = Date().endOfDay
                dayRange.type = .day
                dayRange.performFetch()
                
                newResultsByDay.append(dayRange)
                
                
                let weekRange = EventRange()
                weekRange.startDate = weekStartDate
                weekRange.endDate = Date().endOfDay
                weekRange.type = .custom
                weekRange.performFetch()
                
                newResultsByDay.append(weekRange)
                
                
                let monthRange = EventRange()
                monthRange.startDate = monthStartDate
                monthRange.endDate = Date().endOfDay
                monthRange.type = .custom
                monthRange.performFetch()
                
                newResultsByDay.append(monthRange)
                
                // This Month
                for number in 0...6 {
                    let thisMonthRange = EventRange()
                    thisMonthRange.startDate = Date().firstDayOfMonth(offset: number * -1).startOfDay
                    thisMonthRange.endDate = thisMonthRange.startDate.lastMomentOfMonth()
                    thisMonthRange.type = .month
                    thisMonthRange.performFetch()
                    
                    newResultsByDay.append(thisMonthRange)
                }
                
                
                
                self.resultsByDay = newResultsByDay
                
            } else {
                self.resultsByDay = eventRanges(from: eventRange.events, type: eventRange.subType(), withinRange: eventRange)
            }
        }
    }
    
    func eventRanges(from events: [Event], type: GroupType, withinRange:EventRange?) -> [EventRange] {
        
        let df = DateFormatter()
        
        df.timeStyle = DateFormatter.Style.medium
        df.dateStyle = DateFormatter.Style.medium
        
        var eventRanges = [EventRange]()
        
        // Get event ranges for each preceeding day.
        if let event = withinRange {
            // This is a scoped event range, get the days / months within it.
            
            var currentDate = event.startDate.startOfDay
            var endDate = Date()
            
            if let newEndDate = event.endDate {
                endDate = newEndDate
            }
            
            if type == .day {
                
                while currentDate < endDate && currentDate < Date()  {
                    
                    let newRange = EventRange()
                    newRange.startDate = currentDate
                    newRange.endDate = currentDate.endOfDay
                    newRange.type = GroupType.day
                    
                    eventRanges.append(newRange)

                    // Move currentDate up by a day
                    currentDate = currentDate.startOfDay(offset: 1)
                }
                
                // Flip the events
                eventRanges.reverse()
                df.dateFormat = "DD MMM YYYY"
                
            } else if type == .month {
                
                while currentDate < endDate && currentDate < Date()  {
                    
                    let newRange = EventRange()
                    newRange.startDate = currentDate
                    newRange.endDate = currentDate.lastMomentOfMonth()
                    newRange.type = GroupType.month
                    
                    eventRanges.append(newRange)
                    
                    // Move currentDate up by a month
                    
                    currentDate = currentDate.firstDayOfMonth(offset: 1).startOfDay
                }
                
                // Flip the events
                eventRanges.reverse()
                df.dateFormat = "MMM YYYY"
            }
            
        }
        
        // We now have the ranges and need to iterate through the events and dump them in there if the days line up.
        
        var eventRangeLookup = [String:EventRange]()
        
        for range in eventRanges {
            let string = df.string(from: range.startDate)
            eventRangeLookup[string] = range
        }
        
        for event in events {
            if let date = event.date {
                
                let dateString = df.string(from: date as Date)
                
                if let range = eventRangeLookup[dateString] {
                    range.events.append(event)
                }
            }
        }
 
        return eventRanges
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
        if section == kSectionDays {
            return resultsByDay.count
        }
            
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == kSectionDays {
            
            let range = resultsByDay[indexPath.row]
            
            if range.events.count == 0 {
                return 100
            }
            
            return tableView.frame.width / (400 / 200)
        }
        
        return 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == kSectionDays {
            
            let graphCell = tableView.dequeueReusableCell(withIdentifier: "EventGraphTableViewCell", for: indexPath) as! EventGraphTableViewCell
            
            let eventRange = resultsByDay[indexPath.row]
            
            let days = eventRange.events
            
            graphCell.type = eventRange.type
            
            switch eventRange.type {
            case .day:
                graphCell.displayFormat = .time
            case .month:
                graphCell.displayFormat = .day
            case .months:
                graphCell.displayFormat = .day
            case .summary:
                graphCell.displayFormat = .day
            case .custom:
                if eventRange.numberOfDays() <= 7 {
                    graphCell.displayFormat = .weekday
                } else {
                    graphCell.displayFormat = .day
                }
            }
            
            // Find the average mood from this range.
            var count:Int = 0
            var moodSum:Float = 0
            
            for event in days {
                let emoji = DataFormatter.emoji(typeInt: Int(event.type))
                
                if let linearMood = emoji.linearMood {
                    moodSum += linearMood
                    count += 1
                }
            }
            
            var averageMoodEmoji:String?
            
            if count > 0 {
                let averageMood = moodSum / Float(count)
                averageMoodEmoji = GraphEvent(averageLinearMood: averageMood, date: nil).emoji
            }
            
            let dateString = resultsByDay[indexPath.row].startDateString()
            
            if let averageMoodEmoji = averageMoodEmoji {
                graphCell.layout(events: days.reversed(), title: "\(averageMoodEmoji) \(dateString)")
            } else {
                graphCell.layout(events: days.reversed(), title: dateString)
            }
            
            graphCell.backgroundColor = UIColor.clear
            
            return graphCell
            
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
        
        if indexPath.section == kSectionDays {
            
            let range = resultsByDay[indexPath.row]
            
            if range.type == .day {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DayViewController") as? DayViewController {
                    
                    vc.eventRange = range
                    
                    navigationController?.pushViewController(vc, animated: true)
                }
            } else if range.type == .month {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                    
                    vc.eventRange = range
                    
                    navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                    
                    vc.eventRange = range
                    
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == kSectionDays {
            
            let clearAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Clear", handler: { (action, indexPath) in
                
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
                    
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                }))
                
                self.present(alertView, animated: true, completion: {
                    
                })
            })
            
            let addAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Add", handler: { (action, indexPath) in
                
                let range = self.resultsByDay[indexPath.row]
                
                self.presentInputView(type: ItemType.mood, eventRange: range)
                
                
            })
            
            addAction.backgroundColor = UIColor.lightMoodBlue
            
            
            return [clearAction, addAction]
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
        
//        if let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CircleViewController") as? CircleViewController {
//            
//            view.currentMode = .mood
//            view.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
//            view.modalPresentationCapturesStatusBarAppearance = true
//            view.delegate = self
//            
//            self.present(view, animated: true, completion: {
//                
//            })
//        }
    }
    
    override func userCreated(event: Event) {
        self.reload()
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
    
    func addSeconds(offset: Int) -> Date {
        var components = DateComponents()
        components.second = offset
        return Calendar.current.date(byAdding: components, to: self)!
    }
}
