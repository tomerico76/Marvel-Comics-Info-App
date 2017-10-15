//
//  Comics.swift
//  MarvelProject
//
//  Created by tomer on 27/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class ComicsItem : Item {

    required init(_ dict : [String:Any], isMarvel : Bool) {
        super.init(dict, isMarvel: isMarvel)
        self.name = dict["title"] as? String
        if let imagesUrls = dict["images"] as? [MarvelManager.JSON]{
            for imageUrl in imagesUrls{
                
                let path = imageUrl["path"] as? String ?? ""
                let ext = imageUrl["extension"] as? String ?? ""
                let urlStr = "\(path).\(ext)"
                images.append(SKPhoto.photoWithImageURL(urlStr))
            }
        }
    }
}
