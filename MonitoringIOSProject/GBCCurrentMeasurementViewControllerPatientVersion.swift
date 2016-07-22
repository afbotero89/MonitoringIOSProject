//
//  GBCCurrentMeasurementViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 3/5/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

class GBCCurrentMeasurementViewControllerPatientVersion: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var doneButtonIphone: UIButton!
    
    @IBOutlet weak var systolicPressureValue: UILabel!
    
    @IBOutlet weak var diastolicPressureValue: UILabel!
    
    @IBOutlet weak var averagePressureValue: UILabel!
    
    @IBOutlet weak var heartRateValue: UILabel!
    
    @IBOutlet weak var BatteryLevel: UILabel!
    
    @IBOutlet weak var batteryLevelImage: UIImageView!
    
    // Titles
    @IBOutlet weak var systolicPressureTitleLabel: UILabel!
    
    @IBOutlet weak var averagePressureTitleLabel: UILabel!
    
    @IBOutlet weak var diastolicPressureTitleLabel: UILabel!
    
    @IBOutlet weak var heartRateTitleLabel: UILabel!
    
    @IBOutlet weak var batteryLevelTitleLabel: UILabel!
    
    var systolicPressureString:String!
    
    var diastolicPressureString:String!
    
    var averagePressureString:String!
    
    var heartRatePressureString:String!
    
    var batteryLevelString:String!
    
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Current measure", comment: "")
        
        let device = UIDevice.currentDevice().model
        
        if device == "iPad"{
            UserSelectedConfiguration.typeOfDevice = .iPad
        }else{
            UserSelectedConfiguration.typeOfDevice = .iPhone
        }
        
        systolicPressureTitleLabel.text = NSLocalizedString("Systolic pressure", comment: "")
        diastolicPressureTitleLabel.text = NSLocalizedString("Diastolic pressure", comment: "")
        averagePressureTitleLabel.text = NSLocalizedString("Average pressure", comment: "")
        heartRateTitleLabel.text = NSLocalizedString("Heart Rate", comment: "")
        batteryLevelTitleLabel.text = NSLocalizedString("Battery Level", comment: "")
        
        if systolicPressureString != nil && diastolicPressureValue != nil && averagePressureString != nil && heartRatePressureString != nil && batteryLevelString != nil{
        
            systolicPressureValue.text = systolicPressureString!
            diastolicPressureValue.text = diastolicPressureString!
            averagePressureValue.text = averagePressureString!
            heartRateValue.text = heartRatePressureString!
            //BatteryLevel.text = batteryLevelString!
        }
        
        batteryLevel()
        
        addAttributesToViewController()
        
        addNotifications()
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(GBCCurrentMeasurementViewControllerPatientVersion.displaySavedHistoryGraphs),
                                                         
                                                         name: "displaySavedHistoryGraphsNotificationPatientVersion",
                                                         
                                                         object: nil)
    }
    
    func addAttributesToViewController(){
        //UserSelectedConfiguration.typeOfDevice = .iPhone
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            print("iPhone")
        case .iPhone:
            switch appVersion!{
            case .adminVersion:
                doneButtonIphone.clipsToBounds = true
                doneButtonIphone.layer.cornerRadius = 10
                doneButtonIphone.setTitle(NSLocalizedString("Done", comment: ""), forState: .Normal)
            case .patientVersion:
                print("patient version iphone")
            }
            
        }

        
        let color1 = UIColor.whiteColor().CGColor
        
        let color2 = UIColor(red: 0/255, green: 64/255, blue: 128/255, alpha: 0.2).CGColor
        
        gradientLayer.colors = [color1, color2]
        
        gradientLayer.locations = [0.2, 1]
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        
        gradientLayer.accessibilityElementAtIndex(0)
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 64/255, blue: 128/255, alpha: 1.0)
        
        view.layer.insertSublayer(gradientLayer, atIndex:0)
    }
    
    func batteryLevel(){
        if VectorPhysiologicalVariables.batteryLevel.last != nil{
            BatteryLevel.text = String(VectorPhysiologicalVariables.batteryLevel.last!) + " %"
        }else{
            BatteryLevel.text = NSLocalizedString("Device disconnected", comment: "") + " %"
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
            batteryLevelImage.image = UIImage(named: "BatteryLevel10")
            BatteryLevel.text = "100" + " %"
            
        }
    }

    @IBAction func displayCalendarButton(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            
            let documentationTableViewController = storyboard.instantiateViewControllerWithIdentifier("calendarViewControllerIPad")
            documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover = documentationTableViewController.popoverPresentationController!
            documentationTableViewController.preferredContentSize = CGSizeMake(400,350)
            
            popover.permittedArrowDirections = .Any
            
            // Depending on the source, set the popover properties accordingly.
            if let barButtonItem = sender as? UIBarButtonItem{
                popover.barButtonItem = barButtonItem
            } else if let view = sender as? UIView{
                popover.sourceView = view
                popover.sourceRect = view.bounds
                
            }
            
            popover.delegate = self
            //NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentTimeToPeripheral", object: nil, userInfo: nil)
            
            self.presentViewController(documentationTableViewController, animated: true, completion: nil)
            
        case .iPhone:
            
            let documentationTableViewController = storyboard.instantiateViewControllerWithIdentifier("calendarViewControllerIPhone")
            
            //NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentTimeToPeripheral", object: nil, userInfo: nil)
            navigationController?.pushViewController(documentationTableViewController, animated: true)
        }
        
    }
    
    func displaySavedHistoryGraphs(){
        
        let popoverContent = (self.storyboard?.instantiateViewControllerWithIdentifier("savedHistoryGraphs"))
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            /*
             let nav:UINavigationController?
             nav = UINavigationController(rootViewController: popoverContent!)
             nav!.modalPresentationStyle = UIModalPresentationStyle.Popover
             let popover = nav!.popoverPresentationController
             popoverContent!.preferredContentSize = CGSizeMake(self.view.frame.width,600)
             popover!.delegate = self
             popover!.sourceView = self.view
             popover!.sourceRect = CGRectMake(100,100,0,0)
             
             self.presentViewController(nav!, animated: true, completion: nil)
             */
            navigationController?.pushViewController(popoverContent!, animated: true)
        case .iPhone:
            
            navigationController?.pushViewController(popoverContent!, animated: true)
        }
        
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        print("done")
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
