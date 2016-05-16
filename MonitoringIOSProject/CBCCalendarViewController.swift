//
//  CBCCalendarViewController.swift
//  MonitoringIOSProject
//
//  Created by Felipe Botero on 14/05/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

class CBCCalendarViewController: UIViewController, CalendarViewDelegate {

    @IBOutlet var placeholderView: UIView!
    
    @IBOutlet weak var displayRecordButton: UIButton!
    
    var dateSelectedByTheUser:String?
    
    let requestGetDataBaseSQL = NSMutableURLRequest(URL: NSURL(string:"http://www.sibxe.co/appMonitoreo/querysToDatabaseGetData.php")!)
    
    var responseString:NSString!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // todays date.
        let date = NSDate()
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didSelectDate(date: NSDate) {
        dateSelectedByTheUser =  "\(date.year)-\(date.month)-\(date.day)"
        print(dateSelectedByTheUser)
    }
    
    
    // MARK: - Buttons
    
    @IBAction func displayRecordButton(sender: AnyObject) {
        
        getDataFromServerDataBaseSQL(dateSelectedByTheUser!)
        

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
                print("error=\(error)")
                return
            }
            
            self.responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            
            if (String(self.responseString).isEmpty){
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
                NSNotificationCenter.defaultCenter().postNotificationName("displayAlertThereIsNoDataNotification", object: nil, userInfo: nil)
                
                print("no hay datos en la base de datos")
                
            }else{
                
                print("responseString = \(self.responseString)")
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
                NSNotificationCenter.defaultCenter().postNotificationName("displaySavedHistoryGraphsNotification", object: nil, userInfo: nil)
            }
        }
        task.resume()
    }

}
