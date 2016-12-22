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
    
    var requestGetDataBaseSQL = URLRequest(url: URL(string:"http://www.testgibic.com/app_pressure_monitor/querysToDatabaseGetDataForDate.php")!)
    
    var responseString:String!
    
    var activeCalendarViewController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // todays date.
        let date = Foundation.Date()
        
        title = NSLocalizedString("Calendar", comment: "")
        
        //displayRecordButton.setTitle(NSLocalizedString("Display", comment: ""), forState: .Normal)
        // create an instance of calendar view with
        // base date (Calendar shows 12 months range from current base date)
        // selected date (marked dated in the calendar)
        let calendarView = CalendarView.instance(date, selectedDate: date)
        calendarView.delegate = self
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(calendarView)
        
        // Constraints for calendar view - Fill the parent view.
        placeholderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[calendarView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["calendarView": calendarView]))
        placeholderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[calendarView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["calendarView": calendarView]))
        
        //displayRecordButton.layer.cornerRadius = 5
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didSelectDate(_ date: Foundation.Date) {
        PhysiologicalVariablesStoredInDatabaseSQL.dateSelectedByTheUser =  "\(date.year)-\(date.month)-\(date.day)"
        
        if activeCalendarViewController == true{
            getDataFromServerDataBaseSQL(PhysiologicalVariablesStoredInDatabaseSQL.dateSelectedByTheUser!)
        }
        activeCalendarViewController = true
    }
    
    
    // MARK: - Buttons
    
    @IBAction func displayRecordButton(_ sender: AnyObject) {

        //getDataFromServerDataBaseSQL(PhysiologicalVariablesStoredInDatabaseSQL.dateSelectedByTheUser!)
        
    }
    
    /**
     Get data from data base SQL where date is selected by the user with the calendar
     */
    func getDataFromServerDataBaseSQL(_ date: String){
        
        let postString = "date=\(date)"
        
        requestGetDataBaseSQL.httpBody = postString.data(using: String.Encoding.utf8)
        
        requestGetDataBaseSQL.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: requestGetDataBaseSQL as URLRequest, completionHandler: {
            data, response, error in
            
            if error != nil {
                
                self.dismiss(animated: true, completion:  {
                    internetConnectionError = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "displayAlertThereIsNoDataNotification"), object: nil, userInfo: nil)
                    
                    })
                
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    print("iPad")
                case .iPhone:
                    
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: NSLocalizedString("Connection fail", comment: ""), message: NSLocalizedString("Check your internet connection", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default) { _ in })
                        self.present(alert, animated: true, completion: nil)
                    })
                    
                }
                
                print("no hay datos en la base de datos1")
                print("error=\(error)")
                return
            }
            
            self.responseString = String(data: data!, encoding: .utf8)
            print(self.responseString)
            
            if (String(self.responseString).isEmpty){
                internetConnectionError = false
                self.dismiss(animated: true, completion:  {
                    internetConnectionError = false
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "displayAlertThereIsNoDataNotification"), object: nil, userInfo: nil)
                    
                })
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    print("iPad")
                case .iPhone:
                    
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: NSLocalizedString("Connection fail", comment: ""), message: NSLocalizedString("There is not data", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default) { _ in })
                        self.present(alert, animated: true, completion: nil)
                    })
                    
                }
                print("no hay datos en la base de datos2")
                
            }else{
                
                PhysiologicalVariablesStoredInDatabaseSQL.systolicPressure.removeAll()
                PhysiologicalVariablesStoredInDatabaseSQL.diastolicPressure.removeAll()
                PhysiologicalVariablesStoredInDatabaseSQL.averagePressure.removeAll()
                PhysiologicalVariablesStoredInDatabaseSQL.heartRate.removeAll()
                PhysiologicalVariablesStoredInDatabaseSQL.hour.removeAll()
                
                let vector = self.responseString.components(separatedBy: ";")
                
                for i in 0..<(vector.count-1){
                    var vector1 = vector[i].components(separatedBy: ",")
                    
                    PhysiologicalVariablesStoredInDatabaseSQL.averagePressure.append(Double(vector1[4])!)

                    PhysiologicalVariablesStoredInDatabaseSQL.systolicPressure.append(Double(vector1[5])!)
                    
                    PhysiologicalVariablesStoredInDatabaseSQL.diastolicPressure.append(Double(vector1[6])!)
                    
                    PhysiologicalVariablesStoredInDatabaseSQL.heartRate.append(Double(vector1[7])!)

                    PhysiologicalVariablesStoredInDatabaseSQL.hour.append(String(validatingUTF8: vector1[8])!)
                    
                }
                if PhysiologicalVariablesStoredInDatabaseSQL.systolicPressure.count > 80{
                    for _ in 0..<(PhysiologicalVariablesStoredInDatabaseSQL.systolicPressure.count - 75){
                        PhysiologicalVariablesStoredInDatabaseSQL.systolicPressure.remove(at: 0)
                        PhysiologicalVariablesStoredInDatabaseSQL.diastolicPressure.remove(at: 0)
                        PhysiologicalVariablesStoredInDatabaseSQL.averagePressure.remove(at: 0)
                        PhysiologicalVariablesStoredInDatabaseSQL.heartRate.remove(at: 0)
                        PhysiologicalVariablesStoredInDatabaseSQL.hour.remove(at: 0)
                        
                    }
                }
                
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    self.dismiss(animated: true, completion: nil)
                    
                    userSelectViewController = UserSelectViewPrincipalViewController.hitorialViewController
                    
                    switch appVersion!{
                    case .patientVersion:
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displaySavedHistoryGraphsNotificationPatientVersion"), object: nil, userInfo: nil)
                    case .adminVersion:
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displaySavedHistoryGraphsNotification"), object: nil, userInfo: nil)
                    }
                    
                case .iPhone:
                    userSelectViewController = UserSelectViewPrincipalViewController.hitorialViewController
                    
                    DispatchQueue.main.async(execute: {
                    let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "savedHistoryGraphs")
                        self.show(popoverContent!, sender: nil)
                    })
                    //self.navigationController?.pushViewController(popoverContent!, animated: true)
                    //self.navigationController?.presentViewController(popoverContent!, animated: true, completion: nil)
                    //self.presentViewController(popoverContent!, animated: true, completion: nil)
                    
                }
                
            }
        }) 
        task.resume()
    }

}
