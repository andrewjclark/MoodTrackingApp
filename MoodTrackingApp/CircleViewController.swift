//
//  CircleViewController.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 23/05/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class CircleViewController:UIViewController, CircleViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var circleView: CircleView!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentItems = [CircleItem]()
    var currentIndexPath:IndexPath?
    
    var currentMode = ItemType.mood
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for cellName in ["EmojiCollectionViewCell"] {
            let nib = UINib(nibName: cellName, bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: cellName)
        }
        
        if currentMode == .mood {
            let newItem = CircleItem()
            newItem.type = .mood
            newItem.itemType = 403
            
            currentItems.append(newItem)
            currentIndexPath = IndexPath(row: 0, section: 0)
            
        } else {
            let newItem = CircleItem()
            newItem.type = .event
            newItem.itemType = 605
            
            currentItems.append(newItem)
            currentIndexPath = IndexPath(row: 0, section: 0)
        }
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        
        circleView.delegate = self
        updateCircleView()
        updateView()
        
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
            
            if let currentIndexPath = currentIndexPath {
                // Replace the item if they're both the same mood/event type. If they're different then make another one.
                
                /*
                let currentItem = currentItems[currentIndexPath.row]
                
                if currentItem.type == item.type {
                    // Replace it
                    currentItems.remove(at: currentIndexPath.row)
                    currentItems.insert(item, at: currentIndexPath.row)
                } else {
                    // Make a new one
                    self.currentItems.append(item)
                    self.currentIndexPath = IndexPath(row: currentItems.count - 1, section: 0)
                }
                 */
                
                // Replace it
                currentItems.remove(at: currentIndexPath.row)
                currentItems.insert(item, at: currentIndexPath.row)
                
            } else {
                self.currentItems.append(item)
                self.currentIndexPath = IndexPath(row: currentItems.count - 1, section: 0)
            }
        }
        
        self.updateView()
        
        if let currentIndexPath = currentIndexPath {
            self.collectionView.scrollToItem(at: currentIndexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        }
        
        
    }
    
    func currentItem() -> CircleItem? {
        
        if let currentIndexPath = currentIndexPath {
            return currentItems[currentIndexPath.row]
        }
        
        return nil
    }
    
    func updateView() {
        
        if currentMode == .mood {
            segmentedControl.selectedSegmentIndex = 0
        } else {
            segmentedControl.selectedSegmentIndex = 1
        }
        
        self.collectionView.reloadData()
    }
    
    func updateCircleView() {
        // Mood Set
        if (self.currentMode == ItemType.mood) {
            let dataSet = [[403],[401,603,503],[100,200,600,800,500,700]]
            
            var newDataSet = [[CircleItem]]()
            
            for section in dataSet {
                
                var items = [CircleItem]()
                
                for item in section {
                    
                    let bundle = DataFormatter.moodEmoji(typeInt: item)
                    
                    let newCircleItem = CircleItem()
                    newCircleItem.emoji = bundle.emoji
                    newCircleItem.type = ItemType.mood
                    newCircleItem.itemType = item
                    
                    items.append(newCircleItem)
                }
                
                newDataSet.append(items)
            }
            
            
            if let currentItem = currentItem() {
                circleView.selectedItem = indexPath(dataSet: newDataSet, selectedItem: currentItem)
            } else {
                circleView.selectedItem = nil
            }
            
            circleView.dataSet = newDataSet
        } else {
            // Events
            //              waste  caf,foo,med,wal,wan,fam,date    alc,jun,wor,exe,exp,soc,sex     drug,swe,art,spi,tra,par,knk
            let dataSet = [[605], [301,303,401,202,108,104,1000], [300,304,101,200,111,110,1002], [1001,305,102,109,106,112,1003]]
            
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
            
            if let currentItem = currentItem() {
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
        
        
        // Deselect current item if needed.
        
        if let currentIndexPath = currentIndexPath {
            let item = currentItems[currentIndexPath.row]
            
            if self.currentMode != item.type && item.itemType != 0 {
                // We are now in a mode that clashes with the selected item! Deselect it.
                
                self.currentIndexPath = nil
                self.collectionView.reloadData()
            }
        }
        
        
        updateCircleView()
        
    }
    
    @IBAction func userPressedSave(_ sender: UIButton) {
        
        for item in currentItems {
            if item.type == .event {
                // Event
                if let eventType = EventType(rawValue: item.itemType) {
                    
                    if let _ = DataStore.shared.newEvent(type: eventType, customEmoji: nil, note: nil) {
                        print("Event made")
                    }
                }
            } else {
                // Mood
                
                if let moodType = MoodType(rawValue: item.itemType) {
                    if let _ = DataStore.shared.newMood(type: moodType, customEmoji: nil, note: nil) {
                        print("Mood made")
                    }
                }
            }

        }
        
        DataStore.shared.saveContext()
        
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If we currently have an unknown item then we don't actually have to show the "+"
        
        for item in currentItems {
            if item.itemType == 0 {
                return currentItems.count
            }
        }
        
        return currentItems.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionViewCell", for: indexPath) as! EmojiCollectionViewCell
        
        cell.layer.borderColor = UIColor.clear.cgColor
        
        if indexPath.row == currentItems.count {
            // Plus button
            
            cell.mainLabel.text = "+"
            cell.mainLabel.textColor = UIColor(red: 0.33, green: 1.0, blue: 0.33, alpha: 1.0)
            cell.mainLabel.font = UIFont.systemFont(ofSize: 34)
            
            cell.titleLabel.text = nil
            
            cell.bottomConstraint.constant = 12
            
            cell.backgroundColor = UIColor.clear
            
        } else {
            cell.bottomConstraint.constant = 24
            
            let item = currentItems[indexPath.row]
            
            if item.itemType == 0 {
                // It's empty
                cell.mainLabel.text = nil
                cell.titleLabel.text = nil
                
            } else {
                if item.type == .event {
                    
                    let bundle = DataFormatter.eventEmoji(typeInt: item.itemType)
                    
                    cell.mainLabel.text = bundle.emoji
                    cell.mainLabel.font = UIFont.systemFont(ofSize: 40)
                    
                    cell.titleLabel.text = bundle.name.capitalized
                    cell.titleLabel.font = UIFont.systemFont(ofSize: 16)
                    cell.titleLabel.textColor = UIColor.white
                    
                } else if item.type == .mood {
                    
                    let bundle = DataFormatter.moodEmoji(typeInt: item.itemType)
                    
                    cell.mainLabel.text = bundle.emoji
                    cell.mainLabel.font = UIFont.systemFont(ofSize: 40)
                    
                    cell.titleLabel.text = bundle.name.capitalized
                    cell.titleLabel.font = UIFont.systemFont(ofSize: 16)
                    cell.titleLabel.textColor = UIColor.white
                }
            }
            
            
            
            cell.backgroundColor = UIColor.clear
            cell.layer.cornerRadius = 5.0
            cell.layer.borderWidth = 2.0
            
            if let currentIndexPath = currentIndexPath {
                if currentIndexPath == indexPath {
                    cell.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
                    cell.layer.borderColor = UIColor.white.cgColor
                }
            }
        }
        
        return cell
    }
    
    func removeUnknownsIfNeeded() {
        var newItems = [CircleItem]()
        
        for item in currentItems {
            if item.itemType != 0 {
                newItems.append(item)
            }
        }
        
        self.currentItems = newItems
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == currentItems.count {
            // Start a new one
            
            self.removeUnknownsIfNeeded()
            
            if currentMode == .mood {
                let newItem = CircleItem()
                newItem.type = .mood
                newItem.itemType = 0 // unknown
                
                currentItems.append(newItem)
                
                currentIndexPath = IndexPath(row: currentItems.count - 1, section: 0)
            } else if currentMode == .event {
                let newItem = CircleItem()
                newItem.type = .event
                newItem.itemType = 0 // unknown
                
                currentItems.append(newItem)
                
                currentIndexPath = IndexPath(row: currentItems.count - 1, section: 0)
            }
            
            // Scroll to it
            
            self.collectionView.reloadData()
            
            if let currentIndexPath = currentIndexPath {
                self.collectionView.scrollToItem(at: currentIndexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
            }
            
            return
            
        } else {
            if let currentIndexPath = currentIndexPath {
                if currentIndexPath == indexPath {
                    // Already selected, delete this one
                    
                    let alertView = UIAlertController(title: "Delete?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    alertView.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { (action) in
                        self.currentItems.remove(at: indexPath.row)
                        self.currentIndexPath = nil
                        self.updateCircleView()
                        // Remove this item
                        
                        self.collectionView.deleteItems(at: [indexPath])
                        
                        // self.collectionView.reloadData()
                    }))
                    
                    alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                        
                    }))
                    
                    self.present(alertView, animated: true, completion: { 
                        
                    })
                    
                    return
                    
                }
            }
            
            // We have now selected this one
            self.removeUnknownsIfNeeded()
            self.currentIndexPath = indexPath
            // Change the selected item
            
            let item = currentItems[indexPath.row]
            
            if item.itemType != 0 {
                currentMode = item.type
            }
        }
        
        self.updateCircleView()
        self.collectionView.reloadData()
        
        if let currentIndexPath = currentIndexPath {
            self.collectionView.scrollToItem(at: currentIndexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
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
