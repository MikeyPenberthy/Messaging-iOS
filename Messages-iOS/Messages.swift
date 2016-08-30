//
//  Messages.swift
//  Messages-iOS
//
//  Created by Michael Penberthy on 8/29/16.
//  Copyright © 2016 Michael Penberthy. All rights reserved.
//

import Foundation

class Messages {
    var text: String?
    var timeStamp: NSNumber?
    var fromId: String?
    
    init(text: String, timeStamp: NSNumber, fromId: String){
        self.text = text;
        self.timeStamp = timeStamp
        self.fromId = fromId
    }
}