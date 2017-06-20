//
//  DayViewController.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 31/05/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class DayViewController: MoodViewController, UITableViewDelegate, UITableViewDataSource, DatePickerViewControllerDelegate {
    
    var eventRange = EventRange()
    
    let kSectionAddNew = 0
    let kSectionEvents = 1
    
    let kSectionCount = 2
    
    @IBOutlet weak var tableView: UITableView!
    var datePicker:UIDatePicker?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.moodBlue
        tableView.backgroundColor = UIColor.moodBlue
        
        tableView.dataSource = self
        tableView.delegate = self
        // tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        for cellName in ["EventTableViewCell"] {
            let nib = UINib(nibName: cellName, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: cellName)
        }
        
        self.navigationItem.title = eventRange.startDateString()
        
        setupRightBarButton(editing: false)
    }
    
    func setupRightBarButton(editing: Bool) {
        if editing {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DayViewController.userPressedEditButton))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DayViewController.userPressedEditButton))
        }
    }
    
    func userPressedEditButton() {
        if self.tableView.isEditing {
            self.eventRange.performFetch()
            self.tableView.setEditing(false, animated: true)
            self.setupRightBarButton(editing: self.tableView.isEditing)
        } else {
            self.tableView.setEditing(true, animated: true)
            setupRightBarButton(editing: tableView.isEditing)
        }
    }
    
    override func prefersHiddenNavBar() -> Bool {
        return false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return kSectionCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == kSectionEvents {
            return eventRange.events.count
        } else if section == kSectionAddNew {
            return 1
        }
        
        return 0
    }
    
    func event(indexPath: IndexPath) -> Event? {
        let events = self.eventRange.events
        
        if indexPath.row < events.count {
            return events[indexPath.row]
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != kSectionAddNew
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        //return true
        return indexPath.section != kSectionAddNew
    }
    
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section == kSectionAddNew {
            return IndexPath(item: proposedDestinationIndexPath.row, section: kSectionEvents)
        }
        
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let event = eventRange.events[sourceIndexPath.row]
        
        // Remove the event at this index from eventRange, put it in the new position, then rectify the times
        
        var eventAbove:Event?
        var eventBelow:Event?
        
        if destinationIndexPath.row < sourceIndexPath.row {
            
            // Move up
            if destinationIndexPath.row > 0 {
                eventAbove = eventRange.events[destinationIndexPath.row - 1]
            }
            
            eventBelow = eventRange.events[destinationIndexPath.row]
        } else if destinationIndexPath.row > sourceIndexPath.row {
            // Move down
            
            eventAbove = eventRange.events[destinationIndexPath.row]
            
            if destinationIndexPath.row < eventRange.events.count - 1 {
                eventBelow = eventRange.events[destinationIndexPath.row + 1]
            }
        }
        
        if let aboveDate = eventAbove?.date, let belowDate = eventBelow?.date {
            print("Split the diff")
            
            let intA = aboveDate.timeIntervalSince1970
            let intB = belowDate.timeIntervalSince1970
            
            let newDate = Date(timeIntervalSince1970: (intA + intB) / 2)
            
            event.date = newDate as NSDate
            
        } else if let aboveDate = eventAbove?.date {
            print("Moved to bottom of list")
            
            let newDate = (aboveDate as Date).addingTimeInterval(-60)
            event.date = newDate as NSDate
            
        } else if let belowDate = eventBelow?.date {
            print("Moved to top of list")
            
            var newDate = (belowDate as Date).addingTimeInterval(60)
            
            if newDate > Date() {
                // This would result in a time in the future! Average it
                
                let intA = newDate.timeIntervalSince1970
                let intB = Date().timeIntervalSince1970
                
                newDate = Date(timeIntervalSince1970: (intA + intB) / 2)
            }
            
            event.date = newDate as NSDate
            
        }
        
        // Reload the date of this cell.
        if let cell = tableView.cellForRow(at: sourceIndexPath) as? EventTableViewCell {
            configure(cell: cell, event: event)
        }
        
        DataStore.shared.saveContext()
        
        eventRange.events.remove(at: sourceIndexPath.row)
        eventRange.events.insert(event, at: destinationIndexPath.row)
        self.tableView.reloadData()
        
        
        print("eventAbove: \(eventAbove?.type)")
        print("eventBelow: \(eventBelow?.type)")
        
        print("sourceIndexPath: \(sourceIndexPath)")
        print("destinationIndexPath: \(destinationIndexPath)")
        
    }
    
    func configure(cell: EventTableViewCell, event: Event) {
        let eventEmoji = DataFormatter.emoji(typeInt: Int(event.type))
        
        cell.emojiLabel.text = eventEmoji.emoji
        cell.mainLabel.text = eventEmoji.name.capitalized
        
        let df = DateFormatter()
        df.timeStyle = DateFormatter.Style.short
        df.dateStyle = DateFormatter.Style.none
        
        if let date = event.date {
            cell.secondaryLabel.text = df.string(from: date as Date)
        } else {
            cell.secondaryLabel.text = "?"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell
        
        if indexPath.section == kSectionEvents {
            if let event = event(indexPath: indexPath) {
                configure(cell: eventCell, event: event)
            }
        } else if indexPath.section == kSectionAddNew {
            eventCell.selectionStyle = UITableViewCellSelectionStyle.default
            eventCell.emojiLabel.text = nil
            eventCell.mainLabel.text = "Add New"
            eventCell.secondaryLabel.text = nil
        }
        
        eventCell.backgroundColor = UIColor.clear
        
        return eventCell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete") { (action, indexPath) in
            if let event = self.event(indexPath: indexPath) {
                DataStore.shared.deleteEvent(event: event)
                DataStore.shared.saveContext()
                
                self.eventRange.events.remove(at: indexPath.row)
                
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }
            }
        }
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == kSectionAddNew {
            
            self.presentInputView(type: ItemType.mood)
            
//            if let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CircleViewController") as? CircleViewController {
//                
//                view.currentMode = .mood
//                view.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
//                view.modalPresentationCapturesStatusBarAppearance = true
//                view.delegate = self
//                view.eventRange = self.eventRange
//                
//                self.present(view, animated: true, completion: {
//                    
//                })
//            }
        } else {
            // Show date picker.
            if let event = event(indexPath: indexPath) {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DatePickerViewController") as? DatePickerViewController {
                    
                    vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                    
                    vc.event = event
                    vc.delegate = self
                    
                    self.present(vc, animated: true, completion: {
                        
                    })
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let event = self.event(indexPath: indexPath) {
                DataStore.shared.deleteEvent(event: event)
                DataStore.shared.saveContext()
                
                self.eventRange.events.remove(at: indexPath.row)
            }
        }
    }
    
    override func userCreated(event: Event) {
        eventRange.performFetch()
        self.tableView.reloadData()
    }
    
    func eventUpdated(event: Event) {
        eventRange.performFetch()
        self.tableView.reloadData()
    }
}
