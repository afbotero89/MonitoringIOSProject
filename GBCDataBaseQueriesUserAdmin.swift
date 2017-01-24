//
//  GBCDataBaseQueriesUserAdmin.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 28/7/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import Foundation

class GBCDataBaseQueriesUserAdmin:NSObject{
    
    /// Instances Web service functions
    
    let requestSetDataBaseSQL_GETMethod = NSMutableURLRequest(url: URL(string:"http://testgibic.com/app_slim/v1/public/pressure/patient/all")!)
    
    let requestSetDataBaseSQL_POSTMethod = NSMutableURLRequest(url: URL(string:"http://www.testgibic.com/app_slim/v1/public/pressure/patient/save")!)

    let requestEditUser_POSTMethod = NSMutableURLRequest(url: URL(string:"http://www.testgibic.com/app_slim/v1/public/pressure/patient/save")!)
    
    
    
    /// Instances GIBIC server
    
    var requestInsertNewPatient = URLRequest(url: URL(string:"http://www.testgibic.com/app_pressure_monitor/admin/insertNewPatient.php")!)
    
    
    var requestGetPatientList = URLRequest(url: URL(string:"http://www.testgibic.com/app_pressure_monitor/admin/getPatientList.php")!)
    
    var requestEditPatient = URLRequest(url: URL(string:"http://www.testgibic.com/app_pressure_monitor/admin/editPatient.php")!)
    
    var requestRemovePatient = URLRequest(url: URL(string:"http://www.testgibic.com/app_pressure_monitor/admin/removePatient.php")!)
    
    
    // MARK: - Web service functions
    
    func getInfoPatient_getRequest(){
        
        requestSetDataBaseSQL_GETMethod.httpMethod = "GET"
        
        requestSetDataBaseSQL_GETMethod.allHTTPHeaderFields = ["X-Token":""]
        /*
        let task = URLSession.shared.dataTask(with: self.requestSetDataBaseSQL_GETMethod, completionHandler: {
            data, response, error in
            
            var json:AnyObject?
            
            if error != nil {
                print("error = \(error)")
                return
            }
            
            print("response = \(response)")
            
            do {
                try json = JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            }catch{
                print("exception")
            }
            
            PatientListStruct.patientList = json
            print(json)
        }) 
        
        task.resume()
        */
        //return PatientListStruct.patientList!
        
    }
    
    func insertNewPatient_postRequest(_ branch_id:String,name:String,document:String,age:String,gender:String,email:String){
        
        // create some JSON data and configure the request
        let jsonString = "data={\"branch_id\":\"\(branch_id)\",\"name\":\"\(name)\",\"document\":\"\(document)\",\"age\":\"\(age)\",\"gender\":\"\(gender)\"}"
        //let jsonString = "data={\"branch_id\":\"\(branch_id)\",\"name\":\"\(name)\",\"document\":\"\(document)\",\"age\":\"\(age)\",\"gender\":\"\(gender)\"}"
        requestSetDataBaseSQL_POSTMethod.httpBody = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        requestSetDataBaseSQL_POSTMethod.httpMethod = "POST"
        requestSetDataBaseSQL_POSTMethod.setValue("", forHTTPHeaderField: "X-Token")
        requestSetDataBaseSQL_POSTMethod.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        /*
        let task = session.dataTask(with: requestSetDataBaseSQL_POSTMethod, completionHandler: {(data, response, error) in
            var json:AnyObject?
            do {
                try json = JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
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
        */
    }
    
    func editPatientByID(_ patient_id:Int,branch_id: String,name:String,document:String,age:String,gender:String,email:String){
        // create some JSON data and configure the request
        let jsonString = "data={\"id\":\"\(patient_id)\",\"branch_id\":\"\(branch_id)\",\"name\":\"\(name)\",\"document\":\"\(document)\",\"age\":\"\(age)\",\"gender\":\"\(gender)\",\"email\":\"\(email)\",\"pass\":\"\("23456")\"}"
        //let jsonString = "data={\"branch_id\":\"\(branch_id)\",\"name\":\"\(name)\",\"document\":\"\(document)\",\"age\":\"\(age)\",\"gender\":\"\(gender)\"}"
        requestEditUser_POSTMethod.httpBody = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        requestEditUser_POSTMethod.httpMethod = "POST"
        requestEditUser_POSTMethod.setValue("", forHTTPHeaderField: "X-Token")
        requestEditUser_POSTMethod.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        /*
        let task = session.dataTask(with: requestEditUser_POSTMethod, completionHandler: {(data, response, error) in
            var json:AnyObject?
            do {
                try json = JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
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
    */
    }
    
    // MARK: - Queries Gibic server
    
    /* Insert new patient */
    func insertNewPatient(_ name:String,document: String,age:String,gender:String,email:String,pass:String,profile:String){
        
        requestInsertNewPatient.httpMethod = "POST"
        
        let postString = "name=\(name)&document=\(document)&age=\(age)&gender=\(gender)&email=\(email)&pass=\(pass)&profile=\(profile)"
        
        requestInsertNewPatient.httpBody = postString.data(using: String.Encoding.utf8)
        
        
        let task = URLSession.shared.dataTask(with: requestInsertNewPatient, completionHandler: {
            data, response, error in
            
            
            if error != nil {
                
                print("variables almacenadas db sql")
                
                return
            }
            
            print("response = \(response)")
            
        })
        task.resume()
    
    }
    
    
    /* Get patient list */
    func getPatientList(){
        
         requestGetPatientList.httpMethod = "GET"
        
         URLSession.shared.dataTask(with: self.requestGetPatientList, completionHandler: {
         data, response, error in
            
            if error != nil {
                
                print("variables almacenadas db sql")
                
                return
            }
            
            var json:Any?
            
            do {
                try json = JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            }catch{
                print("exception")
            }

            let patientsInDB = json as! NSArray
            
            
            // If there are patients in database
            if (patientsInDB.count != 0){
            
                PatientListStruct.patientList = patientsInDB
            
                let name = patientsInDB.object(at: 0)
            
                print("server response = \((name as AnyObject))")
            
                PatientListStruct.numberOfPatientsInDataBases = PatientListStruct.patientList?.count
            
                NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadMasterAdminUserPanel"), object: nil, userInfo: nil)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadDetailAdminUserPanel"), object: nil, userInfo: nil)
            }
            
         }).resume()
        
         print("entra 2")
    }
    
    /* Edit patient */
    func editPatient(_ last_id:Int, last_name:String, last_document:String, name:String,document: String,age:String,gender:String,email:String,pass:String,profile:String){
        
        requestEditPatient.httpMethod = "POST"
        
        let postString = "last_id=\(last_id)&last_name=\(last_name)&last_document=\(last_document)&name=\(name)&document=\(document)&age=\(age)&gender=\(gender)&email=\(email)&pass=\(pass)&profile=\(profile)"
        
        requestEditPatient.httpBody = postString.data(using: String.Encoding.utf8)
        
        
        let task = URLSession.shared.dataTask(with: requestEditPatient, completionHandler: {
            data, response, error in
            
            
            if error != nil {
                
                print("variables almacenadas db sql")
                
                return
            }
            
            print("response = \(response)")
            
        })
        task.resume()
        
    }
    
    /* Remove patient */
    func removePatient(_ id:Int, name:String, document: String){
        
        requestRemovePatient.httpMethod = "POST"
        
        let postString = "id=\(id)&document=\(document)&name=\(name)"
        
        requestRemovePatient.httpBody = postString.data(using: String.Encoding.utf8)
        
        print("remove patient")
        let task = URLSession.shared.dataTask(with: requestRemovePatient, completionHandler: {
            data, response, error in
            
            
            if error != nil {
                
                print("variables almacenadas db sql")
                
                return
            }
            
            print("response = \(response)")
            
        })
        task.resume()
        
    }
    
}
