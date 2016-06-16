//
//  AditionalInformationPopupViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 4/5/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

class GBCAditionalInformationPopupViewController: UIViewController {
    
    
    @IBOutlet weak var systolicPressureTitleLabel: UILabel!
    
    @IBOutlet weak var averagePressureTitleLabel: UILabel!
    
    @IBOutlet weak var diastolicPressureTitleLabel: UILabel!
    
    @IBOutlet weak var heartRateTitleLabel: UILabel!
    
    @IBOutlet weak var measurementTimeTitleLabel: UILabel!
    
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
        
        systolicPressureTitleLabel.text = NSLocalizedString("Systolic pressure", comment: "")
        diastolicPressureTitleLabel.text = NSLocalizedString("Diastolic pressure", comment: "")
        averagePressureTitleLabel.text = NSLocalizedString("Average pressure", comment: "")
        heartRateTitleLabel.text = NSLocalizedString("Heart Rate", comment: "")
        measurementTimeTitleLabel.text = NSLocalizedString("Measurement time", comment: "")
        
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
