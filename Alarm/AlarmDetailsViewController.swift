//
//  AlarmDetailViewController.swift
//  Alarm
//
//  Created by Muhd Mirza on 22/8/24.
//

import UIKit

import UserNotifications

import FirebaseAuth
import FirebaseDatabase

class AlarmDetailsViewController: UIViewController, UITextFieldDelegate {

    var alarm: Alarm!
    
    // we need this array for sorting purposes when we send an "edited" alarm back to firebase
    var alarmsArr: [Alarm] = []
    
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var alarmNameTextfield: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    // initialise this to a default value first
    var inputDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.saveButton.isEnabled = false
        
        // Do any additional setup after loading the view.
        self.alarmNameTextfield.placeholder = self.alarm.alarmName
        self.alarmNameTextfield.addTarget(self, action: #selector(AlarmDetailsViewController.textFieldDidChange(textField:)), for: .editingChanged)
        
        let utilities = Utilities()
        
        
        // setting existing alarm date as default
        guard let timestamp = self.alarm.timestamp else {
            return
        }
                
        let convertedDate = utilities.getDateFromDateString(dateString: timestamp)
        self.datePicker.date = convertedDate
        
        self.inputDate = convertedDate
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
    
    @objc func textFieldDidChange(textField: UITextField)  {
        // make sure alarm text:
        // - is not empty because an empty text and a filled text is different. the old alarm text is filled
        // - is different from the old value
        if self.alarmNameTextfield.text != "" && self.alarmNameTextfield.text != self.alarm.alarmName {
            self.saveButton.isEnabled = true
        } else {
            self.saveButton.isEnabled = false
        }
    }
    
    @IBAction func pickerValueChanged(sender: UIDatePicker, forEvent event: UIEvent) {
        self.inputDate = sender.date
        
        // we are comparing date objects here
        let utilities = Utilities()
        
        guard let timestamp = self.alarm.timestamp else {
            return
        }
        let alarmDate = utilities.getDateFromDateString(dateString: timestamp)
        
        // user changed date
        if self.inputDate != alarmDate {
            self.saveButton.isEnabled = true
        } else {
            self.saveButton.isEnabled = false
        }
    }
    
    @IBAction func saveAlarm() {
        var alarmNameIsDiff = false
        var dateIsDiff = false
        
        // make sure alarm text:
        // - is not empty because an empty text and a filled text is different. the old alarm text is filled
        // - is different from the old value
        if self.alarmNameTextfield.text != "" && self.alarmNameTextfield.text != self.alarm.alarmName {
            alarmNameIsDiff = true
        }
        
        
        // we are comparing date objects here
        let utilities = Utilities()
        
        guard let timestamp = self.alarm.timestamp else {
            return
        }
        let alarmDate = utilities.getDateFromDateString(dateString: timestamp)
        
        if self.inputDate != alarmDate {
            dateIsDiff = true
        }

        // if either one is true, make the edit
        if alarmNameIsDiff == true || dateIsDiff == true {
            // delete from firebase
            let ref = Database.database().reference()
            
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }
            
            guard let alarmId = self.alarm.key else {
                return
            }
            
            ref.child("/alarms/\(userId)/\(alarmId)").removeValue { error, argRef in
                
                // watch out for errors or edge case scenarios here
                if error == nil {

                    // delete from pending notifications
                    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                        
                        // watch out for errors or edge case scenarios here
                        for request in requests {

                            // delete alarm in pending notifications (if it is enabled)
                            if request.identifier == alarmId {

                                if self.alarm.enabled == true {
                                    
                                    // remove from pending notifs
                                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarmId])
                                    
                                    // remove from local array
                                    self.alarmsArr.removeAll(where: { alarm in
                                        // remove all keys which are equivalent to alarm id
                                        alarm.key == alarmId
                                    })
                                    
                                    break
                                }
                                
                                // if alarm is not enabled or disabled, it is not in the pending notification requests
                                // hence there is no need to remove anything
                            }
                        }
                        

                        // create alarm
                        var alarmName = ""
                        
                        // we are using dispatch queue here because we are accessing a UI element
                        DispatchQueue.main.async {
                            // create alarm
                            if self.alarmNameTextfield.text == "" {
                                alarmName = self.alarm.alarmName!
                            } else {
                                alarmName = self.alarmNameTextfield.text!
                            }
                        }
                        
                        
                                                
                        // set alarmDate to existing alarm date
                        var alarmDate = utilities.getDateFromDateString(dateString: self.alarm.timestamp!)
                        
                        // if the date input by user is not the same
                        if self.inputDate != alarmDate {

                            // set alarm date to new date
                            alarmDate = self.inputDate
                        }
                        
                        guard let key = ref.child("/alarms/\(userId)").childByAutoId().key else {
                            return
                        }
                        
                        /* create notif request */
                        // create notification content
                        let content = UNMutableNotificationContent()
                        content.title = alarmName
                        content.body = "ALARM"
                        content.sound = UNNotificationSound.default
                        
                        
                        let utilities = Utilities()
                        
                        // you need the dateComponents for the notification trigger
                        // extract the components from that date object
                        let calendar = Calendar.current
                        let selectedDateYear = calendar.component(.year, from: alarmDate)
                        let selectedDateMonth = calendar.component(.month, from: alarmDate)
                        let selectedDateDay = calendar.component(.day, from: alarmDate)
                        let selectedDateHour = calendar.component(.hour, from: alarmDate)
                        let selectedDateMin = calendar.component(.minute, from: alarmDate)
                        let selectedDateSecond = calendar.component(.second, from: alarmDate)
                        
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
                                
                                let formattedTimestamp = utilities.getStringForDate(date: alarmDate)

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
                                        "timestamp": formattedTimestamp
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

                                ref.child("/alarms/\(userId)").setValue(todoDict)

                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
