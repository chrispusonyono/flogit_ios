//
//  Thread.swift
//  FlogIt
//
//  Created by chrispus nyaberi on 20/02/2019.
//  Copyright © 2019 wizag. All rights reserved.
//

import Foundation
class Thread {
    
    //MARK: Properties
    
    var userId: String
    var name: String
    var icon: String
    var lastMessage: String
    var time: String
    var messages = [Message]()
    
    
    
    init(userId: String, name: String, icon: String, lastMessage: String, time: String, messages: [Message]) {
        self.userId=userId
        self.name=name
        self.icon=icon
        self.lastMessage=lastMessage
        self.time=time
        self.messages=messages
    }
    
}
