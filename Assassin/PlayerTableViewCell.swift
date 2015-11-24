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
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
