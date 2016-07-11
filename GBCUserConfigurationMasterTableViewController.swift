//
//  GBCUserConfigurationMasterTableViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 8/7/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

class GBCUserConfigurationMasterTableViewController: UITableViewController {
    
    var numeroDeCeldasDetailView = 0
    
    var activeAdd_EditUserViewController = false
    
    var add_editNewUserDelegate = GBCAdd_EditNewUserTableViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitViewController?.preferredDisplayMode = .AllVisible
        
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(GBCUserConfigurationMasterTableViewController.reloadTableViewController),
                                                         
                                                         name: "reloadMasterTableViewController",
                                                         
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

    @IBAction func addNewUser(sender: AnyObject) {
        print("add new user")
        print(activeAdd_EditUserViewController)
        if (activeAdd_EditUserViewController == false){
            add_editNewUserDelegate.editOrAddNewUser = .addNewPatient
            activeAdd_EditUserViewController = true
            NSNotificationCenter.defaultCenter().postNotificationName("add_editNewUser", object: nil, userInfo: nil)
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (Users.userName.count)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellUserConfigurationMaster", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = Users.userName[indexPath.row]
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 18.0)
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("celda")
        numeroDeCeldasDetailView = indexPath.row
        self.performSegueWithIdentifier("userConfigurationMasterDetail", sender: self)
    }
    
    //MARK: - Functions
    
    func reloadTableViewController(){
        activeAdd_EditUserViewController = false
        self.tableView.reloadData()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepare for segue")
        let controller = (segue.destinationViewController as! UINavigationController).topViewController as! GBCUserConfigurationDetailTableViewController
        controller.userSelectPatient = numeroDeCeldasDetailView
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
