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
    
    @IBOutlet weak var bottomLeftCircleView: CircleView!
    
    @IBOutlet weak var bottomRightCircleView: CircleView!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var emojiLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var currentItem:CircleItem?
    
    var currentIndexPath:IndexPath?
    
    var currentMode = ItemType.mood
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var mainView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentMode == .event {
            // Event
            let bundle = DataFormatter.emoji(typeInt: EventType.wastedtime.rawValue)
            
            let newCircleItem = CircleItem()
            newCircleItem.emoji = bundle.emoji
            newCircleItem.type = ItemType.event
            newCircleItem.itemType = EventType.wastedtime.rawValue
            
            currentItem = newCircleItem
            
            segmentedControl.selectedSegmentIndex = 1
        } else {
            // Mood
            
            let bundle = DataFormatter.emoji(typeInt: EventType.neutral.rawValue)
            
            let newCircleItem = CircleItem()
            newCircleItem.emoji = bundle.emoji
            newCircleItem.type = ItemType.mood
            newCircleItem.itemType = EventType.neutral.rawValue
            
            currentItem = newCircleItem
        }
        
        // Circle View delegates
        
        circleView.delegate = self
        bottomLeftCircleView.delegate = self
        bottomRightCircleView.delegate = self
        
        updateCircleView()
        updateView()
        
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCircleView()
        updateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCircleView()
        updateView()
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
        self.updateCircleView()
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
        
        self.mainLabel.backgroundColor = UIColor.clear
        self.mainLabel.text = name
        self.mainLabel.font = nameFont
        
        self.emojiLabel.backgroundColor = UIColor.clear
        self.emojiLabel.text = emoji
        self.emojiLabel.font = emojiFont
        
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
            
            
            // Bottom Left
            
            let bottomLeftBundle = DataFormatter.emoji(typeInt: EventType.inspired.rawValue)
            
            let bottomLeftItem = CircleItem()
            bottomLeftItem.emoji = bottomLeftBundle.emoji
            bottomLeftItem.type = ItemType.mood
            bottomLeftItem.itemType = EventType.inspired.rawValue
            
            if let currentItem = currentItem {
                bottomLeftCircleView.selectedItem = indexPath(dataSet: [[bottomLeftItem]], selectedItem: currentItem)
            } else {
                bottomLeftCircleView.selectedItem = nil
            }
            
            bottomLeftCircleView.dataSet = [[bottomLeftItem]]
            
            // Bottom Right
            
            let bottomRightBundle = DataFormatter.emoji(typeInt: EventType.sick.rawValue)
            
            let bottomRightItem = CircleItem()
            bottomRightItem.emoji = bottomRightBundle.emoji
            bottomRightItem.type = ItemType.mood
            bottomRightItem.itemType = EventType.sick.rawValue
            
            if let currentItem = currentItem {
                bottomRightCircleView.selectedItem = indexPath(dataSet: [[bottomRightItem]], selectedItem: currentItem)
            } else {
                bottomRightCircleView.selectedItem = nil
            }
            
            bottomRightCircleView.dataSet = [[bottomRightItem]]
            
            
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
            
            // Bottom Left
            
            let bottomLeftBundle = DataFormatter.emoji(typeInt: EventType.tragedy.rawValue)
            
            let bottomLeftItem = CircleItem()
            bottomLeftItem.emoji = bottomLeftBundle.emoji
            bottomLeftItem.type = ItemType.event
            bottomLeftItem.itemType = EventType.tragedy.rawValue
            
            if let currentItem = currentItem {
                bottomLeftCircleView.selectedItem = indexPath(dataSet: [[bottomLeftItem]], selectedItem: currentItem)
            } else {
                bottomLeftCircleView.selectedItem = nil
            }
            
            bottomLeftCircleView.dataSet = [[bottomLeftItem]]
            
            // Bottom Right
            
            let bottomRightBundle = DataFormatter.emoji(typeInt: EventType.period.rawValue)
            
            let bottomRightItem = CircleItem()
            bottomRightItem.emoji = bottomRightBundle.emoji
            bottomRightItem.type = ItemType.mood
            bottomRightItem.itemType = EventType.period.rawValue
            
            if let currentItem = currentItem {
                bottomRightCircleView.selectedItem = indexPath(dataSet: [[bottomRightItem]], selectedItem: currentItem)
            } else {
                bottomRightCircleView.selectedItem = nil
            }
            
            bottomRightCircleView.dataSet = [[bottomRightItem]]
        }
        
        if currentMode == .mood {
            segmentedControl.selectedSegmentIndex = 0
        } else {
            segmentedControl.selectedSegmentIndex = 1
        }
        
        
        
        
        
        
        bottomLeftCircleView.setNeedsDisplay()
        bottomLeftCircleView.drawEmoji()
        
        bottomRightCircleView.setNeedsDisplay()
        bottomRightCircleView.drawEmoji()
        
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
            
            
            if let event = range.events.first {
                if let date = event.date {
                    if date as Date > Date() {
                        // The last date for this event is in the future?! Add 1 min to it
                        return (date as Date).addMinutes(offset: 1)
                    }
                }
            }
            
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
                self.emojiLabel.frame.origin.y -= 100
                self.mainLabel.alpha = 0.0
                self.emojiLabel.alpha = 0.0
                self.saveButton.alpha = 0.0
                
            }, completion: { (complete) in
                self.mainLabel.text = nil
                self.mainLabel.frame.origin.y += 100
                self.emojiLabel.frame.origin.y += 100
                self.mainLabel.alpha = 1.0
                self.emojiLabel.alpha = 1.0
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            
            if location.y < (self.view.frame.height - mainView.frame.height) {
                self.dismiss(animated: true, completion: { 
                    
                })
            }
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
