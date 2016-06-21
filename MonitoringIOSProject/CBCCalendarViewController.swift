//
//  CBCCalendarViewController.swift
//  MonitoringIOSProject
//
//  Created by Felipe Botero on 14/05/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

var internetConnectionError = false

struct PhysiologicalVariablesStoredInDatabaseSQL{
    static var systolicPressure:[Double] = []
    static var diastolicPressure:[Double] = []
    static var averagePressure:[Double] = []
    static var heartRate:[Double] = []
    static var hour:[String] = []
    static var dateSelectedByTheUser:String?
    static var dayMonthYearDataBaseSQL:NSString?
}

class CBCCalendarViewController: UIViewController, CalendarViewDelegate {

    @IBOutlet var placeholderView: UIView!
    
    @IBOutlet weak var displayRecordButton: UIButton!
    
    let requestGetDataBaseSQL = NSMutableURLRequest(URL: NSURL(string:"http://www.sibxe.co/appMonitoreo/querysToDatabaseGetData.php")!)
    
    var responseString:NSString!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // todays date.
        let date = NSDate()
        
        title = NSLocalizedString("Calendar", comment: "")
        
        displayRecordButton.setTitle(NSLocalizedString("Display", comment: ""), forState: .Normal)
        // create an instance of calendar view with
        // base date (Calendar shows 12 months range from current base date)
        // selected date (marked dated in the calendar)
        let calendarView = CalendarView.instance(date, selectedDate: date)
        calendarView.delegate = self
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(calendarView)
        
        // Constraints for calendar view - Fill the parent view.
        placeholderView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[calendarView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["calendarView": calendarView]))
        placeholderView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[calendarView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["calendarView": calendarView]))
        
        displayRecordButton.layer.cornerRadius = 5
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didSelectDate(date: NSDate) {
        PhysiologicalVariablesStoredInDatabaseSQL.dateSelectedByTheUser =  "\(date.year)-\(date.month)-\(date.day)"
        print(PhysiologicalVariablesStoredInDatabaseSQL.dateSelectedByTheUser)
    }
    
    
    // MARK: - Buttons
    
    @IBAction func displayRecordButton(sender: AnyObject) {
        
        getDataFromServerDataBaseSQL(PhysiologicalVariablesStoredInDatabaseSQL.dateSelectedByTheUser!)
        
    }
    
    /**
     Get data from data base SQL where date is selected by the user with the calendar
     */
    func getDataFromServerDataBaseSQL(date: String){
        
        let postString = "date=\(date)"
        
        requestGetDataBaseSQL.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        requestGetDataBaseSQL.HTTPMethod = "POST"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(requestGetDataBaseSQL) {
            data, response, error in
            
            if error != nil {
                
                self.dismissViewControllerAnimated(true, completion:  {
                    internetConnectionError = true
                    NSNotificationCenter.defaultCenter().postNotificationName("displayAlertThereIsNoDataNotification", object: nil, userInfo: nil)
                    
                    })
                
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    print("iPad")
                case .iPhone:
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertController(title: NSLocalizedString("Connection fail", comment: ""), message: NSLocalizedString("Check your internet connection", comment: ""), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .Default) { _ in })
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                    
                }
                
                print("no hay datos en la base de datos1")
                print("error=\(error)")
                return
            }
            
            self.responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            
            if (String(self.responseString).isEmpty || self.responseString == "s-d-a-f-h"){
                
                self.dismissViewControllerAnimated(true, completion:  {
                    internetConnectionError = false
                    NSNotificationCenter.defaultCenter().postNotificationName("displayAlertThereIsNoDataNotification", object: nil, userInfo: nil)
                            
                        
                    
                })
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    print("iPad")
                case .iPhone:
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertController(title: NSLocalizedString("Connection fail", comment: ""), message: NSLocalizedString("There is not data", comment: ""), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .Default) { _ in })
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                    
                }
                print("no hay datos en la base de datos2")
                
            }else{
                
                //print("responseStringXX = \(self.responseString)")
                PhysiologicalVariablesStoredInDatabaseSQL.systolicPressure.removeAll()
                PhysiologicalVariablesStoredInDatabaseSQL.diastolicPressure.removeAll()
                PhysiologicalVariablesStoredInDatabaseSQL.averagePressure.removeAll()
                PhysiologicalVariablesStoredInDatabaseSQL.heartRate.removeAll()
                PhysiologicalVariablesStoredInDatabaseSQL.hour.removeAll()
                
                let vector = self.responseString.componentsSeparatedByString("-")
                print(vector.count)
                for i in 0..<vector.count{
                    var vector1 = vector[i].componentsSeparatedByString(",")
                    
                    for j in 0...(vector1.count - 1){
                        
                        if i == 0 && vector1[j] != "s"{
                            PhysiologicalVariablesStoredInDatabaseSQL.systolicPressure.append(Double(vector1[j])!)
                        }
                        if i == 1 && vector1[j] != "d"{
                            PhysiologicalVariablesStoredInDatabaseSQL.diastolicPressure.append(Double(vector1[j])!)
                        }
                        if i == 2 && vector1[j] != "a"{
                            PhysiologicalVariablesStoredInDatabaseSQL.averagePressure.append(Double(vector1[j])!)
                        }
                        if i == 3 && vector1[j] != "f"{
                            PhysiologicalVariablesStoredInDatabaseSQL.heartRate.append(Double(vector1[j])!)
                        }
                        if i == 4 && vector1[j] != "h"{
                            PhysiologicalVariablesStoredInDatabaseSQL.hour.append(String(UTF8String: vector1[j])!)
                        }
                    }
                }
                if PhysiologicalVariablesStoredInDatabaseSQL.systolicPressure.count > 80{
                    for _ in 0..<(PhysiologicalVariablesStoredInDatabaseSQL.systolicPressure.count - 75){
                        PhysiologicalVariablesStoredInDatabaseSQL.systolicPressure.removeAtIndex(0)
                        PhysiologicalVariablesStoredInDatabaseSQL.diastolicPressure.removeAtIndex(0)
                        PhysiologicalVariablesStoredInDatabaseSQL.averagePressure.removeAtIndex(0)
                        PhysiologicalVariablesStoredInDatabaseSQL.heartRate.removeAtIndex(0)
                        PhysiologicalVariablesStoredInDatabaseSQL.hour.removeAtIndex(0)
                        
                    }
                }
                
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    userSelectViewController = UserSelectViewPrincipalViewController.hitorialViewController
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("displaySavedHistoryGraphsNotification", object: nil, userInfo: nil)
                case .iPhone:
                    userSelectViewController = UserSelectViewPrincipalViewController.hitorialViewController
                    
                    dispatch_async(dispatch_get_main_queue(), {
                    let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("savedHistoryGraphs")
                        self.showViewController(popoverContent!, sender: nil)
                    })
                    //self.navigationController?.pushViewController(popoverContent!, animated: true)
                    //self.navigationController?.presentViewController(popoverContent!, animated: true, completion: nil)
                    //self.presentViewController(popoverContent!, animated: true, completion: nil)
                    
                }
                
            }
        }
        task.resume()
    }

}
