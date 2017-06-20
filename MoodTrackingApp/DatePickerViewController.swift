//
//  DatePickerViewController.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 9/06/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate:class {
    func eventUpdated(event: Event)
}

class DatePickerViewController:UIViewController {
    
    weak var delegate:DatePickerViewControllerDelegate?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var emojiLabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    
    var event:Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainView.backgroundColor = UIColor.lightMoodBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let event = event {
            if let date = event.date {
                datePicker.date = date as Date
                datePicker.becomeFirstResponder()
            }
            
            let emoji = DataFormatter.emoji(typeInt: Int(event.type))
            
            mainLabel.font = UIFont.systemFont(ofSize: 20)
            mainLabel.text = emoji.name.capitalized
            
            emojiLabel.font = UIFont.systemFont(ofSize: 46)
            emojiLabel.text = emoji.emoji
        }
        
    }
    
    @IBAction func pressCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true) { 
            
        }
    }
    
    @IBAction func pressDoneButton(_ sender: UIButton) {
        
        if let event = event {
            event.date = datePicker.date as NSDate
            
            DataStore.shared.saveContext()
            
            delegate?.eventUpdated(event: event)
        }
        
        self.dismiss(animated: true) {
            
        }
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
