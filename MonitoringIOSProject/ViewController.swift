//
//  ViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 27/4/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit


class ViewController: GBCPlotsViewController, UIPopoverPresentationControllerDelegate  {
    
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
    
    var graphicsEnabledHeight:Double?
    
    var graphicsEnabledWidth:Double?
    
    @IBOutlet weak var currentMeasurementLabel: UIButton!
    
    @IBOutlet weak var statusConnectionLabel: UILabel!
    
    @IBOutlet weak var imageStatusConnection: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the bluetooth manager.
        self.bluetoothManager = BluetoothManager()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(ViewController.insertPoint),
                                                         
                                                         name: "insertNewPlot",
                                                         
                                                         object: nil)
        
        // Watch Bluetooth connection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: BLEServiceChangedStatusNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.deviceRotated), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        systolicPressurePlot.identifier = 0
        diastolicPressurePlot.identifier = 1
        averagePressurePlot.identifier = 2
        heartRatePressurePlot.identifier = 3
        
        // Set the lineStyle for the plot
        systolicPressurePlot.dataSource = self
        diastolicPressurePlot.dataSource = self
        averagePressurePlot.dataSource = self
        heartRatePressurePlot.dataSource = self
        
        // Plot simbol
        let lowSymbol = CPTPlotSymbol.ellipsePlotSymbol()
        lowSymbol.fill = CPTFill(color: CPTColor.blackColor())
        lowSymbol.size = CGSize(width: 6, height: 6) //Inflection point size
    
        averagePressurePlot.plotSymbol = lowSymbol
        // Sensitivity level when the user touches the symbol
        systolicPressurePlot.plotSymbolMarginForHitDetection = 20
        diastolicPressurePlot.plotSymbolMarginForHitDetection = 20
        averagePressurePlot.plotSymbolMarginForHitDetection = 20
        heartRatePressurePlot.plotSymbolMarginForHitDetection = 20
        
        let plotLineStyle = systolicPressurePlot.dataLineStyle!.mutableCopy() as! CPTMutableLineStyle
        plotLineStyle.lineWidth = 1.5
        
        plotLineStyle.lineColor = CPTColor(componentRed: 162/255, green: 0/255, blue: 37/255, alpha: 1.0)
        systolicPressurePlot.dataLineStyle = plotLineStyle
        lowSymbol.fill = CPTFill(color: CPTColor(componentRed: 162/255, green: 0/255, blue: 37/255, alpha: 1.0))
        systolicPressurePlot.plotSymbol = lowSymbol
        
        plotLineStyle.lineColor = CPTColor(componentRed: 0, green: 64/255, blue: 128/255, alpha: 1.0)
        lowSymbol.fill = CPTFill(color: CPTColor(componentRed: 0, green: 64/255, blue: 128/255, alpha: 1.0))
        diastolicPressurePlot.dataLineStyle = plotLineStyle
        diastolicPressurePlot.plotSymbol = lowSymbol
        
        plotLineStyle.lineColor = CPTColor(componentRed:0/255, green:128/255,blue:128/255,alpha:0.9)
        lowSymbol.fill = CPTFill(color: CPTColor(componentRed:0/255, green:128/255,blue:128/255,alpha:0.9))
        heartRatePressurePlot.dataLineStyle = plotLineStyle
        heartRatePressurePlot.plotSymbol = lowSymbol
        
        systolicPressurePlot.title = "Systolic pressure"
        diastolicPressurePlot.title = "Diastolic pressure"
        averagePressurePlot.title = "Average pressure"
        heartRatePressurePlot.title = "Heart rate"
        
        pressuresGraph.addPlot(systolicPressurePlot)
        pressuresGraph.addPlot(diastolicPressurePlot)
        pressuresGraph.addPlot(averagePressurePlot)
        heartRateGraph.addPlot(heartRatePressurePlot)

        let plotSpacePressureGraph = pressuresGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpacePressureGraph.yRange = CPTPlotRange(location: 0, length: 200)
        
        let plotSpaceHeartRateGraph = heartRateGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpaceHeartRateGraph.yRange = CPTPlotRange(location: 0, length: 200)
        
        setLegendGraph()
        
        addAttributesToContainerGraph()
        
        addAttributesToViewController()
        
        request.HTTPMethod = "POST"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: BLEServiceChangedStatusNotification, object: nil)
    }
    
    func addAttributesToContainerGraph(){
        
        // Labe1: pressure value
        labelPressure.numberOfLines = 10
        labelPressure.text = "Last messure \n\nSystolic:\nDiastolic:\nAverage:"
        labelPressure.textColor = UIColor.whiteColor()
        labelPressure.backgroundColor =  UIColor(red: 11/255, green: 44/255, blue: 65/255, alpha: 0.7)
        
        // Label2: heart rate value
        labelHeartRate.numberOfLines = 10
        labelHeartRate.text = "Last messure \n\nHeart Rate:"
        labelHeartRate.textColor = UIColor.whiteColor()
        labelHeartRate.backgroundColor =  UIColor(red: 11/255, green: 44/255, blue: 65/255, alpha: 0.7)
        
        // attributes pressure container
        pressureContainerGraph.layer.borderWidth = 1
        pressureContainerGraph.layer.borderColor = UIColor.blackColor().CGColor
        pressureContainerGraph.layer.cornerRadius = 20
        pressureContainerGraph.hostedGraph = pressuresGraph
        pressureContainerGraph.addSubview(labelPressure)
        
        
        // attributes heart rate container graph
        heartRateContainerGraph.layer.borderWidth = 1
        heartRateContainerGraph.layer.borderColor = UIColor.blackColor().CGColor
        heartRateContainerGraph.layer.cornerRadius = 20
        heartRateContainerGraph.hostedGraph = heartRateGraph
        
        // Function call to determine the orientation of the device
        deviceRotated()
        
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
        
        currentMeasurementLabel.layer.cornerRadius = 10
        
        statusConnectionLabel.clipsToBounds = true
        statusConnectionLabel.layer.cornerRadius = 10
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

        pressuresGraph.plotWithIdentifier(0)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.systolicPressure.count-1), numberOfRecords: 1)
        pressuresGraph.plotWithIdentifier(1)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.diastolicPressure.count-1), numberOfRecords: 1)
        pressuresGraph.plotWithIdentifier(2)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.averagePressure.count-1), numberOfRecords: 1)
        heartRateGraph.plotWithIdentifier(3)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.heartRate.count-1), numberOfRecords: 1)
        
        // Label update with latest measures
        labelPressure.text = "Last messure \n\nSystolic: \(VectorPhysiologicalVariables.systolicPressure.last!) mmHg\nDiastolic: \(VectorPhysiologicalVariables.diastolicPressure.last!) mmHg\nAverage: \(VectorPhysiologicalVariables.averagePressure.last!) mmHg"
        labelHeartRate.text = "Last messure \n\nHeart Rate: \(VectorPhysiologicalVariables.heartRate.last!) BPM"
        
        //Change the x and y range.
        
        autoSetXYRangePressureGraphAndHeartRateGraph()
        
        uploadToServerDataBaseSQL(1,diastolicPressure: (1+1),mediumPressure: (1+2),heartRate: (1+3))
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
    
    func displayGeneralInformationPopPup(location:CGPoint, plotIdentifier: NSInteger, indexPoint:Int){
        
        // Display popup
        let storyboard = UIStoryboard(name: "AditionalInformationPopPup", bundle: nil)
        let additionalInformationPopup = storyboard.instantiateViewControllerWithIdentifier("aditionalInformationPopup") as! GBCAditionalInformationPopupViewController
        additionalInformationPopup.title = "General information"
        additionalInformationPopup.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        //let plotSelected = PhysiologicalVariables(rawValue: plotIdentifier)?.displayString()
        
        additionalInformationPopup.valueSystolicPressureString = String(VectorPhysiologicalVariables.systolicPressure[indexPoint]) + " mmHg"
        
        additionalInformationPopup.valueAveragePressureString = String(VectorPhysiologicalVariables.averagePressure[indexPoint]) + " mmHg"
        
        additionalInformationPopup.valueDiastolicPressureString = String(VectorPhysiologicalVariables.diastolicPressure[indexPoint]) + " mmHg"
        
        additionalInformationPopup.valueHeartRateString = String(VectorPhysiologicalVariables.heartRate[indexPoint]) + " BPM"
        
        additionalInformationPopup.measuringTimeString = VectorPhysiologicalVariables.measuringTime[indexPoint]
        
        let presentationController = additionalInformationPopup.popoverPresentationController!
        presentationController.permittedArrowDirections = UIPopoverArrowDirection.Any
        additionalInformationPopup.preferredContentSize = CGSize(width: 320, height: 250)
        presentationController.sourceView = self.view
        let rect = CGRect(x: location.x, y: location.y, width: 0, height: 0)
        presentationController.sourceRect = rect
        // Set this object as the delegate
        presentationController.delegate = self
        presentViewController(additionalInformationPopup, animated: true, completion: nil)
    }
    func connectionChanged(notification: NSNotification) {
        
        // Connection status changed. Indicate on GUI.
        let userInfo = notification.userInfo as! [String: Bool]
        
        dispatch_async(dispatch_get_main_queue(), {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    self.imageStatusConnection.image = UIImage(named: "Bluetooth_Connected")
                    self.statusConnectionLabel.text = "Connected"
                
                } else {
                    self.imageStatusConnection.image = UIImage(named: "Bluetooth_Disconnected")
                    self.statusConnectionLabel.text = "Disconnected"
                  
                }
            }
        });
    }
    
    func deviceRotated(){
        
        // 2*navigationController, because navigation bar and button bar
        graphicsEnabledHeight = Double(view.frame.height) - 4*Double((navigationController?.navigationBar.frame.height)!)
        
        graphicsEnabledWidth = Double(view.frame.width)
        
        print(graphicsEnabledHeight)
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            // Portrait
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                // Image status connection
                imageStatusConnection.frame = CGRect(x: 240, y: 80, width: 50, height: 50)
                
                // Status connection label
                statusConnectionLabel.frame = CGRect(x: 290, y: 80, width: 188, height: 41)
                
                // Labe1: pressure value
                labelPressure.frame = CGRect(x: 500, y: 360, width: 190, height: 120)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: 500, y: 800, width: 190, height: 80)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 50, y: 140, width: 650, height: 400)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 50, y: 550, width: 650, height: 400)
                
            case .iPhone:
                
                // Image status connection
                imageStatusConnection.frame = CGRect(x: 0, y: 80, width: 15, height: 15)
                
                // Status connection label
                statusConnectionLabel.frame = CGRect(x: 20, y: 80, width: 188, height: 21)
                
                // Labe1: pressure value
                labelPressure.frame = CGRect(x: 500, y: 360, width: 190, height: 120)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: 500, y: 800, width: 190, height: 80)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 10, y: 100, width: Int(graphicsEnabledWidth!) - 20, height: Int(graphicsEnabledHeight!/2))
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 10, y: 300, width: Int(graphicsEnabledWidth!) - 20, height: Int(graphicsEnabledHeight!/2))
            }
            
        }else{
            
            // Landscape
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                
                // Image status connection
                imageStatusConnection.frame = CGRect(x: 10, y: 140, width: 50, height: 50)
                
                // Status connection label
                statusConnectionLabel.frame = CGRect(x: 10, y: 80, width: 188, height: 41)
                
                // Labe1: pressure value
                labelPressure.frame = CGRect(x: 680, y: 200, width: 190, height: 120)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: 680, y: 550, width: 190, height: 80)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 230, y: 80, width: 650, height: 300)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 230, y: 390, width: 650, height: 300)

            case .iPhone:
                
                // Image status connection
                imageStatusConnection.frame = CGRect(x: 0, y: 80, width: 15, height: 15)
                
                // Status connection label
                statusConnectionLabel.frame = CGRect(x: 20, y: 80, width: 188, height: 21)
                
                // Labe1: pressure value
                labelPressure.frame = CGRect(x: 500, y: 360, width: 190, height: 120)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: 500, y: 800, width: 190, height: 80)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 20, y: 40, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 280, y: 40, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
            }
  
        }
 
    }


    @IBAction func configurationButton(sender: AnyObject) {
        
         NSNotificationCenter.defaultCenter().postNotificationName("writeValueToPeripheral", object: nil, userInfo: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let documentationTableViewController = storyboard.instantiateViewControllerWithIdentifier("sliderConfiguration")
        documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = documentationTableViewController.popoverPresentationController!
        documentationTableViewController.preferredContentSize = CGSizeMake(380,350)
        
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
    
    @IBAction func currentMeasurementButton(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let documentationTableViewController = storyboard.instantiateViewControllerWithIdentifier("currentMeasurement")
        documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = documentationTableViewController.popoverPresentationController!
        documentationTableViewController.preferredContentSize = CGSizeMake(500,650)
        
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
    
    @IBAction func autoSetGraph(sender: AnyObject) {
        //Change the x and y range.
        autoSetXYRangePressureGraphAndHeartRateGraph()
    }
    
    func autoSetXYRangePressureGraphAndHeartRateGraph(){
        
        let plotSpacePressureGraph = pressuresGraph.defaultPlotSpace as! CPTXYPlotSpace
        let plotSpaceHeartRateGraph = heartRateGraph.defaultPlotSpace as! CPTXYPlotSpace
        
        plotSpacePressureGraph.yRange = CPTPlotRange(location: 0, length: 200)
        plotSpaceHeartRateGraph.yRange = CPTPlotRange(location: 0, length: 200)
        
        if VectorPhysiologicalVariables.vectorNumberOfSamples.count>6{
            let startXRange = VectorPhysiologicalVariables.vectorNumberOfSamples[VectorPhysiologicalVariables.vectorNumberOfSamples.count-6]
            
            plotSpacePressureGraph.xRange = CPTPlotRange(location: startXRange, length: 1)
            plotSpaceHeartRateGraph.xRange = CPTPlotRange(location: startXRange, length: 1)
            
        }else{
            plotSpacePressureGraph.xRange = CPTPlotRange(location: 0, length: 1)
            plotSpaceHeartRateGraph.xRange = CPTPlotRange(location: 0, length: 1)
        }
    }
    
    func scatterPlot(plot: CPTScatterPlot, plotSymbolWasSelectedAtRecordIndex index: Int, withEvent event: UIEvent) {
        
        let touch = event.allTouches()?.first?.preciseLocationInView(self.view)
        displayGeneralInformationPopPup(touch!, plotIdentifier: plot.identifier as! NSInteger, indexPoint: index)
        
    }
    
}
extension ViewController{
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.FullScreen
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        let barButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(ViewController.dismissPopover(_:)))
        navController.topViewController!.navigationItem.rightBarButtonItem = barButtonItem
        return navController
    }
    /**
     Method called when the popover is dissmised programatically, after the user presses a button (iPhone)
     */
    func dismissPopover(sender:AnyObject){
        self.dismissViewControllerAnimated(true, completion: nil)
        
        print("dissmiss iPhone")
    }
    
    /**
     Method called after the popover is dissmissed by means of user interactions only (iPad).
     */
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        
        //Code
        //insertNewBarGraphExtubatedPatient()
        print("dissmiss iPad")
        
    }

}

