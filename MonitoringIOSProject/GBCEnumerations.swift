//
//  GBCEnumerations.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 27/4/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import Foundation

let defaults = NSUserDefaults.standardUserDefaults()

// MARK: - Enumerations

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

enum UserSelectedGraphic:Int{
    case pressureGraphic = 0, heartRateGraphic
}

enum TypeOfDevice:Int{
    case iPhone=0, iPad
}

enum UserSelectViewPrincipalViewController:Int{
    case realTimeViewController = 0, hitorialViewController, animationViewController
}

enum UserConfigurationEditOrAddNewPatient:Int{
    case editNewPatient = 0, addNewPatient
}

// MARK: - Structs

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
    static var vectorToUploadServer:[AnyObject] = []
}

struct UserSelectedConfiguration{
    static var typeOfDevice:TypeOfDevice?
    static var userSelectMeasurementTime:Int!
    
}

struct Users{
    static var userName:[String] = []
    static var userId:[String] = []
    static var age:[String] = []
    static var gender:[String] = []
}


