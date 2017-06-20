//
//  StyleHelper.swift
//  MoodTrackingApp
//
//  Created by Andrew Clark on 31/05/2017.
//  Copyright © 2017 Andrew J Clark. All rights reserved.
//

import UIKit

class StyleHelper {
    static let sharedHelper = StyleHelper()
    fileprivate init() {}
}

extension UIColor {
    
    class var moodBlue:UIColor {
        return UIColor(red: 41/255, green: 172/255, blue: 236/255, alpha: 1.0)
    }
    
    class var lightMoodBlue:UIColor {
        return UIColor(red: 81/255, green: 198/255, blue: 255/255, alpha: 1.0)
    }

}
