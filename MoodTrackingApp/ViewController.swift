//
//  ViewController.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 27/03/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var graphView: GraphView!
    
    let kSectionNewMood = 0
    let kSectionNewEvent = 1
    
    let kSectionMoods = 2
    
    let kSectionsCount = 3
    
    var results = [Any]()
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var midLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    
    @IBOutlet weak var styleSelcetor: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.dataStoreSaved), name: NSNotification.Name.init("kDataStoreSaved"), object: nil)
        
    }
    
    func dataStoreSaved() {
        self.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
        drawLine()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
        drawLine()
    }
    
    func date(item: Any) -> NSDate {
        
        if let item = item as? Mood {
            if let date = item.date {
                return date
            }
        } else if let item = item as? Event {
            if let date = item.date {
                return date
            }
        }
        
        return NSDate()
    }
    
    func updateDataSource() {
        if let fetchedMoods = DataStore.shared.fetchAllMoods(), let fetchedEvents = DataStore.shared.fetchAllEvents() {
            
            
            self.results.removeAll()
            
            for item in fetchedMoods {
                self.results.append(item)
            }
            
            for item in fetchedEvents {
                self.results.append(item)
            }
            
            // Sort these items
            self.results.sort(by: { (first, second) -> Bool in
                
                let date1 = self.date(item: first)
                let date2 = self.date(item: second)
                
                return date1.compare(date2 as Date) == ComparisonResult.orderedDescending
            })
        }
        
        if self.styleSelcetor.selectedSegmentIndex == 0 {
            // Mood
            topLabel.text = "Happy"
            midLabel.text = "Neutral"
            lowLabel.text = "Sad"
        } else {
           // Tense
            topLabel.text = "Future"
            midLabel.text = "Present"
            lowLabel.text = "Past"
        }
        
        self.drawLine()
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
        }
            
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == kSectionMoods {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MoodCell", for: indexPath)
            
            cell.textLabel?.text = "Unknown"
            cell.detailTextLabel?.text = nil
            
            if let mood = results[indexPath.row] as? Mood {
                
                let moodEmoji = DataFormatter.moodEmoji(typeInt: Int(mood.type))
                
                cell.textLabel?.text = "\(moodEmoji.emoji) - \(moodEmoji.name)"
                
                if let date = mood.date {
                    cell.detailTextLabel?.text = DataFormatter.shortDate(date: date as Date)
                } else {
                    cell.detailTextLabel?.text = nil
                }
            } else if let event = results[indexPath.row] as? Event {
                
                let eventEmoji = DataFormatter.eventEmoji(typeInt: Int(event.type))
                cell.textLabel?.text = "\(eventEmoji.emoji) \(eventEmoji.name)"
                
                if let date = event.date {
                    cell.detailTextLabel?.text = DataFormatter.shortDate(date: date as Date)
                } else {
                    cell.detailTextLabel?.text = nil
                }
            }
            
            return cell
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
        }
    }
    
    func presentInputView(type: ItemType) {
        if let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CircleViewController") as? CircleViewController {
            
            view.currentMode = type
            view.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            view.modalPresentationCapturesStatusBarAppearance = true
            
            self.present(view, animated: true, completion: { 
                
            })
        }
    }
    
    func queryMood() {
        // Query user for mood
        
        let alert = UIAlertController(title: "I am feeling...", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        for eventType in [MoodType.happy, MoodType.excited, MoodType.neutral, MoodType.sad, MoodType.depressed, MoodType.anxious, MoodType.angry, MoodType.tired] {
            let event = DataFormatter.moodEmoji(type: eventType)
            
            alert.addAction(UIAlertAction(title: event.emoji + " " + event.name.capitalized, style: UIAlertActionStyle.default, handler: { (action) in
                self.createMood(type: eventType)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "❓ Other", style: UIAlertActionStyle.default, handler: { (action) in
            self.queryMoreMoods()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    func queryMoreMoods() {
        // Query user for mood
        
        let alert = UIAlertController(title: "I am feeling...", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        var stringItems = [String]()
        var nameToEvent = [String:MoodType]()
        
        for scale in 1...MoodType.count {
            if let type = MoodType(rawValue: scale) {
                let event = DataFormatter.moodEmoji(type: type)
                stringItems.append(event.name)
                nameToEvent[event.name] = type
            }
        }
        
        stringItems.sort()
        
        for string in stringItems {
            if let eventType = nameToEvent[string] {
                
                let event = DataFormatter.moodEmoji(type: eventType)
                
                alert.addAction(UIAlertAction(title: event.emoji + " " + event.name.capitalized, style: UIAlertActionStyle.default, handler: { (action) in
                    self.createMood(type: eventType)
                }))
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    func queryEvent() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        var stringItems = [String]()
        var nameToEvent = [String:EventType]()
        
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
                
                let event = DataFormatter.eventEmoji(type: eventType)
                
                alert.addAction(UIAlertAction(title: event.emoji + " " + event.name.capitalized, style: UIAlertActionStyle.default, handler: { (action) in
                    self.createEvent(type: eventType)
                }))
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    func createMood(type: MoodType) {
        let _ = DataStore.shared.newMood(type: type, customEmoji: nil, note: nil)
        DataStore.shared.saveContext()
        self.reload()
    }
    
    func createEvent(type: EventType) {
        let _ = DataStore.shared.newEvent(type: type, customEmoji: nil, note: nil)
        DataStore.shared.saveContext()
        self.reload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == kSectionMoods {
            return [UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete", handler: { (action, indexPath) in
                
                if let mood = self.results[indexPath.row] as? Mood {
                    DataStore.shared.deleteMood(mood: mood)
                    
                    DataStore.shared.saveContext()
                    self.updateDataSource()
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                } else if let event = self.results[indexPath.row] as? Event {
                    DataStore.shared.deleteEvent(event: event)
                    
                    DataStore.shared.saveContext()
                    self.updateDataSource()
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                }
            })]
        }
        
        return nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            
        }) { (context) in
            self.drawLine()
        }
    }
    
    func drawLine() {
        if results.count > 0 {
            
            var subResults = [Any]()
            
            if results.count > 10 {
                subResults = Array(results[0...10])
            } else {
                subResults = results
            }
            
            var width:Float = 0.5
            
            if subResults.count > 1 {
                width = 1.0 / Float(subResults.count - 1)
            }
            
            // Need to get the min and max dates in this range
            /*
            var lowDate = Int.max
            var highDate = Int.min
            
            for result in subResults {
                if let result = result as? Mood {
                    if let date = result.date {
                        let thisDate:Int = Int(date.timeIntervalSince1970)
                        
                        if thisDate < lowDate {
                            lowDate = thisDate
                        }
                        
                        if thisDate > highDate {
                            highDate = thisDate
                        }
                    }
                }
            }
            
            print("lowDate:  \(lowDate)")
            print("highDate: \(highDate)")
            
            if lowDate < Int.max && highDate > Int.min {
                highDate -= lowDate
                
                print("lowDate:  \(lowDate)")
                print("highDate: \(highDate)")
                
                print("")
                
                
            }
            
 */
            
            var items = [Float]()
            var dists = [Float]()
            var labels = [String]()
            
            var count = 0
            var lastResult:Float = 0.5
            
            for result in subResults.reversed() {
                if let result = result as? Mood {
                    
                    let moodEmoji = DataFormatter.moodEmoji(typeInt: Int(result.type))
                    
                    labels.append(moodEmoji.emoji)
                    
                    var scale = (moodEmoji.linearMood - 1) / -2
                    
                    if styleSelcetor.selectedSegmentIndex == 1 {
                        scale = (moodEmoji.tense - 1) / -2
                    }
                    
                    lastResult = scale
                    items.append(Float(scale))
                    
                    var xPos:Float = 1 - (width * Float(count))
                    
                    if subResults.count == 1 {
                        xPos = 0.5
                    }
                    
                    //                        if let date = result.date {
                    //                            let thisDate:Int = Int(date.timeIntervalSince1970)
                    //                            xPos = 1 - (Float(thisDate - lowDate) / Float(highDate))
                    //                        }
                    
                    dists.append(xPos)
                    
                    count += 1
                    
                } else if let result = result as? Event {
                    
                    let eventEmoji = DataFormatter.eventEmoji(typeInt: Int(result.type))
                    
                    labels.append(eventEmoji.emoji + "*")
                    
                    items.append(Float(lastResult))
                    
                    let xPos:Float = 1 - (width * Float(count))
                    
                    dists.append(xPos)
                    
                    count += 1
                }
            }
            
            graphView.updateLabels(results: items, dist: dists, labels: labels)
            return
        }
        
        graphView.updateLabels(results: [Float](), dist: [Float](), labels: [String]())
    }
    
    
    @IBAction func styleSelectorValueChanged(_ sender: UISegmentedControl) {
        self.updateDataSource()
    }
}

