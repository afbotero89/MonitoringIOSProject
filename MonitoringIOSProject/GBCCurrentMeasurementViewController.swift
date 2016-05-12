//
//  GBCCurrentMeasurementViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 3/5/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

class GBCCurrentMeasurementViewController: UIViewController {

    
    @IBOutlet weak var systolicPressureValue: UILabel!
    
    @IBOutlet weak var diastolicPressureValue: UILabel!
    
    @IBOutlet weak var averagePressureValue: UILabel!
    
    @IBOutlet weak var heartRateValue: UILabel!
    
    @IBOutlet weak var BatteryLevel: UILabel!
    
    var systolicPressureString:String?
    
    var diastolicPressureString:String?
    
    var averagePressureString:String?
    
    var heartRatePressureString:String?
    
    var batteryLevelString:String?
    
    @IBOutlet weak var cancelButtonLayer: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButtonLayer.layer.cornerRadius = 10
        
        if systolicPressureString != nil && diastolicPressureValue != nil && averagePressureString != nil && heartRatePressureString != nil && batteryLevelString != nil{
        
            systolicPressureValue.text = systolicPressureString
            diastolicPressureValue.text = diastolicPressureString
            averagePressureValue.text = averagePressureString
            heartRateValue.text = heartRatePressureString
            BatteryLevel.text = batteryLevelString
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelCurrentMeasurement(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("cancelCurrentMeasurementToPeripheral", object: nil, userInfo: nil)
        activeCurrentMeasurementFlag = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
