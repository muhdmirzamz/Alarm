//
//  AlarmDetailViewController.swift
//  Alarm
//
//  Created by Muhd Mirza on 22/8/24.
//

import UIKit

class AlarmDetailViewController: UIViewController {

    var alarm: Alarm!
    
    @IBOutlet var alarmName: UILabel!
    @IBOutlet var alarmTimestamp: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.alarmName.text = alarm.alarmName
        self.alarmTimestamp.text = alarm.timestamp
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
