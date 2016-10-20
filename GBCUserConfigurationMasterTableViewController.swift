//
//  GBCUserConfigurationMasterTableViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 8/7/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

var activeAdd_EditUserViewController = false

class GBCUserConfigurationMasterTableViewController: UITableViewController {
    
    var numeroDeCeldasDetailView = 0
    
    var add_editNewUserDelegate = GBCAdd_EditNewUserTableViewController()
    
    var numberOfPatientsInDataBases:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitViewController?.preferredDisplayMode = .allVisible
        
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(GBCUserConfigurationMasterTableViewController.reloadTableViewController),
                                                         
                                                         name: NSNotification.Name(rawValue: "reloadMasterTableViewController"),
                                                         
                                                         object: nil)
        
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
        
    }
    
    func detailPatientList(){
    
    }

    @IBAction func addNewUser(_ sender: AnyObject) {

        if (activeAdd_EditUserViewController == false){
            editOrAddNewUser = UserConfigurationEditOrAddNewPatient.addNewPatient
            activeAdd_EditUserViewController = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "add_editNewUser"), object: nil, userInfo: nil)
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        numberOfPatientsInDataBases = (PatientListStruct.patientList?.value(forKey: "result") as AnyObject).count
        if numberOfPatientsInDataBases == nil{
            numberOfPatientsInDataBases = 0
        }
        return (numberOfPatientsInDataBases)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellUserConfigurationMaster", for: indexPath)
        let name = PatientListStruct.patientList?.value(forKey: "result")
        //let name = PatientListStruct.patientList!.value(forKey: "result")![(indexPath as NSIndexPath).row].value(forKey: "name")
        
        // Configure the cell...
        cell.textLabel?.text = String(describing: name!)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 18.0)
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        numeroDeCeldasDetailView = (indexPath as NSIndexPath).row
        self.performSegue(withIdentifier: "userConfigurationMasterDetail", sender: self)
    }
    
    //MARK: - Functions
    
    func reloadTableViewController(){
        activeAdd_EditUserViewController = false
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //cell.layer.cornerRadius = 10.0
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let controller = (segue.destinationViewController as! UINavigationController).topViewController as! GBCUserConfigurationDetailTableViewController
        userSelectPatient = numeroDeCeldasDetailView
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
