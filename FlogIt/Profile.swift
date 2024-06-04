//
//  Profile.swift
//  FlogIt
//
//  Created by apple on 10/13/18.
//  Copyright © 2018 wizag. All rights reserved.
//

import Foundation
class Profile {
    
    //MARK: Properties
    
    var loggedIn: Bool
    var token: String
    var fullName: String
    var email: String
    var profilePicture: String
    
    
    init(loggedIn: Bool, token: String, fullName: String, email: String, profilePicture: String) {
        self.loggedIn=loggedIn
        self.token=token
        self.fullName=fullName
        self.email=email
        self.profilePicture=profilePicture
}
}
