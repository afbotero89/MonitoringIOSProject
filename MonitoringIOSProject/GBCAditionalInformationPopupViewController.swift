//
//  AditionalInformationPopupViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 4/5/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

class GBCAditionalInformationPopupViewController: UIViewController {
    
    @IBOutlet weak var valueSystolicPressure: UILabel!
    
    @IBOutlet weak var valueAveragePressure: UILabel!
    
    @IBOutlet weak var valueDiastolicPressure: UILabel!
    
    @IBOutlet weak var valueHeartRate: UILabel!
    
    @IBOutlet weak var measuringTime: UILabel!
    
    var valueSystolicPressureString:String?
    
    var valueAveragePressureString:String?
    
    var valueDiastolicPressureString:String?
    
    var valueHeartRateString:String?
    
    var measuringTimeString:String?
    
    var unitsString:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        valueSystolicPressure.text = valueSystolicPressureString
        valueAveragePressure.text = valueAveragePressureString
        valueDiastolicPressure.text = valueDiastolicPressureString
        valueHeartRate.text = valueHeartRateString
        measuringTime.text = measuringTimeString
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
