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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButtonLayer.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doneButton(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("writeValueToPeripheral", object: nil, userInfo: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
