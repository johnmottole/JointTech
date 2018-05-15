//
//  MessageTableViewCell.swift
//  JoinTech
//
//  Created by John Mottole on 4/22/18.
//  Copyright © 2018 John Mottole. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var prof: UIImageView!
    @IBOutlet weak var last: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var doctor: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
