//
//  GBCUploadMeassuresAndSignalsToRemoteServer.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 1/8/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import Foundation

class GBCUploadMeassuresAndSignalsToRemoteServer:NSObject{
    
    /// Request to remote data base sql: Type post
    let requestSetDataBaseSQL = NSMutableURLRequest(URL: NSURL(string:"http://www.testgibic.com/app_slim/v1/public/pressure/meassure/save")!)
    /**
     Insert data into data base SQL (Systolic pressure, diastolic pressure, medium pressure heart rate, hour, date, DC and AC signal)
     */
    func uploadToServerDataBaseSQL(systolicPressure: Double,diastolicPressure: Double,mediumPressure: Double,heartRate: Double, hour:String, ACSignal:String, DCSignal:String, date:String){
        
        // create some JSON data and configure the request
        let jsonString = "data={\"patient_id\":\"\(1)\",\"data\":\"\(ACSignal)\",\"avg\":\"\(mediumPressure)\",\"dia\":\"\(diastolicPressure)\",\"sys\":\"\(systolicPressure)\",\"time\":\"\(hour)\",\"date\":\"\(date)\"}"
        //let jsonString = "data={\"branch_id\":\"\(branch_id)\",\"name\":\"\(name)\",\"document\":\"\(document)\",\"age\":\"\(age)\",\"gender\":\"\(gender)\"}"
        requestSetDataBaseSQL.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        requestSetDataBaseSQL.HTTPMethod = "POST"
        requestSetDataBaseSQL.setValue("", forHTTPHeaderField: "X-Token")
        requestSetDataBaseSQL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(requestSetDataBaseSQL, completionHandler: {(data, response, error) in
            var json:AnyObject?
            do {
                try json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            }catch{
                print("exception")
            }
            print("respuesta !!!!")
            print(json)
            
            // notice that I can omit the types of data, response and error
            
            // your code
            
        });
        
        task.resume()
        
    }


}