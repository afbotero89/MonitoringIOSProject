//
//  AditionalInformationPopupViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 4/5/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

class GBCAditionalInformationPopupViewController: UIViewController {

    @IBOutlet weak var titlePhysiologicalVariable: UILabel!
    
    @IBOutlet weak var valuePhysiologicalVariable: UILabel!
    
    @IBOutlet weak var measuringTime: UILabel!
    
    var titlePhysiologicalVariableString:String?
    
    var valuePhysiologicalVariableString:String?
    
    var measuringTimeString:String?
    
    var unitsString:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titlePhysiologicalVariable.text = titlePhysiologicalVariableString
        
        valuePhysiologicalVariable.text = valuePhysiologicalVariableString! + unitsString!
        
        measuringTime.text = measuringTimeString
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
