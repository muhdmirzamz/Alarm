//
//  AlarmTableViewCell.swift
//  Alarm
//
//  Created by Muhd Mirza on 26/10/24.
//

import UIKit

class AlarmTableViewCell: UITableViewCell {
    
    @IBOutlet var alarmTimeLabel: UILabel!
    @IBOutlet var alarmNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
