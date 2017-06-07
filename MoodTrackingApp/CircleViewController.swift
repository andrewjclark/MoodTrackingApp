//
//  CircleViewController.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 23/05/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

protocol CircleViewControllerDelegate:class {
    func userCreated(event: Event)
}

class CircleViewController:UIViewController, CircleViewDelegate {
    
    var delegate:CircleViewControllerDelegate?
    var eventRange:EventRange?
    
    @IBOutlet weak var circleView: CircleView!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var currentItem:CircleItem?
    
    var currentIndexPath:IndexPath?
    
    var currentMode = ItemType.mood
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circleView.delegate = self
        updateCircleView()
        updateView()
        
        if currentMode == .event {
            segmentedControl.selectedSegmentIndex = 1
        }
        
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circleView.drawEmoji()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            
        }) { (context) in
            
        }
    }
    
    func userSelected(indexPath: IndexPath?, item: CircleItem?) {
        
        if let item = item {
            currentItem = item
        }
        
        self.updateView()
    }
    
    
    func updateView() {
        
        var emoji = ""
        var name = ""
        
        if let item = currentItem {
            
            let bundle = DataFormatter.emoji(typeInt: item.itemType)
            
            emoji = bundle.emoji
            name = bundle.name.capitalized
        }
        
        let emojiFont = UIFont.systemFont(ofSize: 40)
        let nameFont = UIFont.systemFont(ofSize: 20)
        let divideFont = UIFont.systemFont(ofSize: 10)
        
        var attrString = NSMutableAttributedString(string: emoji, attributes: [NSFontAttributeName: emojiFont])
        
        attrString.append(NSAttributedString(string: "\n", attributes: [NSFontAttributeName : divideFont]))
        
        attrString.append(NSAttributedString(string: "\n\(name)", attributes: [NSFontAttributeName : nameFont, NSForegroundColorAttributeName: UIColor.white]))
        
        self.mainLabel.backgroundColor = UIColor.clear
        self.mainLabel.attributedText = attrString
        
        if currentMode == .mood {
            segmentedControl.selectedSegmentIndex = 0
        } else {
            segmentedControl.selectedSegmentIndex = 1
        }
        
        self.updateSaveButton()
    }
    
    func updateSaveButton() {
        if let currentItem = currentItem {
            self.saveButton.isHidden = false
        } else {
            self.saveButton.isHidden = true
        }
    }
    
    func updateCircleView() {
        // Mood Set
        if (self.currentMode == ItemType.mood) {
            let dataSet = [[EventType.neutral.rawValue],[EventType.calm.rawValue, EventType.nervous.rawValue, EventType.down.rawValue],[EventType.happy.rawValue, EventType.excited.rawValue, EventType.anxious.rawValue, EventType.angry.rawValue, EventType.sad.rawValue, EventType.depressed.rawValue]]
            
            var newDataSet = [[CircleItem]]()
            
            for section in dataSet {
                
                var items = [CircleItem]()
                
                for item in section {
                    
                    let bundle = DataFormatter.emoji(typeInt: item)
                    
                    let newCircleItem = CircleItem()
                    newCircleItem.emoji = bundle.emoji
                    newCircleItem.type = ItemType.mood
                    newCircleItem.itemType = item
                    
                    items.append(newCircleItem)
                }
                
                newDataSet.append(items)
            }
            
            
            if let currentItem = currentItem {
                circleView.selectedItem = indexPath(dataSet: newDataSet, selectedItem: currentItem)
            } else {
                circleView.selectedItem = nil
            }
            
            circleView.dataSet = newDataSet
        } else {
            // Events
            
            let dataSet = [[EventType.wastedtime.rawValue], [EventType.caffeine.rawValue, EventType.food_healthy.rawValue, EventType.study.rawValue, EventType.walk.rawValue, EventType.media.rawValue, EventType.social_friend.rawValue, EventType.date.rawValue], [EventType.alcohol.rawValue, EventType.food_junk.rawValue, EventType.work.rawValue, EventType.exercise.rawValue, EventType.adventure.rawValue, EventType.social_event.rawValue, EventType.sex.rawValue], [EventType.drugs.rawValue, EventType.food_sweet.rawValue, EventType.created.rawValue, EventType.spiritual.rawValue, EventType.travel.rawValue, EventType.social_party.rawValue, EventType.kink.rawValue]]
            
            var newDataSet = [[CircleItem]]()
            
            for section in dataSet {
                
                var items = [CircleItem]()
                
                for item in section {
                    
                    let bundle = DataFormatter.eventEmoji(typeInt: item)
                    
                    let newCircleItem = CircleItem()
                    newCircleItem.emoji = bundle.emoji
                    newCircleItem.type = ItemType.event
                    newCircleItem.itemType = item
                    
                    items.append(newCircleItem)
                }
                
                newDataSet.append(items)
            }
            
            if let currentItem = currentItem {
                circleView.selectedItem = indexPath(dataSet: newDataSet, selectedItem: currentItem)
                
            } else {
                circleView.selectedItem = nil
            }
            
            circleView.dataSet = newDataSet
        }
        
        if currentMode == .mood {
            segmentedControl.selectedSegmentIndex = 0
        } else {
            segmentedControl.selectedSegmentIndex = 1
        }
        
        circleView.setNeedsDisplay()
        circleView.drawEmoji()
    }
    
    func indexPath(dataSet: [[CircleItem]], selectedItem: CircleItem) -> IndexPath? {
        
        var sectionCount = 0
        for section in dataSet {
            
            var itemCount = 0
            
            for item in section {
                
                if selectedItem.itemType == item.itemType && selectedItem.type == item.type {
                    return IndexPath(row: itemCount, section: sectionCount)
                }
                
                itemCount += 1
            }
            
            sectionCount += 1
        }
        
        return nil
    }
    
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            self.currentMode = .mood
        } else {
            self.currentMode = .event
        }
        
        updateCircleView()
    }
    
    
    func newEventDate() -> Date {
        
        if let range = eventRange {
            
            let rangeStartDate = range.startDate
            
            if rangeStartDate.startOfDay == Date().startOfDay {
                // This is todays date! Try and post it now.
                return Date()
            }
            
            // This range represents a previous range. Get the last event and add 15 minutes.
            
            if let event = range.events.first {
                if let date = event.date {
                    return (date as Date).addMinutes(offset: 15)
                }
            }
            
            // We have no relevant event, just get the noon time
            return rangeStartDate.middleOfDay
        }
        
        return Date()
    }
    
    @IBAction func userPressedSave(_ sender: UIButton) {
        
        if let item = currentItem {
            
            if item.type == .event {
                // Event
                if let eventType = EventType(rawValue: item.itemType) {
                    if let event = DataStore.shared.newEvent(type: eventType, customEmoji: nil, note: nil, date: newEventDate()) {
                        
                        if let delegate = delegate {
                            delegate.userCreated(event: event)
                        }
                    }
                }
            } else {
                // Mood
                if let moodType = EventType(rawValue: item.itemType) {
                    if let event = DataStore.shared.newMood(type: moodType, customEmoji: nil, note: nil, date: newEventDate()) {
                        
                        if let delegate = delegate {
                            delegate.userCreated(event: event)
                        }
                    }
                }
            }
            
            currentItem = nil
            
            self.updateCircleView()
            
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                
                self.mainLabel.frame.origin.y -= 100
                self.mainLabel.alpha = 0.0
                self.saveButton.alpha = 0.0
                
            }, completion: { (complete) in
                self.mainLabel.text = nil
                self.mainLabel.frame.origin.y += 100
                self.mainLabel.alpha = 1.0
                self.saveButton.alpha = 1.0
                
                self.updateView()
            })
        }
        
        DataStore.shared.saveContext()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
        }
    }
}

class CircleItem:CustomStringConvertible {
    var type = ItemType.mood
    var itemType = 0
    var emoji:String?
    var color:UIColor?
    
    var description: String {
        return "\(type)-\(itemType)\n(\(emoji))"
    }
}
