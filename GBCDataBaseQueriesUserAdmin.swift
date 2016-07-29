//
//  GBCDataBaseQueriesUserAdmin.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 28/7/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import Foundation

class GBCDataBaseQueriesUserAdmin:NSObject{
    
    let requestSetDataBaseSQL_GETMethod = NSMutableURLRequest(URL: NSURL(string:"http://testgibic.com/app_slim/v1/public/pressure/patient/all")!)
    
    let requestSetDataBaseSQL_POSTMethod = NSMutableURLRequest(URL: NSURL(string:"http://www.testgibic.com/app_slim/v1/public/pressure/patient/save")!)

    
    func getInfoPatient_getRequest(){
        
        requestSetDataBaseSQL_GETMethod.HTTPMethod = "GET"
        
        requestSetDataBaseSQL_GETMethod.allHTTPHeaderFields = ["X-Token":""]
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(self.requestSetDataBaseSQL_GETMethod) {
            data, response, error in
            
            var json:AnyObject?
            
            if error != nil {
                print("error = \(error)")
                return
            }
            
            print("response = \(response)")
            
            do {
                try json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            }catch{
                print("exception")
            }
            
            PatientListStruct.patientList = json
            print(json)
        }
        
        task.resume()
        
        //return PatientListStruct.patientList!
        
    }
    
    func insertNewPatient_postRequest(){
        
        // create some JSON data and configure the request
        let jsonString = "data={\"branch_id\":\"1\",\"name\":\"usuario6\",\"document\":\"67890\",\"age\":\"45\",\"gender\":\"F\"}"
        requestSetDataBaseSQL_POSTMethod.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        requestSetDataBaseSQL_POSTMethod.HTTPMethod = "POST"
        requestSetDataBaseSQL_POSTMethod.setValue("", forHTTPHeaderField: "X-Token")
        requestSetDataBaseSQL_POSTMethod.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(requestSetDataBaseSQL_POSTMethod, completionHandler: {(data, response, error) in
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
        getInfoPatient_getRequest()
    }
    
}