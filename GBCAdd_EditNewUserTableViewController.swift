//
//  GBCAdd_EditNewUserTableViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 11/7/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

var editOrAddNewUser:UserConfigurationEditOrAddNewPatient = .editNewPatient

class GBCAdd_EditNewUserTableViewController: UITableViewController {

    @IBOutlet weak var cell1: UITableViewCell!
    
    @IBOutlet weak var userNameLabel: UITextField!

    @IBOutlet weak var userIdLabel: UITextField!
    
    @IBOutlet weak var userAgeLabel: UITextField!
    
    @IBOutlet weak var userGenderLabel: UITextField!
    
    @IBOutlet weak var emailLabel: UITextField!
    
    let queriesUserAdmin = GBCDataBaseQueriesUserAdmin()
    
    var alertController:UIAlertController?
    
    //let userConfigurationDetail = GBCUserConfigurationMasterTableViewController()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cell1.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {

        changeLabelsValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        //changeLabelsValues()
    }
    
    // MARK: - Buttons
    @IBAction func cancelButton(sender: AnyObject) {
        activeAdd_EditUserViewController = false
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func okButton(sender: AnyObject) {
        
        if userNameLabel.text != "" && userIdLabel.text != "" && userAgeLabel.text != "" && userGenderLabel.text != "" && emailLabel.text! != ""{
            let branch_id = "1"
            switch editOrAddNewUser{
            case .addNewPatient:
                Users.userName.insert(userNameLabel.text!)
                Users.userId.append(userIdLabel.text!)
                Users.age.append(userAgeLabel.text!)
                Users.gender.append(userGenderLabel.text!)
                
                queriesUserAdmin.insertNewPatient_postRequest(branch_id,name:userNameLabel.text!,document:userIdLabel.text!,age:userAgeLabel.text!,gender:userGenderLabel.text!,email:emailLabel.text!)

            case .editNewPatient:
                
                queriesUserAdmin.editPatientByID(1, branch_id: branch_id, name:userNameLabel.text!, document:userIdLabel.text!, age:userAgeLabel.text!, gender:userGenderLabel.text!, email:emailLabel.text!)
                
            }
            
            activeAdd_EditUserViewController = false
            
            NSNotificationCenter.defaultCenter().postNotificationName("reloadMasterTableViewController", object: nil, userInfo: nil)
            
            navigationController?.popViewControllerAnimated(true)

        }else{
            
            alertController = UIAlertController(title: "", message: NSLocalizedString("Please fill out all fields", comment: ""), preferredStyle:UIAlertControllerStyle.Alert)
            alertController!.addAction(UIAlertAction(title:  NSLocalizedString("Done", comment: ""), style: .Default, handler: nil))
            presentViewController(alertController!, animated: true, completion: nil)
        }
    }
    
    // MARK: - Functions
    func changeLabelsValues(){
        switch editOrAddNewUser {
        case .addNewPatient:
            
            userNameLabel.text = ""
            userIdLabel.text = ""
            userAgeLabel.text = ""
            userGenderLabel.text = ""
            
            cell1.imageView!.image = UIImage(named: "User")
            cell1.textLabel?.text = "New patient"
            
        case .editNewPatient:
            
            //if (Users.userName.count>0 && Users.userId.count>0 && Users.age.count>0 && Users.gender.count>0){
            
                cell1.imageView!.image = UIImage(named: "User")
                cell1.textLabel?.text = "Edit patient"
                
                if PatientListStruct.patientList != nil{
                    let name = PatientListStruct.patientList!.valueForKey("result")![userSelectPatient].valueForKey("name")
                    let document = PatientListStruct.patientList!.valueForKey("result")![userSelectPatient].valueForKey("document")
                    let age = PatientListStruct.patientList!.valueForKey("result")![userSelectPatient].valueForKey("age")
                    let gender = PatientListStruct.patientList!.valueForKey("result")![userSelectPatient].valueForKey("gender")
                    let email = PatientListStruct.patientList!.valueForKey("result")![userSelectPatient].valueForKey("email")
                
                    userNameLabel.text = String(name!)
                    userIdLabel.text = String(document!)
                    userAgeLabel.text = String(age!)
                    userGenderLabel.text = String(gender!)
                    emailLabel.text = String(email!)
                }
            //}
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.cornerRadius = 5.0
    }
    
    // MARK: - Table view data source
/*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("add_editNewUserCell", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
 */

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
