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

    var alarmsArr: [Alarm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        print("VIEW WILL APPEAR")
        
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
                    
                    guard let alarmTimestamp = alarmDict["timestamp"] as? String else {
                        return
                    }
                    
                    let alarmObj = Alarm()
                    
                    alarmObj.key = i.key as? String
                    alarmObj.alarmName = alarmName
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

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
        }
    }

}


