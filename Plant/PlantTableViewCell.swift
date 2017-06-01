//
//  PlantTableViewCell.swift
//  Plant
//
//  Created by Kun Huang on 5/30/17.
//  Copyright © 2017 Kun Huang. All rights reserved.
//

import UIKit

class PlantTableViewCell: UITableViewCell {
    
    @IBOutlet weak var plantNameLbl: UILabel!
    @IBOutlet weak var countryFlagImgView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
