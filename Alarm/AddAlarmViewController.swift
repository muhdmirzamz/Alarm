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
    
    var alarmArr: [Alarm] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        var todoDict: [String : [String : String]] = [:]
        
        todoDict[key] = ["name": todo, "timestamp": "timestamp"]
        
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
