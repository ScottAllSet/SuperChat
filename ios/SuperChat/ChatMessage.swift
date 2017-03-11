//
//  ChatItem.swift
//  SuperChat
//
//  Created by Scott R. Jones on 3/10/17.
//  Copyright © 2017 Scott R. Jones. All rights reserved.
//

import Foundation

//the ChatMessage model object
class ChatMessage {
    let text: String
    let timestamp: Date
    
    init(_ text: String) {
        self.text = text
        self.timestamp = Date()
    }
    
    init(text: String, timestamp: Date) {
        self.text = text
        self.timestamp = timestamp
    }
}
