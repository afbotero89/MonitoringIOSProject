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

    var date: Date? {
        didSet {
            if date != nil {
                label.text = "\(date!.day)"
                view.frame = CGRect(x: 35, y: 5, width: 5, height: 5)
                print(date?.day)
                if "\(date!.day)" + "-" + "\(date!.month)" + "-" + "\(date!.year)" == "8-6-2016" && insertaIndicadorRegistro == false{
                    
                    view.backgroundColor = UIColor.redColor()
                    label.insertSubview(view, atIndex: 0)
                    
                }else if("\(date!.day)" + "-" + "\(date!.month)" + "-" + "\(date!.year)" == "9-6-2016" && insertaIndicadorRegistro == false){
                    
                    view.backgroundColor = UIColor.redColor()
                    label.insertSubview(view, atIndex: 0)
                    
                }else if("\(date!.day)" + "-" + "\(date!.month)" + "-" + "\(date!.year)" == "14-6-2016" && insertaIndicadorRegistro == false){
                    
                    view.backgroundColor = UIColor.redColor()
                    label.insertSubview(view, atIndex: 0)
                }else if("\(date!.day)" + "-" + "\(date!.month)" + "-" + "\(date!.year)" == "15-6-2016" && insertaIndicadorRegistro == false){
                    
                    view.backgroundColor = UIColor.redColor()
                    label.insertSubview(view, atIndex: 0)
                }else{
                    
                    view.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    label.insertSubview(view, atIndex: 0)
                }
                
                /*
                if "\(date!.day)" + "-" + "\(date!.month)" + "-" + "\(date!.year)" == "8-6-2016" && insertaIndicadorRegistro == false{
                    print("fecha!!")
                    print("\(date!.day)" + "-" + "\(date!.month)" + "-" + "\(date!.year)")
                    label.insertSubview(view, atIndex: 0)
                }
                if "\(date!.day)" + "-" + "\(date!.month)" + "-" + "\(date!.year)" == "9-6-2016" && insertaIndicadorRegistro == false{
                    label.insertSubview(view, atIndex: 0)
                }
                if "\(date!.day)" + "-" + "\(date!.month)" + "-" + "\(date!.year)" == "14-6-2016" && insertaIndicadorRegistro == false{
                    label.insertSubview(view, atIndex: 0)
                    insertaIndicadorRegistro = true
                }*/

                //label.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
            } else {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        markedViewWidth!.constant = min(self.frame.width, self.frame.height)
        markedViewHeight!.constant = min(self.frame.width, self.frame.height)
        markedView!.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2.0
    }

}
