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
        
        DataAnalyser.sharedAnalyser.anaylseData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SettingsViewController.dismissSelf))
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.backgroundColor = UIColor.moodBlue
        tableView.backgroundColor = UIColor.clear
        
        for cellName in ["DataViewSummaryCell", "DataViewCorrelationCell"] {
            let nib = UINib(nibName: cellName, bundle: nil)
            self.tableView.register(nib, forCellReuseIdentifier: cellName)
        }
        
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
            if DataAnalyser.sharedAnalyser.moodBreakDown.count == 3 {
                return 1
            }
        } else if section == kSectionCorrelations {
            
            return DataAnalyser.sharedAnalyser.numberOfSignificantCorrelations
            /*
            let count = DataAnalyser.sharedAnalyser.topEventCorrelations.count
            return count
            return count > 8 ? 8 : count
             */
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        if section == kSectionHighest {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.backgroundColor = UIColor.clear
            
            if let event = DataAnalyser.sharedAnalyser.highestAllTime {
                let emoji = DataFormatter.emoji(typeInt: Int(event.type))
                
                if let date = event.date {
                    cell.textLabel?.text = "Highest Mood ever is: \(emoji.emoji) on \(date)"
                }
            } else {
                cell.textLabel?.text = "No highest found"
            }
            
            return cell
        } else if section == kSectionAverage {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.backgroundColor = UIColor.clear
            
            if let event = DataAnalyser.sharedAnalyser.averageMood {
                
                cell.textLabel?.text = "Average mood is: \(event.emoji)"
                
            } else {
                cell.textLabel?.text = "No average found"
            }
            
            return cell
        } else if section == kSectionLowest {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.backgroundColor = UIColor.clear
            if let event = DataAnalyser.sharedAnalyser.lowestAllTime {
                let emoji = DataFormatter.emoji(typeInt: Int(event.type))
                
                if let date = event.date {
                    cell.textLabel?.text = "Lowest mood ever is: \(emoji.emoji) on \(date)"
                }
            } else {
                cell.textLabel?.text = "No lower found"
            }
            
            return cell
        } else if section == kSectionEvents {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.backgroundColor = UIColor.clear
            let event = DataAnalyser.sharedAnalyser.eventCounts[indexPath.row]
            
            let emoji = DataFormatter.emoji(typeInt: event.type)
            
            var newText = ""
            
            newText = "#\(indexPath.row + 1): \(emoji.emoji) \(emoji.name.capitalized) x \(event.count) times"
            
            if DataAnalyser.sharedAnalyser.totalEventCount > 0 {
                let percentage:Float = Float(event.count) / Float(DataAnalyser.sharedAnalyser.totalEventCount)
                
                newText += " (\(Int(roundf(percentage * 100)))%)"
            }
            
            cell.textLabel?.text = newText
            
            return cell
        } else if section == kSectionMoods {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.backgroundColor = UIColor.clear
            let event = DataAnalyser.sharedAnalyser.moodsCounts[indexPath.row]
            
            let emoji = DataFormatter.emoji(typeInt: event.type)
            
            var newText = ""
            
            newText = "#\(indexPath.row + 1): \(emoji.emoji) \(emoji.name.capitalized) x \(event.count) times"
            
            if DataAnalyser.sharedAnalyser.totalEventCount > 0 {
                let percentage:Float = Float(event.count) / Float(DataAnalyser.sharedAnalyser.totalEventCount)
                
                newText += " (\(Int(roundf(percentage * 100)))%)"
            }
            
            cell.textLabel?.text = newText
            
            return cell
        } else if section == kSectionMoodsSummary {
            
            let summaryCell = tableView.dequeueReusableCell(withIdentifier: "DataViewSummaryCell") as! DataViewSummaryCell
            
            summaryCell.backgroundColor = UIColor.clear
            
            
            var counts = [Int]()
            
            counts.append(DataAnalyser.sharedAnalyser.moodBreakDown[1]!)
            counts.append(DataAnalyser.sharedAnalyser.moodBreakDown[0]!)
            counts.append(DataAnalyser.sharedAnalyser.moodBreakDown[-1]!)
            
            // Percentages
            
            
            let totalMoods = DataAnalyser.sharedAnalyser.totalMoodsBreakdown
            
            var percentages = [Float]()
            for count in counts {
                
                let newPerc = Float(count) / Float(totalMoods)
                
                percentages.append(newPerc)
            }
            
            summaryCell.layout(emoji: [DataFormatter.emoji(typeInt: EventType.happy.rawValue).emoji,DataFormatter.emoji(typeInt: EventType.neutral.rawValue).emoji,DataFormatter.emoji(typeInt: EventType.sad.rawValue).emoji], title: ["Positive","Neutral","Negative"], percentage: percentages)
            
            return summaryCell
            
        } else if section == kSectionCorrelations {
            
            
            let correlationCell = tableView.dequeueReusableCell(withIdentifier: "DataViewCorrelationCell") as! DataViewCorrelationCell
            
            
            let correlation = DataAnalyser.sharedAnalyser.topEventCorrelations[indexPath.row]
            
            let eventEmoji = DataFormatter.emoji(typeInt: correlation.eventType)
            
            let moodEvent = GraphEvent(averageLinearMood: correlation.averageLinearMood, date: nil)
            
            let overallConfidence = Int(round(correlation.correlationConfidence() * 100))
            
            var confidencceString = ""
            
            if overallConfidence > 50 {
                confidencceString = "very confident (\(overallConfidence)%)"
            } else if overallConfidence > 20 {
                confidencceString = "somewhat confident (\(overallConfidence)%)"
            } else {
                confidencceString = "not confident (\(overallConfidence)%)"
            }
            
            correlationCell.backgroundColor = UIColor.clear
            
            correlationCell.layout(leftEmoji: eventEmoji.emoji, joinTerm: "\(eventEmoji.name.capitalized) -> \(moodEvent.name.capitalized)", rightEmoji: moodEvent.emoji, detail: confidencceString.capitalized)
            
            return correlationCell
            
            
            
            
            /*
            let detailCell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            
            detailCell.backgroundColor = UIColor.clear
            
            
            
            detailCell.textLabel?.text = "\(eventEmoji.emoji) \(eventEmoji.name.capitalized) -> \(event.emoji) \(event.name.capitalized)"
            detailCell.detailTextLabel?.text = "        \(confidencceString.capitalized)"
            
            return detailCell
             */
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == kSectionMoodsSummary {
            return 150
        }
        return 70
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white
        
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textAlignment = NSTextAlignment.center
            view.textLabel?.textColor = UIColor.moodBlue
        }
    }
    
}
