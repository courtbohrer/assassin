//
//  PlayerTableViewCell.swift
//  Assassin
//
//  Created by Quan Vo on 11/23/15.
//  Copyright © 2015 Courtney Bohrer. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playerImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(red:1.00, green:0.19, blue:0.19, alpha: 1.0)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.backgroundColor = UIColor(red:0.70, green:0.13, blue:0.13, alpha: 1.0)
        // Configure the view for the selected state
    }

}
