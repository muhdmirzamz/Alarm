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
    @IBOutlet var enableSwitch: UISwitch!
    @IBOutlet var alarmNameTextfield: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    // initialise this to a default value first
    var inputDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.saveButton.isEnabled = false
        
        // Do any additional setup after loading the view.
        self.enableSwitch.isOn = self.alarm.enabled!
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
    
    @IBAction func switchValueChanged(_ sender : UISwitch!){
        
        if self.enableSwitch.isOn != self.alarm.enabled {
            self.saveButton.isEnabled = true
        } else {
            self.saveButton.isEnabled = false
        }
    }
    
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
        var enableSwitchIsDiff = false
        var alarmNameIsDiff = false
        var dateIsDiff = false
        
        if self.alarm.enabled != self.enableSwitch.isOn {
            enableSwitchIsDiff = true
        }
        
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
        if enableSwitchIsDiff == true || alarmNameIsDiff == true || dateIsDiff == true {
            // delete from firebase
            let ref = Database.database().reference()
            
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }
            
            // we are using the same key
            guard let alarmId = self.alarm.key else {
                return
            }
            
            
            
            // ========= delete from pending notifications =========
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                for request in requests {
                    // delete alarm in pending notifications (if it is enabled)
                    if request.identifier == alarmId {

                        if self.alarm.enabled == true {
                            // remove from pending notifs
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarmId])
                            
                            break
                        }
                    }
                }
                
                var alarmEnabled = false
                
                // we are using dispatch queue here because we are accessing a UI element
                DispatchQueue.main.async {
                    if self.enableSwitch.isOn == true {
                        alarmEnabled = true
                    } else {
                        alarmEnabled = false
                    }
                }
                
                
                // ========= get new alarm properties =========
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
                
                let formattedTimestamp = utilities.getStringForDate(date: alarmDate)
                
                // only create the notification req if alarm is enabled
                if alarmEnabled == true {
                    // ========= create new notif request =========
                    let content = UNMutableNotificationContent()
                    content.title = alarmName
                    content.body = "ALARM"
                    content.sound = UNNotificationSound.default
                    
                    // you need the dateComponents for the notification trigger
                    // extract the components from that date object
                    let calendar = Calendar.current
                    let selectedDateHour = calendar.component(.hour, from: alarmDate)
                    let selectedDateMin = calendar.component(.minute, from: alarmDate)
                    
                    // input the components into a DateComponent object
                    var dateComponents = DateComponents()
                    dateComponents.hour = selectedDateHour
                    dateComponents.minute = selectedDateMin
                    dateComponents.timeZone = .current
                    
                    let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
                    
                    // we will be using the key from firebase as the alarm identifier
                    let request = UNNotificationRequest.init(identifier: self.alarm.key!, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let _ = error {
                            print("Error: unable to create request")
                        } else {
                            print("Success: request created successfully")
                        }
                    }
                }
                
                let updates = [
                    "/alarms/\(userId)/\(self.alarm.key!)/enabled": alarmEnabled,
                    "/alarms/\(userId)/\(self.alarm.key!)/name": alarmName,
                    "/alarms/\(userId)/\(self.alarm.key!)/timestamp": formattedTimestamp,
                ]
                ref.updateChildValues(updates)
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
