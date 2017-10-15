//
//  DetailsCell.swift
//  MarvelProject
//
//  Created by tomer on 27/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit

class DetailsCell: UICollectionViewCell {
    
    @IBOutlet weak var label : UILabel!
    
    func configure(with text : String){
        label.text = text
    }
}
