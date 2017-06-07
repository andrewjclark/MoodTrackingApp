//
//  MoodViewController.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 31/05/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class MoodViewController:UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(prefersHiddenNavBar(), animated: true)
    }
    
    func prefersHiddenNavBar() -> Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func presentInputView(type: ItemType) {
        
        DispatchQueue.main.async {
            if let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CircleViewController") as? CircleViewController {
                
                view.currentMode = type
                view.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                view.modalPresentationCapturesStatusBarAppearance = true
                
                self.present(view, animated: true, completion: {
                    
                })
            }
        }
    }
}
