//
//  Item.swift
//  MarvelProject
//
//  Created by tomer on 24/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class Item : NSObject {
    let id : Int64
    var name : String?
    let thumbnailURL : URL?
    var desc : String = ""
    let isMarvel : Bool
    
    var format : String?
    var pageCount : String?
    var images : [SKPhoto] = []
    var start : Date?
    var end : Date?
    var startYear : String?
    var endYear : String?
    var rating : String?
    var nextName : String?
    var nextUrl : String?
    var previousName : String?
    var previousUrl : String?
    
    required init(_ dict : [String:Any], isMarvel : Bool) {
        
        self.id = dict["id"] as? Int64 ?? 0
        self.isMarvel = isMarvel
        self.name = nil
        self.format = nil
        self.pageCount = nil
        self.start = nil
        self.end = nil
        self.startYear = nil
        self.endYear = nil
        self.rating = nil
        self.nextName = nil
        self.nextUrl = nil
        self.previousName = nil
        self.previousUrl = nil
        
        if let format = dict["format"] as? String{
            self.format = "Format: " + format
        }else{
            self.format = "Format: N/A"
        }
        
        if let rating = dict["rating"] as? String,
            !rating.isEmpty{
            self.rating = "Rating: " + rating
        }else{
            self.rating = "Rating: N/A"
        }
        
        if let pages = dict["pageCount"] as? Int, pages != 0{
            self.pageCount = "Pages: " + pages.description
        }else{
            self.pageCount = "Pages: N/A"
        }
        
        if let previous = dict["previous"] as? MarvelManager.JSON,
            let preURI = previous["resourceURI"] as? String,
            let preName = previous["name"] as? String{
            
            self.previousUrl = preURI
            self.previousName = " " + preName
        }else{
            self.previousName = " N/A"
            self.previousUrl = nil
        }
        
        if let next = dict["next"] as? MarvelManager.JSON,
            let nextURI = next["resourceURI"] as? String,
            let nextName = next["name"] as? String{
            
            self.nextUrl = nextURI
            self.nextName = " " + nextName
        }else{
            self.nextName = " N/A"
            self.nextUrl = nil
        }
          
        if let description = dict["description"] as? String,
            !description.isEmpty{
            desc = description
        }else{
            desc = "N/A"
        }
        
        if let thumbnail = dict["thumbnail"] as? [String:Any]{
            let path = thumbnail["path"] as? String ?? ""
            let ext = thumbnail["extension"] as? String ?? ""
            let urlStr = "\(path).\(ext)"
            self.thumbnailURL = URL(string: urlStr)
            images.append(SKPhoto.photoWithImageURL(urlStr))
        }else{
            self.thumbnailURL = nil
        }
        super.init()
    }
}
