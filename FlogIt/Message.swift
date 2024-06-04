//
//  Message.swift
//  FlogIt
//
//  Created by chrispus nyaberi on 29/01/2019.
//  Copyright © 2019 wizag. All rights reserved.
//

import Foundation
class Message {
    
    //MARK: Properties
    
    var id: String
    var message: String
    var myMessage: Bool
    var time: String
    var status: Int
    
    
    
    init(id: String, message: String, myMessage: Bool, time: String, status: Int) {
        self.id=id
        self.message=message
        self.myMessage=myMessage
        self.time=time
        self.status=status
    }
    
}
