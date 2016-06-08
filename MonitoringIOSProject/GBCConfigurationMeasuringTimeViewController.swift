//
//  GBCConfigurationMeasuringTimeViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 12/5/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

class GBCConfigurationMeasuringTimeViewController: UIViewController {

    
    @IBOutlet weak var doneButtonLayer: UIButton!
    
    @IBOutlet weak var adjustMeasuringTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("User configuration", comment: "") 
        
        doneButtonLayer.setTitle(NSLocalizedString("Done", comment: ""), forState: .Normal)
        
        adjustMeasuringTimeLabel.text = NSLocalizedString("Adjust measurement time", comment: "")
        
        doneButtonLayer.layer.cornerRadius = 5
        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 64/255, blue: 128/255, alpha: 1.0)
    }

    @IBAction func doneButton(sender: AnyObject) {
        print(UserSelectedConfiguration.userSelectMeasurementTime)
        
        NSNotificationCenter.defaultCenter().postNotificationName("sendMeasurementTimeToPeripheral", object: nil, userInfo: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
