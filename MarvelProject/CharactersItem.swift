//
//  Character.swift
//  MarvelProject
//
//  Created by tomer on 16/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit

class CharactersItem : Item {
    
    required init(_ dict : [String:Any], isMarvel : Bool) {        
        super.init(dict, isMarvel: isMarvel)
        self.name = dict["name"] as? String
    }
}
