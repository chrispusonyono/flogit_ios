//
//  Product.swift
//  FlogIt
//
//  Created by chrispus on 10/27/18.
//  Copyright © 2018 wizag. All rights reserved.
//

import Foundation
class Product {
    
    //MARK: Properties
    
    var id: String
    var icon: String
    var name: String
    var description: String
    var location: String
    var price: String
    var type: String
    
    
    init(id: String, icon: String, name: String, description: String,location: String, price: String, type: String) {
        self.id=id
        self.icon=icon
        self.name=name
        self.description=description
        self.location=location
        self.price=price
        self.type=type
    }
    
}
