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
        let names = GBCAnimationView.arrayWithNumberedNames("AnimCurva1920x1080V1.", rangeStart: 0, rangeEnd: 119, suffixFormat: "%05i.jpg")
        let urls =  GBCAnimationView.arrayWithResourcePrefixedURLs(names)
        
        self.currentView.setAnimationWithAnimationURLs(urls, animationFrameDuration: 0.5, animationRepeatCount: 30)
        
        self.currentView.startAnimating()
        
        addNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        if (self.isViewLoaded() && self.view.window == nil){
            print("disappear")
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "displayCurrentMeasurementPopoverNotification", object: nil)
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
        print("deinit!!!!!!!!!")
        // Remove this object from any notification of notification center.
        //NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func addNotifications(){
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(CBCAnimationViewController.displayCurrentMeasurementPopover),
                                                         
                                                         name: "displayCurrentMeasurementPopoverNotification",
                                                         
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(CBCAnimationViewController.displayErrorMessage),
                                                         
                                                         name: "displayErrorMessage",
                                                         
                                                         object: nil)
        
    }
    
    func displayCurrentMeasurementPopover(){
        
        let popoverContent = (self.storyboard?.instantiateViewControllerWithIdentifier("currentMeasurement"))! as! GBCCurrentMeasurementViewController
        
        popoverContent.systolicPressureString = String(VectorPhysiologicalVariables.systolicPressure.last!) + " mmHg"
        popoverContent.diastolicPressureString = String(VectorPhysiologicalVariables.averagePressure.last!) + " mmHg"
        popoverContent.averagePressureString = String(VectorPhysiologicalVariables.diastolicPressure.last!) + " mmHg"
        popoverContent.heartRatePressureString = String(VectorPhysiologicalVariables.heartRate.last!) + " BPM"
        popoverContent.batteryLevelString = String(VectorPhysiologicalVariables.batteryLevel.last!) + " %"
    
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            currentView.stopAnimating()
            navigationController?.pushViewController(popoverContent, animated: true)
            
        case .iPhone:
            currentView.stopAnimating()
            let popoverContentIPhone = (self.storyboard?.instantiateViewControllerWithIdentifier("currentMeasurementiPhone"))! as! GBCCurrentMeasurementViewController
            popoverContentIPhone.systolicPressureString = String(VectorPhysiologicalVariables.systolicPressure.last!) + " mmHg"
            popoverContentIPhone.diastolicPressureString = String(VectorPhysiologicalVariables.diastolicPressure.last!) + " mmHg"
            popoverContentIPhone.averagePressureString = String(VectorPhysiologicalVariables.averagePressure.last!) + " mmHg"
            popoverContentIPhone.heartRatePressureString = String(VectorPhysiologicalVariables.heartRate.last!) + " BPM"
            popoverContentIPhone.batteryLevelString = String(VectorPhysiologicalVariables.batteryLevel.last!) + " %"
            navigationController?.pushViewController(popoverContentIPhone, animated: true)
        }
    }
    
    func displayErrorMessage(){
        
        currentView.stopAnimating()
        
        let alertController:UIAlertController?
        typeError = 1
        
        switch typeError!{
        case 1:
            // Desconexion de manguera
            alertController = UIAlertController(title: NSLocalizedString("Device error", comment: ""), message: NSLocalizedString("Disconnect hose", comment: ""), preferredStyle:UIAlertControllerStyle.Alert)
        case 2:
            alertController = UIAlertController(title: NSLocalizedString("Device error", comment: ""), message: NSLocalizedString("Circuit leaks", comment: ""), preferredStyle:UIAlertControllerStyle.Alert)
        case 3:
            alertController = UIAlertController(title: NSLocalizedString("Device error", comment: ""), message: NSLocalizedString("Incorrect pressure", comment: ""), preferredStyle:UIAlertControllerStyle.Alert)
        case 4:
            alertController = UIAlertController(title: NSLocalizedString("Device error", comment: ""), message: NSLocalizedString("Monitor measure canceled", comment: ""), preferredStyle:UIAlertControllerStyle.Alert)
        case 5:
            alertController = UIAlertController(title: NSLocalizedString("Device error", comment: ""), message: NSLocalizedString("heart rate not caculated", comment: ""), preferredStyle:UIAlertControllerStyle.Alert)
        case 6:
            alertController = UIAlertController(title: NSLocalizedString("Device error", comment: ""), message: NSLocalizedString("Incorrect pressure", comment: ""), preferredStyle:UIAlertControllerStyle.Alert)
        default:
            alertController = UIAlertController(title: NSLocalizedString("Device error", comment: ""), message: "Default", preferredStyle:UIAlertControllerStyle.Alert)
        }
        
        alertController!.addAction(UIAlertAction(title:  NSLocalizedString("Done", comment: ""), style: .Default, handler: {
            action in
            
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                self.dismissViewControllerAnimated(true, completion: nil)
            case .iPhone:
                self.navigationController?.popViewControllerAnimated(true)
            }

        }))
        self.presentViewController(alertController!, animated: true, completion: nil)

    }
}
