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
    
    let requestGetDayMonthYearDataBaseSQL = GBCUploadMeassuresAndSignalsToRemoteServer()
    
    var serverResponse:NSString?
    
    var vectorDatesStoredInDataBases:[String]?
    
    var date: Date? {
        didSet {
            
            if date != nil {
                
                //requestGetDayMonthYearDataBaseSQL.getDataFromDataBaseSQLDayMonthYear()
    
                //vectorDatesStoredInDataBases = PhysiologicalVariablesStoredInDatabaseSQL.dayMonthYearDataBaseSQL?.components(separatedBy: ",")
                vectorDatesStoredInDataBases = ["4/6/2017"]
                /*
                if PhysiologicalVariablesStoredInDatabaseSQL.dayMonthYearDataBaseSQL == nil{
                
                }else{
                    vectorDatesStoredInDataBases = PhysiologicalVariablesStoredInDatabaseSQL.dayMonthYearDataBaseSQL!.components(separatedBy: ",")
                }*/

                label.text = "\(date!.day)"
                view.frame = CGRect(x: 35, y: 5, width: 5, height: 5)
                view.layer.cornerRadius = 3
                
                view.backgroundColor = UIColor.groupTableViewBackground
                
            if vectorDatesStoredInDataBases != nil{
                
                for i in vectorDatesStoredInDataBases!{
                    
                    var monthString:String!
                    
                    var dayString:String!
                    
                    if date!.month < 10{
                        //monthString = "0" + "\(date!.month)"
                        monthString = "\(date!.month)"
                    }else{
                        monthString = "\(date!.month)"
                    }
                    
                    if date!.day < 10{
                        //dayString = "0" + "\(date!.day)"
                        dayString = "\(date!.day)"
                    }else{
                        dayString = "\(date!.day)"
                    }
                    
                    if "\(dayString!)" + "/" + "\(monthString!)" + "/" + "\(date!.year)"  == i {
                        view.backgroundColor = UIColor.red
                        
                    }
                }
                label.insertSubview(view, at: 0)
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
                markedView!.isHidden = false
            } else {
                markedView!.isHidden = true
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        markedViewWidth!.constant = min(self.frame.width, self.frame.height)
        markedViewHeight!.constant = min(self.frame.width, self.frame.height)
        markedView!.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2.0
    }

}
