//
//  AlarmListTableViewController.swift
//  Alarm
//
//  Created by Muhd Mirza on 6/6/24.
//

import UIKit

import FirebaseAuth
import FirebaseDatabase

class AlarmListTableViewController: UITableViewController {

    var alarmArr: [Alarm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self.alarmArr.removeAll()
        
        let ref = Database.database().reference()
        
        guard let userid = Auth.auth().currentUser?.uid else {
            return
        }
        
        ref.child("/alarms").child(userid).observeSingleEvent(of: .value) { snapshot in
            if let alarmsDict = snapshot.value as? Dictionary<String, Any> {
                for i in alarmsDict {
                    
                    guard let alarmDict = i.value as? Dictionary<String, Any> else {
                        return
                    }
                    
                    guard let alarmName = alarmDict["name"] as? String else {
                        return
                    }
                    
                    guard let alarmTimestamp = alarmDict["timestamp"] as? String else {
                        return
                    }
                    
                    let alarmObj = Alarm()
                    
                    alarmObj.key = i.key
                    alarmObj.alarmName = alarmName
                    alarmObj.timestamp = alarmTimestamp
                    
                    self.alarmArr.append(alarmObj)
                }
                
                self.tableView.reloadData()
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
        return self.alarmArr.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        var cellConfig = cell.defaultContentConfiguration()
        cellConfig.text = self.alarmArr[indexPath.row].alarmName
        
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
            addAlarmVC?.alarmArr = self.alarmArr
        }
    }

}
