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
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(GBCUserConfigurationDetailTableViewController.add_editNewUser),
                                                         
                                                         name: NSNotification.Name(rawValue: "add_editNewUser"),
                                                         
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               
                                               selector: #selector(GBCUserConfigurationDetailTableViewController.reloadTableViewController),
                                               
                                               name: NSNotification.Name(rawValue: "reloadDetailAdminUserPanel"),
                                               
                                               object: nil)

        userNameCell.imageView?.image = UIImage(named: "User")
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        //if Users.userName.count > 0 && Users.userId.count > 0 && Users.age.count > 0 && Users.gender.count > 0{
        
        if PatientListStruct.patientList.count != 0{
            
            let name = (PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "name")
            let document = (PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "document")
            let age = (PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "age")
            let gender = (PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "gender")
            let email = (PatientListStruct.patientList[userSelectPatient] as AnyObject).value(forKey: "name")
            userNameTextLabel.text = String(describing: name!)
            userIdLabel.text = String(describing: document!)
            ageLabel.text = String(describing: age!)
            genderLabel.text = String(describing: gender!)
            emailLabel.text = String(describing: email!)
 
        }else{
            userNameTextLabel.text = "nil"
            userIdLabel.text = "nil"
            ageLabel.text = "nil"
            genderLabel.text = "nil"
            emailLabel.text = "nil"
        
        }
        
        userNameTextLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
        userIdLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
        ageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
        genderLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
        emailLabel.font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
        //}

    }
    
    // Buttons
    @IBAction func homeButton(_ sender: AnyObject) {

        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func editButton(_ sender: AnyObject) {
        
        editOrAddNewUser = UserConfigurationEditOrAddNewPatient.editNewPatient
        let add_editTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "add_editUserViewController") as! GBCAdd_EditNewUserTableViewController
        navigationController?.pushViewController(add_editTableViewController, animated: true)
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1{
            return 60.0
        }else{
            return 50.0
        }
    }
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
        let add_editUserViewController = self.storyboard?.instantiateViewController(withIdentifier: "add_editUserViewController") as! GBCAdd_EditNewUserTableViewController
        navigationController?.pushViewController(add_editUserViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.cornerRadius = 5.0
    }
    
    func reloadTableViewController(){
        self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: UITableViewRowAnimation.automatic)
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
