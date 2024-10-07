//
//  AlarmDetailViewController.swift
//  Alarm
//
//  Created by Muhd Mirza on 22/8/24.
//

import UIKit

import FirebaseAuth
import FirebaseDatabase

class AlarmDetailsViewController: UIViewController {

    var alarm: Alarm!
    
    @IBOutlet var alarmName: UILabel!
    @IBOutlet var alarmTimestamp: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.alarmName.text = self.alarm.alarmName
        
        let utilities = Utilities()
        
        guard let timestamp = alarm.timestamp else {
            return
        }
        
        self.alarmTimestamp.text = utilities.getUserReadableStringFromDate(dateString: timestamp)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func deleteAlarm() {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        // delete alarm in firebase
        let ref = Database.database().reference()
        
        ref.child("/alarms/\(userId)/\(self.alarm.key!)").removeValue { error, ref in
            if error == nil {
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    for request in requests {
                        
                        // delete alarm in pending notifications (if it is enabled)
                        if request.identifier == self.alarm.key! {
                            if self.alarm.enabled == true {
                                print("deleting data")
                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.alarm.key!])
                            }
                            
                            // if alarm is not enabled or disabled, it is not in the pending notification requests
                            // hence there is no need to remove anything
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }

}
