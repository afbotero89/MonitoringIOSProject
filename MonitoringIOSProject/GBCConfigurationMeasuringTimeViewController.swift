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
        
        doneButtonLayer.setTitle(NSLocalizedString("Done", comment: ""), for: UIControlState())
        
        adjustMeasuringTimeLabel.text = NSLocalizedString("Adjust measurement time", comment: "")
        
        doneButtonLayer.layer.cornerRadius = 5
        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 64/255, blue: 128/255, alpha: 1.0)
    }

    @IBAction func doneButton(_ sender: AnyObject) {
        if DeviceVariables.bluetoothConnected == true{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "sendMeasurementTimeToPeripheral"), object: nil, userInfo: nil)
            self.dismiss(animated: true, completion: nil)
        }else{
            
            let alert = UIAlertController(title: NSLocalizedString("Connection fail", comment: ""), message: NSLocalizedString("Check your Bluetooth connection", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default) { _ in })
            self.present(alert, animated: true){}
            
        }
    }
}
