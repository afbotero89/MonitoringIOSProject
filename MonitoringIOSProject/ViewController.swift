//
//  ViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 27/4/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

var x = [0.0,0.01]

var y = [0.0,0.01]

class ViewController: GBCPlotsViewController {
    
    var contador = 0.0
    
    var timer:NSTimer?
    
    let plot = CPTScatterPlot()
    
    let plot1 = CPTScatterPlot()
    
    let plot2 = CPTScatterPlot()
    
    let plot3 = CPTScatterPlot()
    
    var pressureContainerGraph = CPTGraphHostingView()
    
    var heartRateContainerGraph = CPTGraphHostingView()
    
    let request = NSMutableURLRequest(URL: NSURL(string:"http://www.sibxe.co/appMonitoreo/querysToDatabase.php")!)
    
    var bluetoothManager:BluetoothManager!
    
    let labelPressure = UILabel()
    
    let labelHeartRate = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the bluetooth manager.
        self.bluetoothManager = BluetoothManager()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(ViewController.insertPoint),
                                                         
                                                         name: "insertNewPlot",
                                                         
                                                         object: nil)
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Do any additional setup after loading the view, typically from a nib.
        plot.identifier = 1
        plot1.identifier = 2
        plot2.identifier = 3
        plot3.identifier = 4
        
        // Set the lineStyle for the plot
        plot.dataSource = self
        plot1.dataSource = self
        plot2.dataSource = self
        plot3.dataSource = self
        let plotLineStyle = plot.dataLineStyle!.mutableCopy() as! CPTMutableLineStyle
        plotLineStyle.lineWidth = 2.5
        plotLineStyle.lineColor = CPTColor(componentRed: 162/255, green: 0/255, blue: 37/255, alpha: 1.0)
        plot.dataLineStyle = plotLineStyle
        
        plot.title = "Systolic pressure"
        plot1.title = "Diastolic pressure"
        plot2.title = "Average pressure"
        plot3.title = "Heart rate"
        
        pressuresGraph.addPlot(plot)
        pressuresGraph.addPlot(plot1)
        pressuresGraph.addPlot(plot2)
        heartRateGraph.addPlot(plot3)
        
        //timer = NSTimer.scheduledTimerWithTimeInterval(0.002, target: self, selector: #selector(ViewController.insertPoint), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
        
        setLegendGraph()
        addAttributesToContainerGraph()
        
        request.HTTPMethod = "POST"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func addAttributesToContainerGraph(){
        // Labe1: pressure value
        labelPressure.frame = CGRect(x: 500, y: 310, width: 150, height: 160)
        labelPressure.numberOfLines = 10
        labelPressure.text = "Systolic:\n\n Diastolic:\n\n Average:"
        labelPressure.textColor = UIColor.whiteColor()
        labelPressure.backgroundColor =  UIColor(red: 11/255, green: 44/255, blue: 65/255, alpha: 0.7)
        
        // Label2: heart rate value
        labelHeartRate.frame = CGRect(x: 500, y: 850, width: 150, height: 80)
        labelHeartRate.numberOfLines = 10
        labelHeartRate.text = "Heart Rate:"
        labelHeartRate.textColor = UIColor.whiteColor()
        labelHeartRate.backgroundColor =  UIColor(red: 11/255, green: 44/255, blue: 65/255, alpha: 0.7)
        
        // attributes pressure container
        pressureContainerGraph.frame = CGRect(x: 100, y: 80, width: 550, height: 450)
        pressureContainerGraph.layer.borderWidth = 1
        pressureContainerGraph.layer.borderColor = UIColor.blackColor().CGColor
        pressureContainerGraph.layer.cornerRadius = 20
        pressureContainerGraph.hostedGraph = pressuresGraph
        
        // attributes heart rate container graph
        heartRateContainerGraph.frame = CGRect(x: 100, y: 550, width: 550, height: 450)
        heartRateContainerGraph.layer.borderWidth = 1
        heartRateContainerGraph.layer.borderColor = UIColor.blackColor().CGColor
        heartRateContainerGraph.layer.cornerRadius = 20
        heartRateContainerGraph.hostedGraph = heartRateGraph
        
        // Insert subviews
        view.addSubview(pressureContainerGraph)
        view.addSubview(heartRateContainerGraph)
        view.addSubview(labelHeartRate)
        view.addSubview(labelPressure)
    }
    
    func setLegendGraph(){
        // Set legend pressure graph
        let theLegend=CPTLegend(graph: pressuresGraph)
        let theLegendHeartRate=CPTLegend(graph: heartRateGraph)
        
        let legendLineStyle = CPTMutableLineStyle()
        theLegend.fill = CPTFill(color: CPTColor.whiteColor())
        legendLineStyle.lineColor = CPTColor.whiteColor()
        theLegend.borderLineStyle = legendLineStyle
        theLegend.numberOfColumns = 1
        theLegend.numberOfRows = 4
        
        theLegendHeartRate.fill = CPTFill(color: CPTColor.whiteColor())
        theLegendHeartRate.borderLineStyle = legendLineStyle
        theLegendHeartRate.numberOfColumns = 1
        theLegendHeartRate.numberOfRows = 4
        
        // Set attributes legend
        // Attributes to the axis titles
        var attrsLegend:[String : AnyObject]?
        
        theLegend.cornerRadius = 10.0
        theLegend.swatchSize = CGSizeMake(20.0, 20.0)
        theLegend.backgroundColor = UIColor.groupTableViewBackgroundColor().CGColor
        
        theLegendHeartRate.cornerRadius = 10.0
        theLegendHeartRate.swatchSize = CGSizeMake(50.0, 30.0)
        //theLegendHeartRate.backgroundColor = UIColor.groupTableViewBackgroundColor().CGColor
        
        pressuresGraph.legendDisplacement = CGPointMake(370.0, -25.0)
        heartRateGraph.legendDisplacement = CGPointMake(370.0, -25.0)
        
        attrsLegend = [
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 16)!,
            
        ]
        
        theLegend.textStyle = CPTTextStyle(attributes: attrsLegend)
        
        pressuresGraph.legend = theLegend
        pressuresGraph.legendAnchor = CPTRectAnchor.TopLeft
        pressureContainerGraph.userInteractionEnabled = true
        
        theLegendHeartRate.textStyle = CPTTextStyle(attributes: attrsLegend)
        
        heartRateGraph.legend = theLegendHeartRate
        heartRateGraph.legendAnchor = CPTRectAnchor.TopLeft
        heartRateContainerGraph.userInteractionEnabled = true
    }
    
    func insertPoint(){
        
        contador = contador + 0.01
        x.append(Double(contador))
        y.append(Double(contador))
        //print(contador)
        if x.count == 40{
            
            contador = 0.0
            x = [0.0,0.01]
            
            y = [0.0,0.01]
            
        }
        pressuresGraph.removePlot(plot)
        pressuresGraph.removePlot(plot1)
        pressuresGraph.removePlot(plot2)
        
        pressuresGraph.addPlot(plot)
        pressuresGraph.addPlot(plot1)
        pressuresGraph.addPlot(plot2)
        
        pressuresGraph.reloadData()
        
        heartRateGraph.removePlot(plot3)
        heartRateGraph.addPlot(plot3)
        heartRateGraph.reloadData()
        uploadToServerDataBaseSQL(contador,diastolicPressure: (contador+1),mediumPressure: (contador+2),heartRate: (contador+3))
    }
    
    func uploadToServerDataBaseSQL(systolicPressure: Double,diastolicPressure: Double,mediumPressure: Double,heartRate: Double){
        
        /*
        let postString = "a=\(systolicPressure)&b=\(diastolicPressure)&c=\(mediumPressure)&d=\(heartRate)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            print("response = \(response)")
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        task.resume()*/
    }


}

