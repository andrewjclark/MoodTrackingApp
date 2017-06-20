//
//  DataAnalysisViewController.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 19/06/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class DataAnalysisViewController: MoodViewController, UITableViewDataSource, UITableViewDelegate {
    
    let kSectionHighest = -100
    let kSectionAverage = -100
    let kSectionLowest = -100
    
    let kSectionEvents = 3
    let kSectionMoods = 2
    let kSectionMoodsSummary = 0
    let kSectionCorrelations = 1
    
    let kSectionsCount = 4
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataAnalyser.sharedAnalyser.shallowAnalysis()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SettingsViewController.dismissSelf))
        
        tableView.dataSource = self
        tableView.delegate = self
        
        updateTitle()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return kSectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == kSectionHighest {
            return 1
        } else if section == kSectionAverage {
            return 1
        } else if section == kSectionLowest {
            return 1
        } else if section == kSectionEvents {
            let count = DataAnalyser.sharedAnalyser.eventCounts.count
            
            if count > 5 {
                return 5
            } else {
                return count
            }
        } else if section == kSectionMoods {
            let count = DataAnalyser.sharedAnalyser.moodsCounts.count
            
            return count > 5 ? 5 : count
        } else if section == kSectionMoodsSummary {
            return DataAnalyser.sharedAnalyser.moodBreakDown.count // Should always be 3
        } else if section == kSectionCorrelations {
            let count = DataAnalyser.sharedAnalyser.topEventCorrelations.count
            return count > 8 ? 8 : count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = UIColor.clear
        
        let section = indexPath.section
        
        if section == kSectionHighest {
            if let event = DataAnalyser.sharedAnalyser.highestAllTime {
                let emoji = DataFormatter.emoji(typeInt: Int(event.type))
                
                if let date = event.date {
                    cell.textLabel?.text = "Highest Mood ever is: \(emoji.emoji) on \(date)"
                }
            } else {
                cell.textLabel?.text = "No highest found"
            }
        } else if section == kSectionAverage {
            if let event = DataAnalyser.sharedAnalyser.averageMood {
                
                cell.textLabel?.text = "Average mood is: \(event.emoji)"
                
            } else {
                cell.textLabel?.text = "No average found"
            }
        } else if section == kSectionLowest {
            if let event = DataAnalyser.sharedAnalyser.lowestAllTime {
                let emoji = DataFormatter.emoji(typeInt: Int(event.type))
                
                if let date = event.date {
                    cell.textLabel?.text = "Lowest mood ever is: \(emoji.emoji) on \(date)"
                }
            } else {
                cell.textLabel?.text = "No lower found"
            }
        } else if section == kSectionEvents {
            let event = DataAnalyser.sharedAnalyser.eventCounts[indexPath.row]
            
            let emoji = DataFormatter.emoji(typeInt: event.type)
            
            var newText = ""
            
            newText = "#\(indexPath.row + 1): \(emoji.emoji) \(emoji.name.capitalized) x \(event.count) times"
            
            if DataAnalyser.sharedAnalyser.totalEventCount > 0 {
                let percentage:Float = Float(event.count) / Float(DataAnalyser.sharedAnalyser.totalEventCount)
                
                newText += " (\(Int(roundf(percentage * 100)))%)"
            }
            
            cell.textLabel?.text = newText
        } else if section == kSectionMoods {
            let event = DataAnalyser.sharedAnalyser.moodsCounts[indexPath.row]
            
            let emoji = DataFormatter.emoji(typeInt: event.type)
            
            var newText = ""
            
            newText = "#\(indexPath.row + 1): \(emoji.emoji) \(emoji.name.capitalized) x \(event.count) times"
            
            if DataAnalyser.sharedAnalyser.totalEventCount > 0 {
                let percentage:Float = Float(event.count) / Float(DataAnalyser.sharedAnalyser.totalEventCount)
                
                newText += " (\(Int(roundf(percentage * 100)))%)"
            }
            
            cell.textLabel?.text = newText
        } else if section == kSectionMoodsSummary {
            
            var categoryInt = 0
            
            if indexPath.row == 0 {
                // Happy
                categoryInt = 1
            } else if indexPath.row == 1 {
                // Neutral
                categoryInt = 0
            } else if indexPath.row == 2 {
                // Neutral
                categoryInt = -1
            }
            
            let moodCount = DataAnalyser.sharedAnalyser.moodBreakDown[categoryInt]!
            
            let ev = GraphEvent(averageLinearMood: Float(categoryInt) / 2, date: nil)
            
            let moodNames = ["Positive", "Neutral", "Negative"]
            let theMood = moodNames[indexPath.row]
            
            if DataAnalyser.sharedAnalyser.totalMoodsBreakdown > 0 {
                let percentage = Float(moodCount) / Float(DataAnalyser.sharedAnalyser.totalMoodsBreakdown) * 100
                
                cell.textLabel?.text = "You feel \(ev.emoji) \(theMood) \(Int(roundf(percentage)))% of the time"
            }
        } else if section == kSectionCorrelations {
            let correlation = DataAnalyser.sharedAnalyser.topEventCorrelations[indexPath.row]
            
            let eventEmoji = DataFormatter.emoji(typeInt: correlation.eventType)
            
            let event = GraphEvent(averageLinearMood: correlation.averageLinearMood, date: nil)
            
            cell.textLabel?.text = "\(eventEmoji.emoji) \(eventEmoji.name.capitalized) -> \(event.emoji) \(event.name.capitalized) C:\(correlation.correlationConfidence()) (\(correlation.linearMoodCount) times)"
        }
        
        /*
         } else if section == kSectionCorrelations {
         return DataAnalyser.sharedAnalyser.topEventCorrelations.count
         }
         */
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func dismissSelf() {
        dismiss(animated: true) {
            
        }
    }
    
    func updateTitle() {
        navigationItem.title = "Data Analysis (last 30 days)"
        navigationController?.navigationBar.barStyle = UIBarStyle.blackOpaque
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.moodBlue
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == kSectionEvents {
            return "Your Top Events"
        } else if section == kSectionMoods {
            return "Your Top Moods"
        } else if section == kSectionMoodsSummary {
            return "Your Mood Summary"
        } else if section == kSectionCorrelations {
            return "Top Correlations"
        }
        
        return nil
    }
    
}
