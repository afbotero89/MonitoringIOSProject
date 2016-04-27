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
    /// Physiological variables container
    let physiologicalVariablesContainer = CPTGraphHostingView()
    
    var timer:NSTimer?
    
    let plot = CPTScatterPlot()
    
    let plot1 = CPTScatterPlot()
    
    let plot2 = CPTScatterPlot()
    
    let plot3 = CPTScatterPlot()
    
    var containerGraph = CPTGraphHostingView()
    
    let request = NSMutableURLRequest(URL: NSURL(string: "http://www.sibxe.co/appMonitoreo/querysToDatabase.php")!)
    
    var bluetoothManager:BluetoothManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the bluetooth manager.
        self.bluetoothManager = BluetoothManager()
        
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
        newGraph.addPlot(plot)
        newGraph.addPlot(plot1)
        newGraph.addPlot(plot2)
        newGraph.addPlot(plot3)
        containerGraph.frame = CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: 600)
        containerGraph.layer.borderWidth = 1
        containerGraph.layer.borderColor = UIColor.blackColor().CGColor
        containerGraph.layer.cornerRadius = 20
        containerGraph.hostedGraph = newGraph
        
        // Set legend
        let theLegend=CPTLegend(graph: newGraph)
        let legendLineStyle = CPTMutableLineStyle()
        theLegend.fill = CPTFill(color: CPTColor.whiteColor())
        legendLineStyle.lineColor = CPTColor.whiteColor()
        theLegend.borderLineStyle = legendLineStyle
        theLegend.numberOfColumns = 1
        theLegend.numberOfRows = 4
        
        // Set attributes legend
        // Attributes to the axis titles
        var attrsLegend:[String : AnyObject]?
        
        
        theLegend.cornerRadius = 10.0
        theLegend.swatchSize = CGSizeMake(20.0, 20.0)
        newGraph.legendDisplacement = CGPointMake(500.0, -45.0)
        attrsLegend = [
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 16)!,
            
        ]
        
        theLegend.textStyle = CPTTextStyle(attributes: attrsLegend)
        
        newGraph.legend = theLegend
        newGraph.legendAnchor = CPTRectAnchor.TopLeft
        
        view.addSubview(containerGraph)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.insertPoint), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
        
        request.HTTPMethod = "POST"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func insertPoint(){
        
        contador = contador + 0.01
        x.append(Double(contador))
        y.append(Double(contador))
        if x.count == 40{
            contador = 0.0
            x = [0.0,0.01]
            
            y = [0.0,0.01]
        }
        newGraph.addPlot(plot)
        newGraph.addPlot(plot1)
        newGraph.addPlot(plot2)
        newGraph.addPlot(plot3)
        newGraph.reloadData()
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

