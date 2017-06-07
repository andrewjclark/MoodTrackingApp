//
//  DayViewController.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 31/05/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class DayViewController: MoodViewController, UITableViewDelegate, UITableViewDataSource, CircleViewControllerDelegate {
    
    var eventRange = EventRange()
    
    let kSectionAddNew = 0
    let kSectionEvents = 1
    
    let kSectionCount = 2
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        let startDate = eventRange.startDate
        
        self.navigationItem.title = eventRange.startDateString()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell
        
        if indexPath.section == kSectionEvents {
            if let event = event(indexPath: indexPath) {
                
                let eventEmoji = DataFormatter.emoji(typeInt: Int(event.type))
                
                eventCell.emojiLabel.text = eventEmoji.emoji
                eventCell.mainLabel.text = eventEmoji.name.capitalized
                eventCell.selectionStyle = UITableViewCellSelectionStyle.none
                
                let df = DateFormatter()
                df.timeStyle = DateFormatter.Style.short
                df.dateStyle = DateFormatter.Style.none
                
                if let date = event.date {
                    eventCell.secondaryLabel.text = df.string(from: date as Date)
                } else {
                    eventCell.secondaryLabel.text = "?"
                }
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
                
                self.eventRange.events.remove(at: self.eventRange.events.count - 1 - indexPath.row)
                
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
            if let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CircleViewController") as? CircleViewController {
                
                view.currentMode = .mood
                view.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                view.modalPresentationCapturesStatusBarAppearance = true
                view.delegate = self
                view.eventRange = self.eventRange
                
                self.present(view, animated: true, completion: {
                    
                })
            }
        }
    }
    
    func userCreated(event: Event) {
        eventRange.performFetch()
        self.tableView.reloadData()
    }
}
