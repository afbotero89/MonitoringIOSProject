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

class ViewController: GBCPlotsViewController, UIPopoverPresentationControllerDelegate  {
    
    var contador = 0.0
    
    var timer:NSTimer?
    
    let systolicPressurePlot = CPTScatterPlot()
    
    let diastolicPressurePlot = CPTScatterPlot()
    
    let averagePressurePlot = CPTScatterPlot()
    
    let heartRatePressurePlot = CPTScatterPlot()
    
    var pressureContainerGraph = CPTGraphHostingView()
    
    var heartRateContainerGraph = CPTGraphHostingView()
    
    let request = NSMutableURLRequest(URL: NSURL(string:"http://www.sibxe.co/appMonitoreo/querysToDatabase.php")!)
    
    var bluetoothManager:BluetoothManager!
    
    let labelPressure = UILabel()
    
    let labelHeartRate = UILabel()
    
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the bluetooth manager.
        self.bluetoothManager = BluetoothManager()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(ViewController.insertPoint),
                                                         
                                                         name: "insertNewPlot",
                                                         
                                                         object: nil)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        systolicPressurePlot.identifier = 1
        diastolicPressurePlot.identifier = 2
        averagePressurePlot.identifier = 3
        heartRatePressurePlot.identifier = 4
        
        // Set the lineStyle for the plot
        systolicPressurePlot.dataSource = self
        diastolicPressurePlot.dataSource = self
        averagePressurePlot.dataSource = self
        heartRatePressurePlot.dataSource = self
        let plotLineStyle = systolicPressurePlot.dataLineStyle!.mutableCopy() as! CPTMutableLineStyle
        plotLineStyle.lineWidth = 2.5
        plotLineStyle.lineColor = CPTColor(componentRed: 162/255, green: 0/255, blue: 37/255, alpha: 1.0)
        systolicPressurePlot.dataLineStyle = plotLineStyle
        
        systolicPressurePlot.title = "Systolic pressure"
        diastolicPressurePlot.title = "Diastolic pressure"
        averagePressurePlot.title = "Average pressure"
        heartRatePressurePlot.title = "Heart rate"
        
        pressuresGraph.addPlot(systolicPressurePlot)
        pressuresGraph.addPlot(diastolicPressurePlot)
        pressuresGraph.addPlot(averagePressurePlot)
        heartRateGraph.addPlot(heartRatePressurePlot)
        
        //timer = NSTimer.scheduledTimerWithTimeInterval(0.002, target: self, selector: #selector(ViewController.insertPoint), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
        

        setLegendGraph()
        
        addAttributesToContainerGraph()
        
        addAttributesToViewController()
        
        request.HTTPMethod = "POST"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func addAttributesToContainerGraph(){
        // Labe1: pressure value
        labelPressure.frame = CGRect(x: 500, y: 300, width: 190, height: 160)
        labelPressure.numberOfLines = 10
        labelPressure.text = "Last messure \n\nSystolic:\n\n Diastolic:\n\n Average:"
        labelPressure.textColor = UIColor.whiteColor()
        labelPressure.backgroundColor =  UIColor(red: 11/255, green: 44/255, blue: 65/255, alpha: 0.7)
        
        // Label2: heart rate value
        
        labelHeartRate.frame = CGRect(x: 500, y: 850, width: 190, height: 80)
        labelHeartRate.numberOfLines = 10
        labelHeartRate.text = "Last messure \n\nHeart Rate:"
        labelHeartRate.textColor = UIColor.whiteColor()
        labelHeartRate.backgroundColor =  UIColor(red: 11/255, green: 44/255, blue: 65/255, alpha: 0.7)
        
        // attributes pressure container
        pressureContainerGraph.frame = CGRect(x: 50, y: 80, width: 650, height: 450)
        pressureContainerGraph.layer.borderWidth = 1
        pressureContainerGraph.layer.borderColor = UIColor.blackColor().CGColor
        pressureContainerGraph.layer.cornerRadius = 20
        pressureContainerGraph.hostedGraph = pressuresGraph
        
        // attributes heart rate container graph
        heartRateContainerGraph.frame = CGRect(x: 50, y: 550, width: 650, height: 450)
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
    
    func addAttributesToViewController(){
        // 1
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        
        // 2
        let color1 = UIColor.clearColor().CGColor as CGColorRef
        let color2 = UIColor(white: 0.0, alpha: 0.2).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2]
        
        // 3
        gradientLayer.locations = [0.0, 0.5]
        
        // 4
        self.view.layer.addSublayer(gradientLayer)

        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 64/255, blue: 128/255, alpha: 1.0)
        
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
        //theLegend.backgroundColor = UIColor.groupTableViewBackgroundColor().CGColor
        
        theLegendHeartRate.cornerRadius = 10.0
        theLegendHeartRate.swatchSize = CGSizeMake(50.0, 30.0)
        //theLegendHeartRate.backgroundColor = UIColor.groupTableViewBackgroundColor().CGColor
        
        pressuresGraph.legendDisplacement = CGPointMake(450.0, -25.0)
        heartRateGraph.legendDisplacement = CGPointMake(450.0, -25.0)
        
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
        pressuresGraph.removePlot(systolicPressurePlot)
        pressuresGraph.removePlot(diastolicPressurePlot)
        pressuresGraph.removePlot(averagePressurePlot)
        
        pressuresGraph.addPlot(systolicPressurePlot)
        pressuresGraph.addPlot(diastolicPressurePlot)
        pressuresGraph.addPlot(averagePressurePlot)
        
        pressuresGraph.reloadData()
        
        heartRateGraph.removePlot(heartRatePressurePlot)
        heartRateGraph.addPlot(heartRatePressurePlot)
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

    @IBAction func configurationButton(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let documentationTableViewController = storyboard.instantiateViewControllerWithIdentifier("sliderConfiguration")
        documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = documentationTableViewController.popoverPresentationController!
        documentationTableViewController.preferredContentSize = CGSizeMake(400,350)
        
        popover.permittedArrowDirections = .Any
        
        // Depending on the source, set the popover properties accordingly.
        if let barButtonItem = sender as? UIBarButtonItem{
            popover.barButtonItem = barButtonItem
        } else if let view = sender as? UIView{
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
        popover.delegate = self
        self.presentViewController(documentationTableViewController, animated: true, completion: nil)
    }

    @IBAction func generalInformation(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let documentationTableViewController = storyboard.instantiateViewControllerWithIdentifier("generalInformation")
        documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = documentationTableViewController.popoverPresentationController!
        documentationTableViewController.preferredContentSize = CGSizeMake(400,150)
        
        popover.permittedArrowDirections = .Any
        
        // Depending on the source, set the popover properties accordingly.
        if let barButtonItem = sender as? UIBarButtonItem{
            popover.barButtonItem = barButtonItem
        } else if let view = sender as? UIView{
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
        popover.delegate = self
        self.presentViewController(documentationTableViewController, animated: true, completion: nil)
    }
}

