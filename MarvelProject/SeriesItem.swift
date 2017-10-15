//
//  Series.swift
//  MarvelProject
//
//  Created by tomer on 27/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit

class SeriesItem : Item {

    required init(_ dict : [String:Any], isMarvel : Bool) {
        super.init(dict, isMarvel: isMarvel)
        self.name = dict["title"] as? String
        if let start = dict["startYear"] as? Int{
            self.startYear = "Start: " + start.description
        }
        
        if let end = dict["endYear"] as? Int{
            self.endYear = "End: " + end.description
        }
    }
}
