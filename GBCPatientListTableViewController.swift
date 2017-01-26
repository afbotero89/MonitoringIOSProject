//
//  GBCPatientListTableViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 26/1/17.
//  Copyright © 2017 FING156561. All rights reserved.
//

import UIKit

class GBCPatientListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if PatientListStruct.numberOfPatientsInDataBases == nil{
            PatientListStruct.numberOfPatientsInDataBases = 0
        }

        return PatientListStruct.numberOfPatientsInDataBases!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPatientList", for: indexPath)
        
        //let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cellUserConfigurationMaster")
        
        let name = (PatientListStruct.patientList[indexPath.row] as AnyObject).value(forKey: "name")
        
        let document = (PatientListStruct.patientList[indexPath.row] as AnyObject).value(forKey: "document")
        
        //let name = PatientListStruct.patientList!.value(forKey: "result")![(indexPath as NSIndexPath).row].value(forKey: "name")
        
        // Configure the cell...
        cell.textLabel?.text = String(describing: name!)
        
        cell.detailTextLabel?.text = "Asigned monitor: False"
        
        cell.detailTextLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 18.0)
        
        var imageView : UIImageView?
        
        imageView  = UIImageView(frame: CGRect(x: 20, y: 20, width: 30, height: 30))
        
        imageView?.image = UIImage(named:"MonitorNo-Assigned")
        
        cell.accessoryView = imageView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        var imageView : UIImageView?
        
        imageView  = UIImageView(frame: CGRect(x: 20, y: 20, width: 30, height: 30))
        
        imageView?.image = UIImage(named:"MonitorAssigned")
        
        cell?.accessoryView = imageView

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
