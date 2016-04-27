//
//  GBCEnumerations.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 27/4/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import Foundation

enum PhysiologicalVariables:Int{
    case systolicPressure=0, diastolicPressure, averagePressure, heartRate
    
    static let allValues = [systolicPressure, diastolicPressure, averagePressure, heartRate]
}

enum DeviceVariables:Int{
    case batteryLevel=0, currentHour
    
    static let allValues = [batteryLevel, currentHour]
}