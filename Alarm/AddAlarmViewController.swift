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
        
        let calendar = Calendar.current
        let utilities = Utilities()
        
        let selectedDate = utilities.getDateFromDateString(dateString: self.formattedTimestamp)
        let todayDate = Date()
        
        var finalDate: Date
        
        // time has passed
        if selectedDate > todayDate {
            // set time to tomorrow
            finalDate = calendar.date(byAdding: .day, value: 1, to: selectedDate)!
        } else {
            // set time to today
            finalDate = selectedDate
        }
        
        
        
        
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
        content.userInfo = [
            "userId": userId,
            "alarmId": key,
        ]
        
        
        // extract the components from that date object
        let selectedDateHour = calendar.component(.hour, from: finalDate)
        let selectedDateMin = calendar.component(.minute, from: finalDate)
        
        // input the components into a DateComponent object
        var dateComponents = DateComponents()
        dateComponents.hour = selectedDateHour
        dateComponents.minute = selectedDateMin
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
                
        let todoDict: NSMutableDictionary = [
            key: [
                "name": alarmName,
                "key": key,
//                "order": 0,
                "enabled": true,
                "timestamp": self.formattedTimestamp
            ]
        ]
                
        for todo in self.alarmsArr {
            let newDict: [String: Any] = [
                "name": todo.alarmName!,
                "key": todo.key!,
//                "order": count,
                "enabled": true,
                "timestamp": todo.timestamp!
            ]
        
            todoDict.setValue(newDict, forKey: todo.key!)
        }
        
        let updates = ["/alarms/\(userId)": todoDict]
        ref.updateChildValues(updates)
        
        self.navigationController?.popViewController(animated: true)
    }

}
