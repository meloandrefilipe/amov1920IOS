//
//  EditReceitaIngCell.swift
//  receitasDeCulinaria
//
//  Created by André Melo on 30/12/2019.
//  Copyright © 2019 André Melo. All rights reserved.
//

import UIKit

class EditReceitaIngCell: UITableViewCell {
    
    @IBOutlet weak var lbIngName: UILabel!
    
    @IBOutlet weak var lbIngQuantity: UILabel!
    
    @IBOutlet weak var lbIngUnit: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
