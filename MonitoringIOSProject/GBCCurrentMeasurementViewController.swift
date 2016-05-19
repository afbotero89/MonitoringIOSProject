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
    
    @IBOutlet weak var batteryLevelImage: UIImageView!
    
    var systolicPressureString:String!
    
    var diastolicPressureString:String!
    
    var averagePressureString:String!
    
    var heartRatePressureString:String!
    
    var batteryLevelString:String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if systolicPressureString != nil && diastolicPressureValue != nil && averagePressureString != nil && heartRatePressureString != nil && batteryLevelString != nil{
        
            systolicPressureValue.text = systolicPressureString!
            diastolicPressureValue.text = diastolicPressureString!
            averagePressureValue.text = averagePressureString!
            heartRateValue.text = heartRatePressureString!
            //BatteryLevel.text = batteryLevelString!
        }
        
        batteryLevel()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func batteryLevel(){
        if VectorPhysiologicalVariables.batteryLevel.last != nil{
            BatteryLevel.text = String(VectorPhysiologicalVariables.batteryLevel.last!) + " %"
        }else{
            BatteryLevel.text = "Device disconnected" + " %"
        }
        //BatteryLevel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        
        // Battery level 0%
        if VectorPhysiologicalVariables.batteryLevel.last == 0 {
            batteryLevelImage.image = UIImage(named: "BatteryLevel0")
            
            // Battery level 1%-10%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 0 && VectorPhysiologicalVariables.batteryLevel.last <= 10){
            batteryLevelImage.image = UIImage(named: "BatteryLevel1")
            
            // Battery level 11%-20%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 10 && VectorPhysiologicalVariables.batteryLevel.last <= 20){
            batteryLevelImage.image = UIImage(named: "BatteryLevel2")
            
            // Battery level 21%-30%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 20 && VectorPhysiologicalVariables.batteryLevel.last <= 30){
            batteryLevelImage.image = UIImage(named: "BatteryLevel3")
            
            // Battery level 31%-40%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 30 && VectorPhysiologicalVariables.batteryLevel.last <= 40){
            batteryLevelImage.image = UIImage(named: "BatteryLevel4")
            
            // Battery level 41%-50%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 40 && VectorPhysiologicalVariables.batteryLevel.last <= 50){
            batteryLevelImage.image = UIImage(named: "BatteryLevel5")
            
            // Battery level 51%-60%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 50 && VectorPhysiologicalVariables.batteryLevel.last <= 60){
            batteryLevelImage.image = UIImage(named: "BatteryLevel6")
            
            // Battery level 61%-70%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 60 && VectorPhysiologicalVariables.batteryLevel.last <= 70){
            batteryLevelImage.image = UIImage(named: "BatteryLevel7")
            
            // Battery level 71%-80%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 70 && VectorPhysiologicalVariables.batteryLevel.last <= 80){
            batteryLevelImage.image = UIImage(named: "BatteryLevel8")
            
            // Battery level 81%-90%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 80 && VectorPhysiologicalVariables.batteryLevel.last <= 90){
            batteryLevelImage.image = UIImage(named: "BatteryLevel9")
            
            // Battery level 91%-100
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 90 && VectorPhysiologicalVariables.batteryLevel.last <= 100){
            batteryLevelImage.image = UIImage(named: "BatteryLevel10")
            
            // Battery level default
        }else{
            batteryLevelImage.image = UIImage(named: "BatteryCharging")
            BatteryLevel.text = "Battery charging"
            
        }
    }

}
