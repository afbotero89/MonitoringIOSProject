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
    
    override func viewDidAppear(_ animated: Bool) {

        changeLabelsValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        //changeLabelsValues()
    }
    
    // MARK: - Buttons
    @IBAction func cancelButton(_ sender: AnyObject) {
        activeAdd_EditUserViewController = false
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func okButton(_ sender: AnyObject) {
        
        if userNameLabel.text != "" && userIdLabel.text != "" && userAgeLabel.text != "" && userGenderLabel.text != "" && emailLabel.text! != ""{
            let branch_id = "1"
            switch editOrAddNewUser{
            case .addNewPatient:
                Users.userName.insert(userNameLabel.text!)
                Users.userId.append(userIdLabel.text!)
                Users.age.append(userAgeLabel.text!)
                Users.gender.append(userGenderLabel.text!)
                
                //queriesUserAdmin.insertNewPatient_postRequest(branch_id,name:userNameLabel.text!,document:userIdLabel.text!,age:userAgeLabel.text!,gender:userGenderLabel.text!,email:emailLabel.text!)
                
                queriesUserAdmin.insertNewPatient(userNameLabel.text!, document: userIdLabel.text!, age: userAgeLabel.text!, gender: userGenderLabel.text!, email: "email", pass: "1", profile: "1")

            case .editNewPatient:
                
                //queriesUserAdmin.editPatientByID(1, branch_id: branch_id, name:userNameLabel.text!, document:userIdLabel.text!, age:userAgeLabel.text!, gender:userGenderLabel.text!, email:emailLabel.text!)
                let last_id = ((PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "id") as! NSString).intValue
                let last_name = (PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "name")
                let last_document = (PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "document")

                
                queriesUserAdmin.editPatient(Int(last_id), last_name: last_name as! String, last_document: last_document as! String, name: userNameLabel.text!, document: userIdLabel.text!, age: userAgeLabel.text!, gender: userGenderLabel.text!, email: emailLabel.text!, pass: "1", profile: "1")
            
                
                
            }
            
            activeAdd_EditUserViewController = false
            
            queriesUserAdmin.getPatientList()
            
            _ = navigationController?.popViewController(animated: true)

        }else{
            
            alertController = UIAlertController(title: "", message: NSLocalizedString("Please fill out all fields", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
            alertController!.addAction(UIAlertAction(title:  NSLocalizedString("Done", comment: ""), style: .default, handler: nil))
            present(alertController!, animated: true, completion: nil)
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
                    
                    let name = (PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "name")
                    let document = (PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "document")
                    let age = (PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "age")
                    let gender = (PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "gender")
                    let email = (PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "mail")
                
                    userNameLabel.text = String(describing: name!)
                    userIdLabel.text = String(describing: document!)
                    userAgeLabel.text = String(describing: age!)
                    userGenderLabel.text = String(describing: gender!)
                    emailLabel.text = String(describing: email)
                }
            
                userNameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
                userIdLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
                userAgeLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
                userGenderLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
                emailLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
            //}
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.cornerRadius = 5.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1{
            return 60.0
        }else{
            return 50.0
        }
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
