//
//  TableViewDetailsCell.swift
//  MarvelProject
//
//  Created by tomer on 31/08/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit

class TableViewDetailsCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    
    func configure(with item : Item){
        nameLabel.text = item.name
        itemImage.sd_setImage(with: item.thumbnailURL)
    }
}
