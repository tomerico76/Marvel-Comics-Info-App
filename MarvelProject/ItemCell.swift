//
//  CharacterCell.swift
//  MarvelProject
//
//  Created by tomer on 16/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit
import SDWebImage

class ItemCell: UICollectionViewCell {
    
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var imageView : UIImageView!
    
    func configure(with item : Item){
        
        imageView.image = nil
        
        if let url = item.thumbnailURL{
            imageView.sd_setImage(with: url)
        }else{
            imageView.sd_cancelCurrentImageLoad()
        }
        
        label.text = item.name
    }
}
