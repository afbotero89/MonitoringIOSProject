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
    
    func displayString()-> String{
        switch self{
        case .systolicPressure:
            return "Systolic pressure:"
        case .diastolicPressure:
            return "Diastolic pressure:"
        case .averagePressure:
            return "Average pressure:"
        case .heartRate:
            return "Heart rate:"
        }
    }
    
    static let allValues = [systolicPressure, diastolicPressure, averagePressure, heartRate]
}

enum DeviceVariables:Int{
    case batteryLevel=0, currentHour
    
    static let allValues = [batteryLevel, currentHour]
}

struct VectorPhysiologicalVariables{
    
    //static var currentMeasures : [Character] = []
    static var currentMeasures:String = ""
    static var systolicPressure:[Double] = []
    static var diastolicPressure:[Double] = []
    static var averagePressure:[Double] = []
    static var heartRate:[Double] = []
    static var measuringTime:[String] = []
    static var batteryLevel:[Double] = []
    static var vectorNumberOfSamples:[Double] = []
}