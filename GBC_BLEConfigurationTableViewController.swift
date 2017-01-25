//
//  GBC_BLEConfigurationTableViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 19/1/17.
//  Copyright © 2017 FING156561. All rights reserved.
//

import UIKit

class GBC_BLEConfigurationTableViewController: UITableViewController {
    
    /// Bluetooth manager
    var bluetoothManager:BluetoothManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the bluetooth manager.
        self.bluetoothManager = BluetoothManager()
        
        NotificationCenter.default.addObserver(self,
                                               
                                               selector: #selector(GBCUserConfigurationMasterTableViewController.reloadTableViewController),
                                               
                                               name: NSNotification.Name(rawValue: "reloadMasterMonitorsNearby"),
                                               
                                               object: nil)
        
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
        return PressureMonitors.monitorsNearby.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bleListCell", for: indexPath)
        
        cell.textLabel?.text = PressureMonitors.monitorsNearby[PressureMonitors.monitorsNearby.index(PressureMonitors.monitorsNearby.startIndex, offsetBy: indexPath.row)]
        cell.detailTextLabel?.text = "UUID: BDCBCB68-4353-4540-AEE4-9D4D9295121A"
        
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
        
        var imageView : UIImageView?
        
        imageView  = UIImageView(frame: CGRect(x: 20, y: 20, width: 30, height: 30))
        
        imageView?.image = UIImage(named:"Configuration3")
        
        cell.accessoryView = imageView
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func reloadTableViewController(){
        self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: UITableViewRowAnimation.automatic)
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
