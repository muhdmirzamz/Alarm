//
//  AddAlarmViewController.swift
//  Alarm
//
//  Created by Muhd Mirza on 6/6/24.
//

import UIKit

import FirebaseAuth
import FirebaseDatabase

class AddAlarmViewController: UIViewController {
    
    @IBOutlet var textfield: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    var alarmArr: [Alarm] = []
    
    var formattedTimestamp = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set default date and time by getting the default date and time from the date picker
        let utilities = Utilities()
        self.formattedTimestamp = utilities.getStringForDate(date: self.datePicker.date)
        
        print("curr timestamp: \(self.formattedTimestamp)")
        
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
        
        guard let todo = self.textfield.text else {
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let key = ref.child("/alarms/\(userId)").childByAutoId().key else {
            return
        }
        
        // create a starting dictionary with the new element having count 0
        let todoDict: NSMutableDictionary = [
            key: [
                "name": todo,
//                "order": 0,
                "timestamp": self.formattedTimestamp
            ]
        ]
        
        // start the next element with count 1
//        var count = 1
        
        // loop through the existing array
        for todo in self.alarmArr {
            let newDict: [String: Any] = [
                "name": todo.alarmName!,
//                "order": count,
                "timestamp": todo.timestamp!
            ]
            
//            count += 1
            
            todoDict.setValue(newDict, forKey: todo.key!)
        }
        
        ref.child("/alarms/\(userId)").setValue(todoDict)
        
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
