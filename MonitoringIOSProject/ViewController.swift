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
    
    var containerGraph = CPTGraphHostingView()
    
    let request = NSMutableURLRequest(URL: NSURL(string: "http://www.sibxe.co/appMonitoreo/querysToDatabase.php")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        plot.identifier = 1
        plot1.identifier = 2
        // Set the lineStyle for the plot
        plot.dataSource = self
        plot1.dataSource = self
        let plotLineStyle = plot.dataLineStyle!.mutableCopy() as! CPTMutableLineStyle
        plotLineStyle.lineWidth = 2.5
        plotLineStyle.lineColor = CPTColor(componentRed: 162/255, green: 0/255, blue: 37/255, alpha: 1.0)
        plot.dataLineStyle = plotLineStyle
        newGraph.addPlot(plot)
        newGraph.addPlot(plot1)
        containerGraph.hostedGraph = newGraph
        containerGraph.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        //view.addSubview(containerGraph)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(ViewController.insertPoint), userInfo: nil, repeats: true)
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
        newGraph.reloadData()
        uploadToServerDataBaseSQL(contador,diastolicPressure: (contador+1),mediumPressure: (contador+2),heartRate: (contador+3))
    }
    
    func uploadToServerDataBaseSQL(systolicPressure: Double,diastolicPressure: Double,mediumPressure: Double,heartRate: Double){
        
        
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
        task.resume()
    }


}

