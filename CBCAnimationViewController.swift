//
//  CBCAnimationViewController.swift
//  MonitoringIOSProject
//
//  Created by Felipe Botero on 5/06/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

class CBCAnimationViewController: UIViewController {

    
    @IBOutlet var currentView: GBCAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Measuring", comment: "") + "...."
        
        // Do any additional setup after loading the view.
        // An array with the name of the frames composing the animation
        let names = GBCAnimationView.array(withNumberedNames: "AnimCurva1920x1080V1.", rangeStart: 0, rangeEnd: 119, suffixFormat: "%05i.jpg")
        let urls =  GBCAnimationView.array(withResourcePrefixedURLs: names)
        
        self.currentView.setAnimationWithAnimationURLs(urls, animationFrameDuration: 0.5, animationRepeatCount: 30)
        
        self.currentView.startAnimating()
        
        addNotifications()
        
        userSelectViewController = UserSelectViewPrincipalViewController.animationViewController
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if (self.isViewLoaded && self.view.window == nil){
            
            userSelectViewController = UserSelectViewPrincipalViewController.realTimeViewController
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "displayCurrentMeasurementPopoverNotification"), object: nil)
            currentView.stopAnimating()
            self.currentView = nil
            self.view = nil
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        
        // Remove this object from any notification of notification center.
        //NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func addNotifications(){
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(CBCAnimationViewController.displayCurrentMeasurementPopover),
                                                         
                                                         name: NSNotification.Name(rawValue: "displayCurrentMeasurementPopoverNotification"),
                                                         
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(CBCAnimationViewController.displayErrorMessage),
                                                         
                                                         name: NSNotification.Name(rawValue: "displayErrorMessage"),
                                                         
                                                         object: nil)
        
    }
    
    func displayCurrentMeasurementPopover(){
        activeCurrentMeasurementFlag = false
        let popoverContent = (self.storyboard?.instantiateViewController(withIdentifier: "currentMeasurement"))! as! GBCCurrentMeasurementViewController
        
        if VectorPhysiologicalVariables.systolicPressure.last != nil && VectorPhysiologicalVariables.averagePressure.last != nil && VectorPhysiologicalVariables.diastolicPressure.last != nil && VectorPhysiologicalVariables.heartRate.last != nil && VectorPhysiologicalVariables.batteryLevel.last != nil{
            
            if VectorPhysiologicalVariables.diastolicPressure.last! > VectorPhysiologicalVariables.averagePressure.last!{
                
                popoverContent.systolicPressureString = String(VectorPhysiologicalVariables.systolicPressure.last!) + " mmHg"
                popoverContent.diastolicPressureString = String(VectorPhysiologicalVariables.averagePressure.last!) + " mmHg"
                popoverContent.averagePressureString = String(VectorPhysiologicalVariables.diastolicPressure.last!) + " mmHg"
                popoverContent.heartRatePressureString = String(VectorPhysiologicalVariables.heartRate.last!) + " BPM"
                popoverContent.batteryLevelString = String(VectorPhysiologicalVariables.batteryLevel.last!) + " %"
            
            }else{
                popoverContent.systolicPressureString = String(VectorPhysiologicalVariables.systolicPressure.last!) + " mmHg"
                popoverContent.diastolicPressureString = String(VectorPhysiologicalVariables.diastolicPressure.last!) + " mmHg"
                popoverContent.averagePressureString = String(VectorPhysiologicalVariables.averagePressure.last!) + " mmHg"
                popoverContent.heartRatePressureString = String(VectorPhysiologicalVariables.heartRate.last!) + " BPM"
                popoverContent.batteryLevelString = String(VectorPhysiologicalVariables.batteryLevel.last!) + " %"
            }
            
            
        }
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            currentView.stopAnimating()
            navigationController?.pushViewController(popoverContent, animated: true)
            
        case .iPhone:
            currentView.stopAnimating()
            let popoverContentIPhone = (self.storyboard?.instantiateViewController(withIdentifier: "currentMeasurementiPhone"))! as! GBCCurrentMeasurementViewController
            if VectorPhysiologicalVariables.systolicPressure.last != nil && VectorPhysiologicalVariables.averagePressure.last != nil && VectorPhysiologicalVariables.diastolicPressure.last != nil && VectorPhysiologicalVariables.heartRate.last != nil && VectorPhysiologicalVariables.batteryLevel.last != nil{
                
                
                if VectorPhysiologicalVariables.diastolicPressure.last! > VectorPhysiologicalVariables.averagePressure.last!{
                    popoverContentIPhone.systolicPressureString = String(VectorPhysiologicalVariables.systolicPressure.last!) + " mmHg"
                    popoverContentIPhone.diastolicPressureString = String(VectorPhysiologicalVariables.averagePressure.last!) + " mmHg"
                    popoverContentIPhone.averagePressureString = String(VectorPhysiologicalVariables.diastolicPressure.last!) + " mmHg"
                    popoverContentIPhone.heartRatePressureString = String(VectorPhysiologicalVariables.heartRate.last!) + " BPM"
                    popoverContentIPhone.batteryLevelString = String(VectorPhysiologicalVariables.batteryLevel.last!) + " %"
                    
                }else{
                    popoverContentIPhone.systolicPressureString = String(VectorPhysiologicalVariables.systolicPressure.last!) + " mmHg"
                    popoverContentIPhone.diastolicPressureString = String(VectorPhysiologicalVariables.diastolicPressure.last!) + " mmHg"
                    popoverContentIPhone.averagePressureString = String(VectorPhysiologicalVariables.averagePressure.last!) + " mmHg"
                    popoverContentIPhone.heartRatePressureString = String(VectorPhysiologicalVariables.heartRate.last!) + " BPM"
                    popoverContentIPhone.batteryLevelString = String(VectorPhysiologicalVariables.batteryLevel.last!) + " %"
                }
                
                
            }
            navigationController?.pushViewController(popoverContentIPhone, animated: true)
        }
    }
    
    func displayErrorMessage(){
        activeCurrentMeasurementFlag = false
        currentView.stopAnimating()
        
        let alertController:UIAlertController?
        //typeError = 1
        
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
            alertController = UIAlertController(title:"", message: "Default", preferredStyle:UIAlertControllerStyle.alert)
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
}
