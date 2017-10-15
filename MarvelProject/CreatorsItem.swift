//
//  Creators.swift
//  MarvelProject
//
//  Created by tomer on 27/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit

class CreatorsItem : Item {

    required init(_ dict : [String:Any], isMarvel : Bool) {
        super.init(dict, isMarvel: isMarvel)
        self.name = dict["fullName"] as? String
    }
}
