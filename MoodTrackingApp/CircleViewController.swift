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
    
    @IBOutlet weak var topLeftCircleView: CircleView!
    
    @IBOutlet weak var topRightCircleView: CircleView!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var emojiLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var currentItem:CircleItem?
    
    var currentIndexPath:IndexPath?
    
    var currentMode = ItemType.mood
    
    var circleItemSetup = false
    
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
        topLeftCircleView.delegate = self
        topRightCircleView.delegate = self
        
        
        circleView.isUserInteractionEnabled = false
        bottomLeftCircleView.isUserInteractionEnabled = false
        bottomRightCircleView.isUserInteractionEnabled = false
        topLeftCircleView.isUserInteractionEnabled = false
        topRightCircleView.isUserInteractionEnabled = false
        
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
        
        var previousType = 0
        var newType = 0
        
        if let currentItem = currentItem {
            previousType = currentItem.itemType
        }
        
        if let item = item {
            currentItem = item
            newType = item.itemType
            
            print("previousType: \(previousType)")
            print("newType: \(newType)")
            print("")
            
            if previousType != newType {
                playSelectSound()
            }
        }
        
        self.updateView()
        self.updateCircleView()
    }
    
    func playSelectSound() {
        SoundManager.sharedStore.playSound(sound: SoundType.click)
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
        if let _ = currentItem {
            self.saveButton.isHidden = false
        } else {
            self.saveButton.isHidden = true
        }
    }
    
    func setupCircle(circleView: CircleView, items:[[Int]]) {
        
        let dataSet = items
        
        var newDataSet = [[CircleItem]]()
        
        for section in dataSet {
            
            var items = [CircleItem]()
            
            for item in section {
                
                let bundle = DataFormatter.emoji(typeInt: item)
                
                let newCircleItem = CircleItem()
                newCircleItem.emoji = bundle.emoji
                
                if item >= 1000 {
                    newCircleItem.type = ItemType.event
                } else {
                    newCircleItem.type = ItemType.mood
                }
                
                newCircleItem.itemType = item
                
                items.append(newCircleItem)
            }
            
            newDataSet.append(items)
        }
        
        circleView.dataSet = newDataSet
    }
    
    func updateCircleView() {
        
        if !circleItemSetup {
            if (self.currentMode == ItemType.mood) {
                // Moods
                
                setupCircle(circleView: circleView, items: [[EventType.neutral.rawValue],[EventType.calm.rawValue, EventType.nervous.rawValue, EventType.down.rawValue, EventType.bored.rawValue],[EventType.happy.rawValue, EventType.excited.rawValue, EventType.anxious.rawValue, EventType.angry.rawValue, EventType.sad.rawValue, EventType.depressed.rawValue, EventType.sick.rawValue, EventType.tired.rawValue]])
                
                //setupCircle(circleView: bottomLeftCircleView, items: [[EventType.inspired.rawValue]])
                
                //setupCircle(circleView: bottomRightCircleView, items: [[EventType.sick.rawValue]])
                
//                setupCircle(circleView: topLeftCircleView, items: [[EventType.tired.rawValue]])
//                
//                setupCircle(circleView: topRightCircleView, items: [[EventType.bored.rawValue]])
                
                bottomLeftCircleView.isHidden = true
                bottomRightCircleView.isHidden = true
                topLeftCircleView.isHidden = true
                topRightCircleView.isHidden = true
                
            } else {
                // Events
                
                setupCircle(circleView: circleView, items: [[EventType.wastedtime.rawValue], [EventType.caffeine.rawValue, EventType.food_healthy.rawValue, EventType.study.rawValue, EventType.walk.rawValue, EventType.media.rawValue, EventType.social_friend.rawValue, EventType.date.rawValue], [EventType.alcohol.rawValue, EventType.food_junk.rawValue, EventType.work.rawValue, EventType.exercise.rawValue, EventType.adventure.rawValue, EventType.social_event.rawValue, EventType.sex.rawValue], [EventType.medication.rawValue, EventType.food_sweet.rawValue, EventType.created.rawValue, EventType.spiritual.rawValue, EventType.travel.rawValue, EventType.social_party.rawValue, EventType.period.rawValue]])
                
                setupCircle(circleView: bottomLeftCircleView, items: [[EventType.tragedy.rawValue]])
                
                setupCircle(circleView: bottomRightCircleView, items: [[EventType.period.rawValue]])
                
                bottomLeftCircleView.isHidden = false
                bottomRightCircleView.isHidden = true
                topLeftCircleView.isHidden = true
                topRightCircleView.isHidden = true
                
//                setupCircle(circleView: topLeftCircleView, items: [[EventType.medication.rawValue]])
//                
//                setupCircle(circleView: topRightCircleView, items: [[EventType.slept.rawValue]])
            }
            
            circleItemSetup = true
        }
        
        if currentMode == .mood {
            segmentedControl.selectedSegmentIndex = 0
        } else {
            segmentedControl.selectedSegmentIndex = 1
        }
        
        // Update the selected items
        for theCircleView in [circleView, bottomLeftCircleView, bottomRightCircleView, topLeftCircleView, topRightCircleView] {
            if let theCircleView = theCircleView {
                theCircleView.setupSelectedItem(item: currentItem)
            }
        }
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
        
        circleItemSetup = false
        
        updateCircleView()
    }
    
    
    func newEventDate() -> Date {
        
        if let range = eventRange {
            
            let rangeStartDate = range.startDate
            
            if let event = range.events.first {
                if let date = event.date {
                    if date as Date > Date() {
                        // The last date for this event is in the future?! Add 1 min to it instead
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
                    
                    if (date as Date).addMinutes(offset: 1) >= (date as Date).endOfDay {
                        // Adding 1 minute to this date would bring it into tomorrow, add 1 second instead.
                        return (date as Date).addSeconds(offset: 1)
                    }
                    
                    if (date as Date).addMinutes(offset: 15) >= (date as Date).endOfDay {
                        // Adding 15 minutes to this date would bring it into tomorrow, add 1 minute instead.
                        return (date as Date).addMinutes(offset: 1)
                    }
                    
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
            
            SoundManager.sharedStore.playSound(sound: SoundType.clear)
            
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
            processTouch(touch: touch, force: true)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touch = touches.first {
            processTouch(touch: touch, force: false)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let touch = touches.first {
            processTouch(touch: touch, force: true)
        }
    }
    
    func processTouch(touch: UITouch, force: Bool) {
        let location = touch.location(in: self.view)
        let previousLocation = touch.previousLocation(in: self.view)
        
        if location.y < (self.view.frame.height - mainView.frame.height) {
            self.dismiss(animated: true, completion: {
                
            })
        } else {
            // Process this touch
            
            if force || Int(location.x) != Int(previousLocation.x) || Int(location.y) != Int(previousLocation.y) {
                
                for theView in [circleView, topLeftCircleView, topRightCircleView, bottomLeftCircleView, bottomRightCircleView] {
                    
                    if let theView = theView {
                        let location = touch.location(in: mainView)
                        
                        if theView.frame.contains(location) {
                            theView.processTouch(location: touch.location(in: theView))
                        }
                    }
                }
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
