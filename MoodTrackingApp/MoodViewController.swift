//
//  MoodViewController.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 31/05/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit
import MessageUI

class MoodViewController:UIViewController, CircleViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(prefersHiddenNavBar(), animated: true)
    }
    
    func prefersHiddenNavBar() -> Bool {
        return false
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
                view.delegate = self
                
                self.present(view, animated: true, completion: {
                    
                })
            }
        }
    }
    
    func userCreated(event: Event) {
        // Subclasses should override this
    }
    
    func email(emailAddress: String, subject: String, message: String?) {
        if MFMailComposeViewController.canSendMail() {
            
            let picker = MFMailComposeViewController()
            picker.mailComposeDelegate = self
            
            let toReceipts = [emailAddress]
            picker.setToRecipients(toReceipts)
            
            picker.setSubject(subject)
            
            if let message = message {
                picker.setMessageBody(message, isHTML: false)
            }
            
            if let info = Bundle.main.infoDictionary {
                if let version = info["CFBundleShortVersionString"] as? String, let buildNumber = info["CFBundleVersion"] as? String {
                    picker.setSubject("\(subject) - v\(version) (\(buildNumber))")
                }
            }
            
//            if let data = SimpleLogger.shared.logAsData() {
//                picker.addAttachmentData(data, mimeType: "text/plain", fileName: "log.txt")
//            }
            
            present(picker, animated: true, completion: {
                () -> Void in
                
            })
        } else {
            self.notifyUser(title: "Email Not Configured", message: "Looks like you can't send an email natively. Please email verytinymachines@gmail.com")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // User has finished with this email dialogue, just dismiss it.
        controller.dismiss(animated: true) {
            
        }
    }
    
    func notifyUser(title: String?, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                
            }))
            
            alert.popoverPresentationController?.sourceView = self.view
            
            self.present(alert, animated: true, completion: {
                
            })
        }
    }
}
