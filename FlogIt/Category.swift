//
//  Product.swift
//  FlogIt
//
//  Created by chrispus on 10/27/18.
//  Copyright © 2018 wizag. All rights reserved.
//

import Foundation
class Category {
    
    //MARK: Properties
    
    var id: String
    var icon: String
    var description: String
    
    
    init(id: String, icon: String, description: String) {
        self.id=id
        self.icon=icon
        self.description=description
    }
    
}
