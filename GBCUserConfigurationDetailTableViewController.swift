//
//  GBCUserConfigurationDetailTableViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 8/7/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

var userSelectPatient = 0

class GBCUserConfigurationDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var userNameCell: UITableViewCell!
    
    @IBOutlet weak var userNameTextLabel: UILabel!
    
    @IBOutlet weak var userIdLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(GBCUserConfigurationDetailTableViewController.add_editNewUser),
                                                         
                                                         name: "add_editNewUser",
                                                         
                                                         object: nil)

        userNameCell.imageView?.image = UIImage(named: "User")
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 64/255, blue: 128/255, alpha: 1.0)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //if Users.userName.count > 0 && Users.userId.count > 0 && Users.age.count > 0 && Users.gender.count > 0{
        
            print(PatientListStruct.patientList!.valueForKey("result"))
        
            let name = PatientListStruct.patientList!.valueForKey("result")![userSelectPatient].valueForKey("name")
            let document = PatientListStruct.patientList!.valueForKey("result")![userSelectPatient].valueForKey("document")
            let age = PatientListStruct.patientList!.valueForKey("result")![userSelectPatient].valueForKey("age")
            let gender = PatientListStruct.patientList!.valueForKey("result")![userSelectPatient].valueForKey("gender")
            let email = PatientListStruct.patientList!.valueForKey("result")![userSelectPatient].valueForKey("email")
            userNameTextLabel.text = String(name!)
            userIdLabel.text = String(document!)
            ageLabel.text = String(age!)
            genderLabel.text = String(gender!)
            emailLabel.text = String(email!)
        //}

    }
    
    // Buttons
    @IBAction func homeButton(sender: AnyObject) {

        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func editButton(sender: AnyObject) {
        
        editOrAddNewUser = .editNewPatient
        let add_editTableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("add_editUserViewController") as! GBCAdd_EditNewUserTableViewController
        navigationController?.pushViewController(add_editTableViewController, animated: true)
        
    }

    // MARK: - Table view data source
/*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numeroDeCeldas
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellUserConfigurationDetail", forIndexPath: indexPath)

        cell.textLabel?.text = "user"
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 18.0)
        // Configure the cell...

        return cell
    }*/
    
    // MARK: - Functions
    func add_editNewUser(){
        let add_editUserViewController = self.storyboard?.instantiateViewControllerWithIdentifier("add_editUserViewController") as! GBCAdd_EditNewUserTableViewController
        navigationController?.pushViewController(add_editUserViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.cornerRadius = 5.0
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
