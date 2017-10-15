//
//  Utils.swift
//  MarvelProject
//
//  Created by tomer on 06/09/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import Foundation

extension Date{
    init?(string : String?) {
        guard let string = string else{
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let d = formatter.date(from: string) else{
            return nil
        }
        
        self = d
    }
    
    var dateString : String{
        get{
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: self)
        }
    }
}
