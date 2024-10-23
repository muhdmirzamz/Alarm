//
//  AlarmListTableViewController.swift
//  Alarm
//
//  Created by Muhd Mirza on 6/6/24.
//

import UIKit

import FirebaseAuth
import FirebaseDatabase

import UserNotifications

class AlarmListTableViewController: UITableViewController {

    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    
    var alarmsArr: [Alarm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        print("[viewWillAppear] =========")
        
        self.alarmsArr.removeAll()
        
        print("removing all in alarm arr")
        
        print("fetching data...")
        let ref = Database.database().reference()
        
        guard let userid = Auth.auth().currentUser?.uid else {
            return
        }
        
        ref.child("/alarms").child(userid).observeSingleEvent(of: .value) { snapshot  in
            if let alarmsDict = snapshot.value as? NSDictionary {
                for i in alarmsDict {
                    
                    guard let alarmDict = i.value as? NSDictionary else {
                        return
                    }
                    
                    guard let alarmName = alarmDict["name"] as? String else {
                        return
                    }
                    
                    guard let alarmIsEnabled = alarmDict["enabled"] as? Bool else {
                        return
                    }
                    
                    guard let alarmTimestamp = alarmDict["timestamp"] as? String else {
                        return
                    }
                    
                    let alarmObj = Alarm()
                    
                    alarmObj.key = i.key as? String
                    alarmObj.alarmName = alarmName
                    alarmObj.enabled = alarmIsEnabled
                    alarmObj.timestamp = alarmTimestamp
                    
                    self.alarmsArr.append(alarmObj)
                    
                    print("adding data")
                }
                
                let utilities = Utilities()
                
                
                print("sorting data")
                
                // we are sorting using the timestamp variable
                // but we need to convert it to a Date type
                self.alarmsArr.sort(by: { alarm1, alarm2 in
                    
                    // timestamp is an optional
                    guard let alarm1Timestamp = alarm1.timestamp else {
                        return false
                    }
                    
                    // the date function returns a Date object, not an optional
                    let date1 = utilities.getDateFromDateString(dateString: alarm1Timestamp)
                    
                    guard let alarm2Timestamp = alarm2.timestamp else {
                        return false
                    }
                    
                    let date2 = utilities.getDateFromDateString(dateString: alarm2Timestamp)
                    
                    return date1 < date2
                })
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("there is no data")
                
                // there is no data
                
                // we have already removed all data in alarms array
                // so we should remember to reload data here
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.alarmsArr.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        var cellConfig = cell.defaultContentConfiguration()
        cellConfig.text = self.alarmsArr[indexPath.row].alarmName
        
        cell.contentConfiguration = cellConfig

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // delete from firebase
            let ref = Database.database().reference()
            
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }
            
            let alarm = self.alarmsArr[indexPath.row]
            
            guard let alarmId = alarm.key else {
                return
            }
            
            print("alarm id to be deleted: \(alarmId)")
            
            ref.child("/alarms/\(userId)/\(alarmId)").removeValue { error, ref in
                if error == nil {
                    
                    print("accessing pending notifications")
                    
                    // delete from pending notifications
                    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                        for request in requests {
                            
                            // delete alarm in pending notifications (if it is enabled)
                            if request.identifier == alarmId {
                                
                                print("found alarm id")
                                
                                if alarm.enabled == true {
                                    print("deleting alarm from pending notifications")
                                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarmId])
                                    break
                                }
                                
                                // if alarm is not enabled or disabled, it is not in the pending notification requests
                                // hence there is no need to remove anything
                            }
                        }

                        // delete from local array
                        self.alarmsArr.remove(at: indexPath.row)
                        
                        DispatchQueue.main.async {
                            // Delete the row from the data source
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                }
            }
                        
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    @IBAction func editTable() {
        // if table view is not in edit mode
        if self.tableView.isEditing == false {
            
            // turn it into edit mode
            self.tableView.isEditing = true
            
            /*
                table view should be in edit mode here
                UI elements should reflect a table view in edit mode
             */
            
            // in idle mode, the edit button should display "Done" to signify to users to exit edit mode
            self.editButton.title = "Done"
            
            // we want to disable adding alarms in edit mode
            self.addButton.isEnabled = false
        } else {
            // if table view is in edit mode
            
            // exit edit mode
            self.tableView.isEditing = false
            
            /*
                table view should not be in edit mode here
             */
            
            // the edit button should display "Edit" to signify to users that they can start editing if they tap on this button
            self.editButton.title = "Edit"
            
            // we want to enable adding alarms when not in edit mode
            self.addButton.isEnabled = true
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueToAddAlarm" {
            let addAlarmVC = segue.destination as? AddAlarmViewController
            addAlarmVC?.alarmsArr = self.alarmsArr
        }
        
        if segue.identifier == "segueToViewAlarmDetails" {
            guard let indexPathForAlarm = self.tableView.indexPathForSelectedRow else {
                return
            }
            
            let alarmDetailsVC = segue.destination as? AlarmDetailsViewController
            alarmDetailsVC?.alarm = self.alarmsArr[indexPathForAlarm.row]
            alarmDetailsVC?.alarmsArr = self.alarmsArr
        }
    }

}


