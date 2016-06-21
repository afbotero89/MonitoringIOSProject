//
//  DayCollectionCell.swift
//  Calendar
//
//  Created by Lancy on 02/06/15.
//  Copyright (c) 2015 Lancy. All rights reserved.
//

import UIKit

var insertaIndicadorRegistro = false

class DayCollectionCell: UICollectionViewCell {
    
    @IBOutlet var label: UILabel!
    let view = UIView()
    @IBOutlet var markedView: UIView!
    @IBOutlet var markedViewWidth: NSLayoutConstraint!
    @IBOutlet var markedViewHeight: NSLayoutConstraint!
    
    let requestGetDayMonthYearDataBaseSQL = NSMutableURLRequest(URL: NSURL(string:"http://www.sibxe.co/appMonitoreo/querysToDatabaseGetDayMonthYear.php")!)
    
    var serverResponse:NSString?
    
    var vectorDatesStoredInDataBases:[String]?
    
    var date: Date? {
        didSet {
            
            if date != nil {
                
                if PhysiologicalVariablesStoredInDatabaseSQL.dayMonthYearDataBaseSQL == nil{
    
                    getDataFromDataBaseSQLDayMonthYear()
    
                    vectorDatesStoredInDataBases = PhysiologicalVariablesStoredInDatabaseSQL.dayMonthYearDataBaseSQL?.componentsSeparatedByString(",")
                }else{
                    vectorDatesStoredInDataBases = PhysiologicalVariablesStoredInDatabaseSQL.dayMonthYearDataBaseSQL?.componentsSeparatedByString(",")
                }
                
                label.text = "\(date!.day)"
                view.frame = CGRect(x: 35, y: 5, width: 5, height: 5)
                
            view.backgroundColor = UIColor.groupTableViewBackgroundColor()
                
            if vectorDatesStoredInDataBases != nil{
                
                for i in vectorDatesStoredInDataBases!{
                    
                    var monthString:String!
                    
                    var dayString:String!
                    
                    if date!.month < 10{
                        monthString = "0" + "\(date!.month)"
                    }else{
                        monthString = "\(date!.month)"
                    }
                    
                    if date!.day < 10{
                        dayString = "0" + "\(date!.day)"
                    }else{
                        dayString = "\(date!.day)"
                    }
                    
                    if "\(date!.year)" + "-" + "\(monthString)" + "-" + "\(dayString)" == i {
                        view.backgroundColor = UIColor.redColor()
                        
                    }
                }
                label.insertSubview(view, atIndex: 0)
            }
                
              }else{
                label.text = ""
            }
        }
    }
    
    var disabled: Bool = false {
        didSet {
            if disabled {
                alpha = 0.4
            } else {
                alpha = 1.0
            }
        }
    }
    
    var mark: Bool = false {
        didSet {
            if mark {
                markedView!.hidden = false
            } else {
                markedView!.hidden = true
            }
        }
    }
    
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
            print("entra a la funcion !!!!")
            
            self.serverResponse = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            PhysiologicalVariablesStoredInDatabaseSQL.dayMonthYearDataBaseSQL = self.serverResponse
            
        }
        
        task.resume()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        markedViewWidth!.constant = min(self.frame.width, self.frame.height)
        markedViewHeight!.constant = min(self.frame.width, self.frame.height)
        markedView!.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2.0
    }

}
