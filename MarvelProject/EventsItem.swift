//
//  Events.swift
//  MarvelProject
//
//  Created by tomer on 27/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit

class EventsItem : Item {

    required init(_ dict : [String:Any], isMarvel : Bool) {
        super.init(dict, isMarvel: isMarvel)
        self.name = dict["title"] as? String
        self.start = Date(string: dict["start"] as? String)
        self.end = Date(string: dict["end"] as? String)
    }
}
