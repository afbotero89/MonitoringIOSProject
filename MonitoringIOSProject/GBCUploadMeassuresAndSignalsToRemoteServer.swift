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
    
    
    /// Request to remote data base sql: Type post  -> Sibxeco server
    let requestSetDataBaseSQL_sibxecoServer = NSMutableURLRequest(URL: NSURL(string:"http://www.sibxe.co/appMonitoreo/querysToDatabase.php")!)
    
    
    /// Request to remote data base sql: Type get   -> Sibxeco server
    let requestGetDayMonthYearDataBaseSQL_sibxecoServer = NSMutableURLRequest(URL: NSURL(string:"http://www.sibxe.co/appMonitoreo/querysToDatabaseGetDayMonthYear.php")!)
    
    
    /// Request to remote data base sql: Type get
    let requestGetDayMonthYearDataBaseSQL = NSMutableURLRequest(URL: NSURL(string:"http://www.sibxe.co/appMonitoreo/querysToDatabaseGetDayMonthYear.php")!)
    
    var serverResponse:NSString?
    
    /**
     Insert data into data base SQL (Systolic pressure, diastolic pressure, medium pressure heart rate, hour, date, DC and AC signal)---> GIBIC server
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
            if data != nil{
                do {
                    try json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                }catch{
                    print("exception")
                }
            }
            print("respuesta measure !!!!")
            print(json)
            VectorPhysiologicalVariables.ACSignal = "AC"
            VectorPhysiologicalVariables.DCSignal = "DC"
            VectorPhysiologicalVariables.fullSignal = ""
            // notice that I can omit the types of data, response and error
            
            // your code
            
        });
        
        task.resume()
        
    }
    
    // MARK: -- Sibxe server
    
    /**
    Insert data into data base SQL (Systolic pressure, diastolic pressure, medium pressure heart rate, hour and date) --> sibxe server
     */
    func uploadToServerDataBaseSQL_Sibxeco(systolicPressure: Double,diastolicPressure: Double,mediumPressure: Double,heartRate: Double, hour:String){
        
        requestSetDataBaseSQL_sibxecoServer.HTTPMethod = "POST"
        
        let date = NSDate()
        
        VectorPhysiologicalVariables.ACSignal = "AC"
        
        let postString = "a=\(systolicPressure)&b=\(diastolicPressure)&c=\(mediumPressure)&d=\(heartRate)&e=\(hour)&f=\(date.year)-\(date.month)-\(date.day)"
        requestSetDataBaseSQL_sibxecoServer.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(requestSetDataBaseSQL_sibxecoServer) {
            data, response, error in
            
            if error != nil {
                
                if defaults.arrayForKey("VectorToUpLoadServer")?.count > 0{
                    VectorPhysiologicalVariables.vectorToUploadServer = defaults.arrayForKey("VectorToUpLoadServer")!
                }
                VectorPhysiologicalVariables.vectorToUploadServer.append(postString)
                defaults.setObject(VectorPhysiologicalVariables.vectorToUploadServer, forKey: "VectorToUpLoadServer")
                print("variables almacenadas db sql")
                print(defaults.arrayForKey("VectorToUpLoadServer"))
                return
            }
            
            print("response = \(response)")
            
        }
        task.resume()
    
    }
    
    /*
        Upload lost data by bad internet connection --> Sibxe server
     */
    func upLoadLostDataToServer(lostData:String){
        
        let postString = lostData
        requestSetDataBaseSQL_sibxecoServer.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(requestSetDataBaseSQL_sibxecoServer) {
            data, response, error in
            
            if error != nil {
                
                return
            }
            
            print("response = \(response)")
            
            defaults.removeObjectForKey("VectorToUpLoadServer")
        }
        task.resume()
        
    }
    
    /*
     Get data from data base SQL by Day Month Year
     */
    func getDataFromDataBaseSQLDayMonthYear(){
        
        requestGetDayMonthYearDataBaseSQL.HTTPMethod = "POST"
        
        let postString = "month=2016-06-21"
        
        requestGetDayMonthYearDataBaseSQL.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(requestGetDayMonthYearDataBaseSQL) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            self.serverResponse = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            PhysiologicalVariablesStoredInDatabaseSQL.dayMonthYearDataBaseSQL = self.serverResponse
            
        }
        
        task.resume()
        
        
    }

    
}