//
//  GBCCurrentMeasurementViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 3/5/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


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
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var systolicPressureString:String!
    
    var diastolicPressureString:String!
    
    var averagePressureString:String!
    
    var heartRatePressureString:String!
    
    var batteryLevelString:String!
    
    let gradientLayer = CAGradientLayer()
    
    /// Bluetooth manager
    var bluetoothManager:BluetoothManager!
    
    /// Request to remote data base sql: Type post to GIBIC server
    let uploadMeassuresToRemoteServer = GBCUploadMeassuresAndSignalsToRemoteServer()
    
    @IBOutlet weak var imageStatusConnection: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Current measure", comment: "")
        
        // Initialize the bluetooth manager.
        self.bluetoothManager = BluetoothManager()
        
        let device = UIDevice.current.model
        
        if device == "iPad"{
            UserSelectedConfiguration.typeOfDevice = .iPad
        }else{
            UserSelectedConfiguration.typeOfDevice = .iPhone
        }
        
        systolicPressureTitleLabel.text = NSLocalizedString("Systolic pressure", comment: "")
        diastolicPressureTitleLabel.text = NSLocalizedString("Diastolic pressure", comment: "")
        averagePressureTitleLabel.text = NSLocalizedString("Average pressure", comment: "")
        heartRateTitleLabel.text = NSLocalizedString("Heart Rate", comment: "")
        
        
        if systolicPressureString != nil && diastolicPressureValue != nil && averagePressureString != nil && heartRatePressureString != nil && batteryLevelString != nil{
        
            systolicPressureValue.text = systolicPressureString! + "mmHg"
            diastolicPressureValue.text = diastolicPressureString! + "mmHg"
            averagePressureValue.text = averagePressureString! + "mmHg"
            heartRateValue.text = heartRatePressureString! + "BPM"
            //BatteryLevel.text = batteryLevelString!
        }
        
        batteryLevel()
        
        addAttributesToViewController()
        
        addNotifications()
        
        uploadMeassuresToRemoteServer.getDataFromDataBaseSQLDayMonthYear()
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNotifications(){
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(GBCCurrentMeasurementViewControllerPatientVersion.displaySavedHistoryGraphs),
                                                         
                                                         name: NSNotification.Name(rawValue: "displaySavedHistoryGraphsNotificationPatientVersion"),
                                                         
                                                         object: nil)
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(GBCCurrentMeasurementViewControllerPatientVersion.displayMeasure),
                                                         
                                                         name: NSNotification.Name(rawValue: "displayMeasurePatientViewController"),
                                                         
                                                         object: nil)
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(ViewController.displayErrorMessageMainView),
                                                         
                                                         name: NSNotification.Name(rawValue: "displayErrorMessageMainViewNotificationPatientVersion"),
                                                         
                                                         object: nil)
        
        // Watch Bluetooth connection
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
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
                doneButtonIphone.setTitle(NSLocalizedString("Done", comment: ""), for: UIControlState())
            case .patientVersion:
                print("patient version iphone")
            }
            
        }
        navigationBar.barTintColor = UIColor(red: 0/255, green: 64/255, blue: 128/255, alpha: 1)
        
        let color1 = UIColor.white.cgColor
        
        let color2 = UIColor(red: 0/255, green: 64/255, blue: 128/255, alpha: 0.2).cgColor
        
        gradientLayer.colors = [color1, color2]
        
        gradientLayer.locations = [0.2, 1]
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        
        gradientLayer.accessibilityElement(at: 0)
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 64/255, blue: 128/255, alpha: 1.0)
        
        view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func batteryLevel(){
        if VectorPhysiologicalVariables.batteryLevel.last != nil{
            batteryLevelTitleLabel.text = String(VectorPhysiologicalVariables.batteryLevel.last!) + " %"
        }else{
            batteryLevelTitleLabel.text = NSLocalizedString("Device disconnected", comment: "") + " %"
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
            batteryLevelTitleLabel.text = "100" + " %"
            
        }
    }

    @IBAction func displayCalendarButton(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            
            let documentationTableViewController = storyboard.instantiateViewController(withIdentifier: "calendarViewControllerIPad")
            documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = documentationTableViewController.popoverPresentationController!
            documentationTableViewController.preferredContentSize = CGSize(width: 400,height: 350)
            
            popover.permittedArrowDirections = .any
            
            // Depending on the source, set the popover properties accordingly.
            if let barButtonItem = sender as? UIBarButtonItem{
                popover.barButtonItem = barButtonItem
            } else if let view = sender as? UIView{
                popover.sourceView = view
                popover.sourceRect = view.bounds
                
            }
            
            popover.delegate = self
            //NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentTimeToPeripheral", object: nil, userInfo: nil)
            
            self.present(documentationTableViewController, animated: true, completion: nil)
            
        case .iPhone:
            
            let documentationTableViewController = storyboard.instantiateViewController(withIdentifier: "calendarViewControllerIPhone")
            
            //NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentTimeToPeripheral", object: nil, userInfo: nil)
            navigationController?.pushViewController(documentationTableViewController, animated: true)
        }
        
    }
    
    func displayMeasure(){
        
        systolicPressureValue.text = String(VectorPhysiologicalVariables.systolicPressure.last!) + "mmHg"
        averagePressureValue.text = String(VectorPhysiologicalVariables.averagePressure.last!) + "mmHg"
        diastolicPressureValue.text = String(VectorPhysiologicalVariables.diastolicPressure.last!) + "mmHg"
        heartRateValue.text = String(VectorPhysiologicalVariables.heartRate.last!)  + "BPM"
        
        
        uploadMeassuresToRemoteServer.uploadToServerDataBaseSQL_GIBIC(VectorPhysiologicalVariables.systolicPressure.last!, diastolicPressure: VectorPhysiologicalVariables.diastolicPressure.last!, mediumPressure: VectorPhysiologicalVariables.averagePressure.last!, heartRate: VectorPhysiologicalVariables.heartRate.last!, hour: "12:22:22")
        batteryLevel()
    }
    
    func connectionChanged(_ notification: Notification) {
        
        // Connection status changed. Indicate on GUI.
        let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
        
        DispatchQueue.main.async(execute: {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    self.imageStatusConnection.image = UIImage(named: "Bluetooth_Connected")
                    DeviceVariables.bluetoothConnected = true
                    
                    
                } else {
                    self.imageStatusConnection.image = UIImage(named: "Bluetooth_Disconnected")
                    DeviceVariables.bluetoothConnected = false
                    
                }
            }
        });
    }
    
    func displayErrorMessageMainView(){
        activeCurrentMeasurementFlag = false
        let alertController:UIAlertController?
        
        switch typeError!{
        case 1:
            // Desconexion de manguera
            alertController = UIAlertController(title: "", message: NSLocalizedString("Disconnect hose", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        case 2:
            alertController = UIAlertController(title: "", message: NSLocalizedString("Circuit leaks", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        case 3:
            alertController = UIAlertController(title: "", message: NSLocalizedString("Incorrect pressure", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        case 4:
            alertController = UIAlertController(title: "", message: NSLocalizedString("Monitor measure canceled", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        case 5:
            alertController = UIAlertController(title: "", message: NSLocalizedString("heart rate not caculated", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        case 6:
            alertController = UIAlertController(title: "", message: NSLocalizedString("Incorrect pressure", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        case 7:
            alertController = UIAlertController(title: "", message: NSLocalizedString("Incorrect measure", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        default:
            alertController = UIAlertController(title: "", message: "Default principal view", preferredStyle:UIAlertControllerStyle.alert)
        }
        
        alertController!.addAction(UIAlertAction(title:  NSLocalizedString("Done", comment: ""), style: .default, handler: {
            action in
            
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                self.dismiss(animated: true, completion: nil)
            case .iPhone:
                _ = self.navigationController?.popViewController(animated: true)
            }
            
        }))
        self.present(alertController!, animated: true, completion: nil)
        
    }
    
    func displaySavedHistoryGraphs(){
        
        let popoverContent = (self.storyboard?.instantiateViewController(withIdentifier: "savedHistoryGraphs"))
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            navigationController?.pushViewController(popoverContent!, animated: true)
        case .iPhone:
            
            navigationController?.pushViewController(popoverContent!, animated: true)
        }
        
    }
    
    @IBAction func doneButton(_ sender: AnyObject) {
        print("done")
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
