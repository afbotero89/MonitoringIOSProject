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

    let requestEditUser_POSTMethod = NSMutableURLRequest(URL: NSURL(string:"http://www.testgibic.com/app_slim/v1/public/pressure/patient/save")!)
    
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
    
    func insertNewPatient_postRequest(branch_id:String,name:String,document:String,age:String,gender:String,email:String){
        
        // create some JSON data and configure the request
        let jsonString = "data={\"branch_id\":\"\(branch_id)\",\"name\":\"\(name)\",\"document\":\"\(document)\",\"age\":\"\(age)\",\"gender\":\"\(gender)\"}"
        //let jsonString = "data={\"branch_id\":\"\(branch_id)\",\"name\":\"\(name)\",\"document\":\"\(document)\",\"age\":\"\(age)\",\"gender\":\"\(gender)\"}"
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
            self.getInfoPatient_getRequest()
            
            // notice that I can omit the types of data, response and error
            
            // your code
            
        });
        
        task.resume()
        
    }
    
    func editPatientByID(patient_id:Int,branch_id: String,name:String,document:String,age:String,gender:String,email:String){
        // create some JSON data and configure the request
        let jsonString = "data={\"id\":\"\(patient_id)\",\"branch_id\":\"\(branch_id)\",\"name\":\"\(name)\",\"document\":\"\(document)\",\"age\":\"\(age)\",\"gender\":\"\(gender)\",\"email\":\"\(email)\",\"pass\":\"\("23456")\"}"
        //let jsonString = "data={\"branch_id\":\"\(branch_id)\",\"name\":\"\(name)\",\"document\":\"\(document)\",\"age\":\"\(age)\",\"gender\":\"\(gender)\"}"
        requestEditUser_POSTMethod.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        requestEditUser_POSTMethod.HTTPMethod = "POST"
        requestEditUser_POSTMethod.setValue("", forHTTPHeaderField: "X-Token")
        requestEditUser_POSTMethod.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(requestEditUser_POSTMethod, completionHandler: {(data, response, error) in
            var json:AnyObject?
            do {
                try json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            }catch{
                print("exception")
            }
            print("edita !!!!!!!!!!!!!!")
            print(json)
            self.getInfoPatient_getRequest()
            
            // notice that I can omit the types of data, response and error
            
            // your code
            
        });
        
        task.resume()
    
    }
    
}