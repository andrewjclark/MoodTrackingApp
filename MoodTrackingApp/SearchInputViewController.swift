//
//  SearchInputViewController.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 12/04/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class SearchInputViewController:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedItems = [EmojiBundle]()
    
    var masterResults = [EmojiBundle]()
    var masterAliasResults = [String:[EmojiBundle]]()
    var results = [EmojiBundle]()
    
    let kSectionSelected = 0
    let kSectionResults = 1
    
    let kSectionCount = 2
    
    override func viewDidLoad() {
        for cellName in ["EmojiCollectionViewCell"] {
            let nib = UINib(nibName: cellName, bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: cellName)
        }
        
        for headerName in ["SearchInputHeader"] {
            let nib = UINib(nibName: headerName, bundle: nil)
            collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerName)
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Fetch results
        // masterResults = DataFormatter.allBundles()
        
        // Setup the masterAliasResults
        for item in masterResults {
            if var currentAliases = masterAliasResults[item.name] {
                currentAliases.append(item)
                masterAliasResults[item.name] = currentAliases
            } else {
                masterAliasResults[item.name] = [item]
            }
            
            for alias in item.aliases {
                if var currentAliases = masterAliasResults[alias] {
                    currentAliases.append(item)
                    masterAliasResults[alias] = currentAliases
                } else {
                    masterAliasResults[alias] = [item]
                }
            }
        }
        
        print("masterAliasResults: \(masterAliasResults)")
        
        print("masterAliasResults[drunk]: \(masterAliasResults["drunk"])")
        
        performSearch()
        
        textField.delegate = self
        textField.becomeFirstResponder()
        
        self.view.backgroundColor = UIColor.clear
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.backgroundView?.backgroundColor = UIColor.clear
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if queuedItemsCount() > 0 {
            saveItems()
        }
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return kSectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == kSectionSelected {
            return selectedItems.count
        } else if section == kSectionResults {
            return results.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionViewCell", for: indexPath) as! EmojiCollectionViewCell
        cell.backgroundColor = UIColor.red
        
        var item:EmojiBundle?
        
        if indexPath.section == kSectionSelected {
            item = selectedItems[indexPath.row]
        } else if indexPath.section == kSectionResults {
            item = results[indexPath.row]
        }
        
        if let item = item {
            cell.mainLabel.text = item.emoji
            cell.mainLabel.font = UIFont.systemFont(ofSize: 40)
            
            cell.titleLabel.text = item.name.capitalized
            cell.titleLabel.font = UIFont.systemFont(ofSize: 16)
            cell.titleLabel.textColor = UIColor.white
            
            cell.backgroundColor = UIColor.clear
        }
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == kSectionSelected {
            selectedItems.remove(at: indexPath.row)
        } else if indexPath.section == kSectionResults {
            selectedItems.append(results[indexPath.row])
        }
        
        self.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == kSectionSelected {
            if selectedItems.count == 0 {
                return CGSize(width: 0, height: 0)
            }
        } else if section == kSectionResults {
            if results.count == 0 || selectedItems.count == 0 {
                return CGSize(width: 0, height: 0)
            }
        }
        
        let borderWidth:CGFloat = 10
        return CGSize(width: collectionView.frame.width - (borderWidth * 2), height: 44)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchInputHeader", for: indexPath) as! SearchInputHeader
        
        header.backgroundColor = UIColor.clear
        header.mainLabel.textColor =  UIColor.white
        
        if indexPath.section == kSectionSelected {
            header.mainLabel.text = "Selected"
        } else if indexPath.section == kSectionResults {
            header.mainLabel.text = "All"
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let borderWidth:CGFloat = 10
        let columns:CGFloat = 4
        
        let width = ((collectionView.frame.width - (borderWidth * 2) - (borderWidth * (columns - 1))) / columns) - 0.5
        return CGSize(width: width, height: width)
    }
    
    @IBAction func userPressedDoneButton(_ sender: UIButton) {
        saveItems()
    }
    
    func saveItems() {
        // Need to save the selected items to this moment in time.
        
        var searchTerm = ""
        if let text = textField.text {
            searchTerm = text.lowercased()
        }
        
        if selectedItems.count > 0 {
            // User has manually selected items. Add them
            saveAndDismiss(items: selectedItems)
        } else if searchTerm != "" && results.count > 0 {
            
            if results.count == 1 {
                saveAndDismiss(items: results)
            } else {
                // Only save multiple results if there are multiple words being searched for
                if searchTerm.components(separatedBy: " ").count > 1 && results.count > 0 {
                    saveAndDismiss(items: results)
                }
            }
        }
    }
    
    func queuedItemsCount() -> Int {
        var searchTerm = ""
        if let text = textField.text {
            searchTerm = text.lowercased()
        }
        
        if selectedItems.count > 0 {
            // User has manually selected items. Add them
            return selectedItems.count
        } else if searchTerm != "" && results.count > 0 {
            
            if results.count == 1 {
                return 1
            } else {
                // Only save multiple results if there are multiple words being searched for
                if searchTerm.components(separatedBy: " ").count > 1 && results.count > 0 {
                    return results.count
                }
            }
        }
        
        return 0
    }
    
    @IBAction func userPressedCancel(_ sender: Any) {
        self.dismiss(animated: true) { 
            
        }
    }
    
    func saveAndDismiss(items: [EmojiBundle]) {
        /*
        for selected in items {
            print("selected: \(selected)")
            if selected.type == ItemType.event {
                print("selected.type: \(selected.type)")
                
                if let eventType = EventType(rawValue: selected.typeInt) {
                    print("")
                    if let _ = DataStore.shared.newEvent(type: eventType, customEmoji: nil, note: nil) {
                        print("Event made")
                    }
                }
            } else if selected.type == ItemType.mood {
                print("selected.type: \(selected.type)")
                
                if let moodType = EventType(rawValue: selected.typeInt) {
                    if let _ = DataStore.shared.newMood(type: moodType, customEmoji: nil, note: nil) {
                        print("Mood made")
                    }
                }
            }
        }
        */
        
        DataStore.shared.saveContext()
        
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        performSearch()
    }
    
    func performSearch() {
        var searchTerm = ""
        if let text = textField.text {
            searchTerm = text.lowercased()
        }
        
        DispatchQueue.global(qos: .background).async {
            
            let stringWords = searchTerm.components(separatedBy: " ")
            
            var newResults = [EmojiBundle]()
            
            if stringWords.count > 1 {
                newResults = self.resultsForSentence(words: stringWords)
            } else {
                newResults = self.resultsForString(string: searchTerm, requireMatch: false)
            }
            
            DispatchQueue.main.async {
                
                var newSearchTerm = ""
                if let text = self.textField.text {
                    newSearchTerm = text.lowercased()
                }
                
                if newSearchTerm == searchTerm {
                    // These results are still relevant
                    self.results = Array(newResults)
                    self.reloadData()
                }
            }
        }
    }
    
    func reloadData() {
        // userCanPressDone()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            
            let itemsCount = self.queuedItemsCount()
            
            if itemsCount > 0 {
                self.doneButton.isEnabled = true
                self.doneButton.alpha = 1.0
                
                UIView.performWithoutAnimation {
                    self.doneButton.setTitle("Save (\(itemsCount))", for: UIControlState.normal)
                }
            } else {
                self.doneButton.isEnabled = false
                self.doneButton.alpha = 0.5
                UIView.performWithoutAnimation {
                    self.doneButton.setTitle("Save", for: UIControlState.normal)
                }
            }
        }
    }
    
    
    func resultsForString(string: String, requireMatch: Bool) -> [EmojiBundle] {
        
        var newResultsArray = [EmojiBundle]()
        
        if string == "" {
            newResultsArray = self.masterResults
        } else {
            
            //print("Searching for: \(searchTerm)")
            
            var newResults = Set<EmojiBundle>()
            
            for (key, bundles) in self.masterAliasResults {
                //print("Key: \(key) Bundles: \(bundles)")
                
                if requireMatch {
                    if key == string {
                        //print("\(key) contains \(searchTerm)")
                        //print("    newResults: \(newResults)")
                        for bundle in bundles {
                            newResults.insert(bundle)
                        }
                    }
                } else {
                    if key.hasPrefix(string) {
                        //print("\(key) contains \(searchTerm)")
                        //print("    newResults: \(newResults)")
                        for bundle in bundles {
                            newResults.insert(bundle)
                        }
                    }
                }
                
            }
            newResultsArray = Array(newResults)
        }
        
        return newResultsArray
    }
    
    func resultsForSentence(words: [String]) -> [EmojiBundle] {
        
        var newResultsArray = [EmojiBundle]()
        
        for word in words {
            var foundWord = false
            
            print("word: \(word)")
            // See if this word matches one of the results primary names
            
            // If not then search the aliases
            
            if !foundWord {
                for item in masterResults {
                    if item.name == word {
                        print("item: \(item)")
                        newResultsArray.append(item)
                        foundWord = true
                        break
                    }
                }
            }
            
            
            if !foundWord {
                for (key, bundles) in self.masterAliasResults {
                    //print("Key: \(key) Bundles: \(bundles)")
                    
                    if key == word {
                        //print("\(key) contains \(searchTerm)")
                        //print("    newResults: \(newResults)")
                        print("key: \(key)")
                        if let firstItem = bundles.first {
                            print("firstItem: \(firstItem)")
                            newResultsArray.append(firstItem)
                            foundWord = true
                            break
                        }
                    }
                }
            }
            
        }
        
        
        return newResultsArray
        
        
        /*
        if string == "" {
            newResultsArray = self.masterResults
        } else {
            
            //print("Searching for: \(searchTerm)")
            
            var newResults = Set<EmojiBundle>()
            
            for (key, bundles) in self.masterAliasResults {
                //print("Key: \(key) Bundles: \(bundles)")
                
                if requireMatch {
                    if key == string {
                        //print("\(key) contains \(searchTerm)")
                        //print("    newResults: \(newResults)")
                        for bundle in bundles {
                            newResults.insert(bundle)
                        }
                    }
                } else {
                    if key.hasPrefix(string) {
                        //print("\(key) contains \(searchTerm)")
                        //print("    newResults: \(newResults)")
                        for bundle in bundles {
                            newResults.insert(bundle)
                        }
                    }
                }
                
            }
            newResultsArray = Array(newResults)
        }
        
        return newResultsArray
 */
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
}
