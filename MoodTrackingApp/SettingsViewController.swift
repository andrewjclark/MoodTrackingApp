//
//  SettingsViewController.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 19/06/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class SettingsViewController:MoodViewController, UITableViewDelegate, UITableViewDataSource {
    
    let kItemAbout = 0
    let kItemNotifcations = 1
    let kItemContact = 2
    
    let kItemsCount = 3
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SettingsViewController.dismissSelf))
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        view.backgroundColor = UIColor.moodBlue
        tableView.backgroundColor = UIColor.clear
        
        updateTitle()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kItemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = ""
        cell.backgroundColor = UIColor.clear
        
        if indexPath.row == kItemAbout {
            cell.textLabel?.text = "Mood Tracker App is the app that helps you track your moods, your life, and teaches you what makes you happy.\n\nIt's simple... periodically enter your moods when you're feeling high, low, or somewhere in between. Enter in some events so you have some context and soon enough you'll be able to see how you're doing today, this week, this month, or longer!\n\nEmotions are hard. Let's make them easier.\n"
        } else if indexPath.row == kItemNotifcations {
            
            if SettingsHelper.isSettingEnabled(key: SettingsKey.notifications) {
                // Notifications enabled.
                cell.textLabel?.text = "Notifications are ENABLED\nYou will be reminded to track your moods and life events every so often, but not between 10pm and 7am.\n(Tap here to disable)"
            } else {
                cell.textLabel?.text = "Notifications are DISABLED\n{Tap here to enable)"
            }
        } else if indexPath.row == kItemContact {
            cell.textLabel?.text = "Got a problem? Contact Us"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == kItemNotifcations {
            SettingsHelper.flipSetting(key: SettingsKey.notifications)
            self.tableView.reloadData()
        } else if indexPath.row == kItemContact {
            self.email(emailAddress: "verytinymachines@gmail.com", subject: "Issue with Mood Tracker App", message: "")
        }
    }
    
    func dismissSelf() {
        dismiss(animated: true) {
            
        }
    }
    
    func updateTitle() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.barStyle = UIBarStyle.blackOpaque
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.moodBlue
        navigationController?.navigationBar.isTranslucent = false
    }
    
}
