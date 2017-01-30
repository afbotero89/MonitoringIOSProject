//
//  GBCPatientHistoryViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 30/1/17.
//  Copyright © 2017 FING156561. All rights reserved.
//

import UIKit

class GBCPatientHistoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("patient history")
        
        displayCalendar()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func displayCalendar() {
        
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "sendUserDocumentToMonitorNotification"), object: nil, userInfo: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let documentationTableViewController = storyboard.instantiateViewController(withIdentifier: "calendarViewControllerIPad")
            
        navigationController?.show(documentationTableViewController, sender: nil)
            
    }

}
