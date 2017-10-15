//
//  TableViewSearchCell.swift
//  MarvelProject
//
//  Created by tomer on 04/09/2017.
//  Copyright © 2017 tomer. All rights reserved.
//

import UIKit

class TableViewSearchCell: UITableViewCell {

    @IBOutlet weak var label : UILabel!
    
    func configure(with text : String){
        label.text = text
    }
}
