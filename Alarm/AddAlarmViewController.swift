//
//  AddAlarmViewController.swift
//  Alarm
//
//  Created by Muhd Mirza on 6/6/24.
//

import UIKit

import UserNotifications

import FirebaseAuth
import FirebaseDatabase

class AddAlarmViewController: UIViewController {
    
    @IBOutlet var textfield: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    var alarmsArr: [Alarm] = []
    
    var formattedTimestamp = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set default date and time by getting the default date and time from the date picker
        let utilities = Utilities()
        self.formattedTimestamp = utilities.getStringForDate(date: self.datePicker.date)

    }
    
    @IBAction func pickerValueChanged(sender: UIDatePicker, forEvent event: UIEvent) {
        let date = sender.date
        print("Date chosen: \(date)")
        
        let utilities = Utilities()
        self.formattedTimestamp = utilities.getStringForDate(date: sender.date)
        
        print("Date chosen (formatted): \(formattedTimestamp)")
    }
    
    @IBAction func addAlarm() {
        
        let ref = Database.database().reference()
        
        guard let alarmName = self.textfield.text else {
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let key = ref.child("/alarms/\(userId)").childByAutoId().key else {
            return
        }
        
        /*
            a request contains:
            - content
            - trigger (requires a dateComponent)
         
            extract the components from the date input
            put it inside a DateComponents object
         
            create a request
            add request to UNUserNotificationCenter
        */
        
        // create notification content
        let content = UNMutableNotificationContent()
        content.title = alarmName
        content.body = "ALARM"
        content.sound = UNNotificationSound.default
        
        
        let utilities = Utilities()
        
        // you need the dateComponents for the notification trigger
        // to get that, you get the date object from converting the date string
        let selectedDate = utilities.getDateFromDateString(dateString: self.formattedTimestamp)
        
        // extract the components from that date object
        let calendar = Calendar.current
        let selectedDateYear = calendar.component(.year, from: selectedDate)
        let selectedDateMonth = calendar.component(.month, from: selectedDate)
        let selectedDateDay = calendar.component(.day, from: selectedDate)
        let selectedDateHour = calendar.component(.hour, from: selectedDate)
        let selectedDateMin = calendar.component(.minute, from: selectedDate)
        let selectedDateSecond = calendar.component(.second, from: selectedDate)
        
        // input the components into a DateComponent object
        var dateComponents = DateComponents()
        dateComponents.year = selectedDateYear
        dateComponents.month = selectedDateMonth
        dateComponents.day = selectedDateDay
        dateComponents.hour = selectedDateHour
        dateComponents.minute = selectedDateMin
        dateComponents.second = selectedDateSecond
        dateComponents.timeZone = .current
        
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // we will be using the key from firebase as the alarm identifier
        let request = UNNotificationRequest.init(identifier: key, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let _ = error {
                print("Error: unable to create request")
            } else {
                print("Success: request created successfully")
            }
        }
        
        // what the code below does is to simply create a new dictionary
        // loop through the current array
        // add every item to the new dictionary
        // we are doing this because firebase accepts NSDictionaries
        
        // *we will not be using count for now
        
        // create a starting dictionary with the new element having count 0
        let todoDict: NSMutableDictionary = [
            key: [
                "name": alarmName,
                "key": key,
//                "order": 0,
                "enabled": true,
                "timestamp": self.formattedTimestamp
            ]
        ]
        
        // start the next element with count 1
//        var count = 1
        
        // loop through the existing array
        for todo in self.alarmsArr {
            let newDict: [String: Any] = [
                "name": todo.alarmName!,
                "key": todo.key!,
//                "order": count,
                "enabled": true,
                "timestamp": todo.timestamp!
            ]
            
//            count += 1
            
            // add new element to the dictionary
            todoDict.setValue(newDict, forKey: todo.key!)
        }
        
        let updates = ["/alarms/\(userId)": todoDict]
        ref.updateChildValues(updates)
        
        self.navigationController?.popViewController(animated: true)
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
