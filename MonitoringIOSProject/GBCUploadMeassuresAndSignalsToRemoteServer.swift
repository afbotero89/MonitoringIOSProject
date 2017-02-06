//
//  GBCUploadMeassuresAndSignalsToRemoteServer.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 1/8/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import Foundation


class GBCUploadMeassuresAndSignalsToRemoteServer:NSObject{
    
    
    // Instances web service functions
    /// Request to remote data base sql: Type post  -> GIBIC server
    var requestSetDataBaseSQL = URLRequest(url: URL(string:"http://www.testgibic.com/app_slim/v1/public/pressure/meassure/save")!)
    
    
    // Instances GIBIC server
    /// Request to remote data base sql: Type post  -> GIBIC server
    //var requestSetDataBaseSQL_GIBICServer = URLRequest(url: URL(string:"http://localhost/appMonitoreo/querysToDatabaseInsertData.php")!)
    //var requestSetDataBaseSQL_GIBICServer = URLRequest(url: URL(string:"http://localhost/appMonitoreo/querysToDatabaseInsertData.php")!)
    var requestSetDataBaseSQL_GIBICServer = URLRequest(url: URL(string:"http://www.testgibic.com/app_pressure_monitor/querysToDatabaseInsertData.php")!)
    
    
    /// Request to remote data base sql: Type get
    var requestGetDayMonthYearDataBaseSQL = URLRequest(url: URL(string:"http://www.testgibic.com/app_pressure_monitor/querysToDatabaseGetDayMonthYear.php")!)
    
    var requestGetDataBaseSQL = URLRequest(url: URL(string:"http://www.testgibic.com/app_pressure_monitor/querysToDatabaseGetDataForDate.php")!)
    
    var serverResponse:NSString?
    
    /**
     Insert data into data base SQL (Systolic pressure, diastolic pressure, medium pressure heart rate, hour, date, DC and AC signal)---> GIBIC server
     */
    func uploadToServerDataBaseSQL(_ systolicPressure: Double,diastolicPressure: Double,mediumPressure: Double,heartRate: Double, hour:String, ACSignal:String, DCSignal:String, date:String){
        
        // create some JSON data and configure the request
        let jsonString = "data={\"patient_id\":\"\(1)\",\"data\":\"\(ACSignal)\",\"avg\":\"\(mediumPressure)\",\"dia\":\"\(diastolicPressure)\",\"sys\":\"\(systolicPressure)\",\"time\":\"\(hour)\",\"date\":\"\(date)\"}"
        //let jsonString = "data={\"branch_id\":\"\(branch_id)\",\"name\":\"\(name)\",\"document\":\"\(document)\",\"age\":\"\(age)\",\"gender\":\"\(gender)\"}"
        requestSetDataBaseSQL.httpBody = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        requestSetDataBaseSQL.httpMethod = "POST"
        requestSetDataBaseSQL.setValue("", forHTTPHeaderField: "X-Token")
        requestSetDataBaseSQL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        /*
        let task = session.dataTask(with: requestSetDataBaseSQL, completionHandler: {(data, response, error) in
            var json:AnyObject?
            if data != nil{
                do {
                    try json = JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
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
        */
    }
    
    // MARK: -- GIBIC server
    
    /**
    Insert data into data base SQL (Systolic pressure, diastolic pressure, medium pressure heart rate, hour and date) --> gibic server
     */
    func uploadToServerDataBaseSQL_GIBIC(_ systolicPressure: Double,diastolicPressure: Double,mediumPressure: Double,heartRate: Double, hour:String){
        
        requestSetDataBaseSQL_GIBICServer.httpMethod = "POST"
        
        let date = Foundation.Date()
        
        VectorPhysiologicalVariables.ACSignal = "AC"
        
        let postString = "document=\(systolicPressure)&sys=\(systolicPressure)&diast=\(diastolicPressure)&aver=\(mediumPressure)&heart=\(heartRate)&hour=\(hour)&date=\(date.year)-\(date.month)-\(date.day)"
        requestSetDataBaseSQL_GIBICServer.httpBody = postString.data(using: String.Encoding.utf8)
        
        
        let task = URLSession.shared.dataTask(with: requestSetDataBaseSQL_GIBICServer, completionHandler: {
            data, response, error in
            
            if error != nil {
                
                if  (defaults.array(forKey: "VectorToUpLoadServer") != nil){
                    if (defaults.array(forKey: "VectorToUpLoadServer")?.count)! > 0{
                        VectorPhysiologicalVariables.vectorToUploadServer = defaults.array(forKey: "VectorToUpLoadServer")! as [AnyObject]
                    }
                }
                VectorPhysiologicalVariables.vectorToUploadServer.append(postString as AnyObject)
                defaults.set(VectorPhysiologicalVariables.vectorToUploadServer, forKey: "VectorToUpLoadServer")
                print("variables almacenadas db sql")
    
                return
            }
            
            print("response = \(response)")
            
        }) 
        task.resume()
        
    }
    
    /*
        Upload lost data by bad internet connection --> Gibic server
     */
    func upLoadLostDataToServer(_ lostData:String){
        
        let postString = lostData
        requestSetDataBaseSQL_GIBICServer.httpBody = postString.data(using: String.Encoding.utf8)
        /*
        let task = URLSession.shared.dataTask(with: requestSetDataBaseSQL_GIBICServer, completionHandler: {
            data, response, error in
            
            if error != nil {
                
                return
            }
            
            print("response = \(response)")
            
            defaults.removeObject(forKey: "VectorToUpLoadServer")
        }) 
        task.resume()
        */
    }
    
    /*
     Get data from data base SQL by Day Month Year
     */
    func getDataFromDataBaseSQLDayMonthYear(){
        
        requestGetDayMonthYearDataBaseSQL.httpMethod = "POST"
        
        let postString = ""
        
        requestGetDayMonthYearDataBaseSQL.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: requestGetDayMonthYearDataBaseSQL, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            self.serverResponse = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            PhysiologicalVariablesStoredInDatabaseSQL.dayMonthYearDataBaseSQL = self.serverResponse
            
        }) 
        
        task.resume()
        
        
    }

    
}
