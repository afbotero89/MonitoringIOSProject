//
//  GBCSavedHistoryGraphsViewController1.swift
//  MonitoringIOSProject
//
//  Created by Felipe Botero on 16/05/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

class GBCSavedHistoryGraphsViewController1: GBCPlotsViewController {

    @IBOutlet weak var titleLabelUserSelectedDate: UILabel!
    
    let systolicPressurePlot = CPTScatterPlot()
    
    let diastolicPressurePlot = CPTScatterPlot()
    
    let averagePressurePlot = CPTScatterPlot()
    
    let heartRatePressurePlot = CPTScatterPlot()
    
    var pressureContainerGraph = CPTGraphHostingView()
    
    var heartRateContainerGraph = CPTGraphHostingView()
    
    let gradientLayer = CAGradientLayer()
    
    var graphicsEnabledHeight:Double?
    
    var graphicsEnabledWidth:Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_async(dispatch_get_main_queue(), {
            // code here
        
        self.title = NSLocalizedString("Historical", comment: "")
            
        // Do any additional setup after loading the view, typically from a nib.
        self.systolicPressurePlot.identifier = 4
        self.diastolicPressurePlot.identifier = 5
        self.averagePressurePlot.identifier = 6
        self.heartRatePressurePlot.identifier = 7
        
        // Set the lineStyle for the plot
        self.systolicPressurePlot.dataSource = self
        self.diastolicPressurePlot.dataSource = self
        self.averagePressurePlot.dataSource = self
        self.heartRatePressurePlot.dataSource = self
        
        // Plot simbol
        let lowSymbol = CPTPlotSymbol.ellipsePlotSymbol()
        lowSymbol.fill = CPTFill(color: CPTColor.blackColor())
            
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            lowSymbol.size = CGSize(width: 6, height: 6) //Inflection point size
        case .iPhone:
            lowSymbol.size = CGSize(width: 3, height: 3) //Inflection point size
        }
        
        self.averagePressurePlot.plotSymbol = lowSymbol
        // Sensitivity level when the user touches the symbol
        self.systolicPressurePlot.plotSymbolMarginForHitDetection = 20
        self.diastolicPressurePlot.plotSymbolMarginForHitDetection = 20
        self.averagePressurePlot.plotSymbolMarginForHitDetection = 20
        self.heartRatePressurePlot.plotSymbolMarginForHitDetection = 20
        
        let plotLineStyle = self.systolicPressurePlot.dataLineStyle!.mutableCopy() as! CPTMutableLineStyle
        plotLineStyle.lineWidth = 1.5
        
        plotLineStyle.lineColor = CPTColor(componentRed: 162/255, green: 0/255, blue: 37/255, alpha: 1.0)
        self.systolicPressurePlot.dataLineStyle = plotLineStyle
        lowSymbol.fill = CPTFill(color: CPTColor(componentRed: 162/255, green: 0/255, blue: 37/255, alpha: 1.0))
        self.systolicPressurePlot.plotSymbol = lowSymbol
        
        plotLineStyle.lineColor = CPTColor(componentRed: 0, green: 64/255, blue: 128/255, alpha: 1.0)
        lowSymbol.fill = CPTFill(color: CPTColor(componentRed: 0, green: 64/255, blue: 128/255, alpha: 1.0))
        self.diastolicPressurePlot.dataLineStyle = plotLineStyle
        self.diastolicPressurePlot.plotSymbol = lowSymbol
        
        plotLineStyle.lineColor = CPTColor(componentRed:0/255, green:128/255,blue:128/255,alpha:0.9)
        lowSymbol.fill = CPTFill(color: CPTColor(componentRed:0/255, green:128/255,blue:128/255,alpha:0.9))
        self.heartRatePressurePlot.dataLineStyle = plotLineStyle
        self.heartRatePressurePlot.plotSymbol = lowSymbol
        
        self.systolicPressurePlot.title = NSLocalizedString("Systolic pressure", comment: "")
        self.diastolicPressurePlot.title = NSLocalizedString("Diastolic pressure", comment: "")
        self.averagePressurePlot.title = NSLocalizedString("Average pressure", comment: "")
        self.heartRatePressurePlot.title = NSLocalizedString("Heart rate", comment: "")
        
        let attrs = [
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 16)!,
                
        ]
            
        self.pressuresGraph.title = NSLocalizedString("Pressure graphics", comment: "")
        self.pressuresGraph.titleTextStyle = CPTTextStyle(attributes: attrs)
        self.heartRateGraph.title = NSLocalizedString("Heart rate graphic", comment: "")
        self.heartRateGraph.titleTextStyle = CPTTextStyle(attributes: attrs)
            
        self.pressuresGraph.addPlot(self.systolicPressurePlot)
        self.pressuresGraph.addPlot(self.diastolicPressurePlot)
        self.pressuresGraph.addPlot(self.averagePressurePlot)
        self.heartRateGraph.addPlot(self.heartRatePressurePlot)
        
        let plotSpacePressureGraph = self.pressuresGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpacePressureGraph.yRange = CPTPlotRange(location: 0, length: 200)
        
        let plotSpaceHeartRateGraph = self.heartRateGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpaceHeartRateGraph.yRange = CPTPlotRange(location: 0, length: 200)
        
        self.setLegendGraph()
        
        self.addAttributesToContainerGraph()
        
        self.autoSetXYGraph()
        
        self.titleLabelUserSelectedDate.text = PhysiologicalVariablesStoredInDatabaseSQL.dateSelectedByTheUser
        // Do any additional setup after loading the view.
            
        
        // Color gradient is added under the scatter plot

        let areaColor = CPTColor(componentRed: 0/255, green: 64/255, blue: 128/255, alpha: 0.1)
        let areaGradient = CPTGradient(beginningColor: areaColor.colorWithAlphaComponent(0.2), endingColor: CPTColor.clearColor())
        areaGradient.angle = -90
        let areaGradientFill = CPTFill.init(gradient: areaGradient)
            //CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
        self.systolicPressurePlot.areaFill = areaGradientFill
        self.systolicPressurePlot.areaBaseValue = 0
            
        self.heartRatePressurePlot.areaFill = areaGradientFill
        self.heartRatePressurePlot.areaBaseValue = 0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.deviceRotated), name: UIDeviceOrientationDidChangeNotification, object: nil)
 
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {

        
    }
    func addAttributesToContainerGraph(){
        
        // Add gradient layer
        let color1 = UIColor.whiteColor().CGColor
        let color2 = UIColor(red: 0/255, green: 64/255, blue: 128/255, alpha: 0.7).CGColor
        
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.1, 1]
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        
        view.layer.insertSublayer(gradientLayer, atIndex:0)
        
        // attributes pressure container
        pressureContainerGraph.layer.borderWidth = 0
        pressureContainerGraph.layer.borderColor = UIColor.blackColor().CGColor
        pressureContainerGraph.layer.cornerRadius = 20
        pressureContainerGraph.hostedGraph = pressuresGraph
        
        // attributes heart rate container graph
        heartRateContainerGraph.layer.borderWidth = 0
        heartRateContainerGraph.layer.borderColor = UIColor.blackColor().CGColor
        heartRateContainerGraph.layer.cornerRadius = 20
        heartRateContainerGraph.hostedGraph = heartRateGraph
        
        // Function call to determine the orientation of the device
        deviceRotated()
        
        // Insert subviews
        view.addSubview(pressureContainerGraph)
        view.addSubview(heartRateContainerGraph)
        
    }
    
    func deviceRotated(){
        
        // 2*navigationController, because navigation bar and button bar
        graphicsEnabledHeight = Double(view.frame.height) - 4*40
        
        graphicsEnabledWidth = Double(view.frame.width)
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            // Portrait
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 50, y: 140, width: 650, height: 400)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 50, y: 550, width: 650, height: 400)
                
            case .iPhone:
                
                pressuresGraph.legendDisplacement = CGPointMake(CGFloat(graphicsEnabledWidth!/1.8), -20.0)
                
                heartRateGraph.legendDisplacement = CGPointMake(CGFloat(graphicsEnabledWidth!/1.8), -20.0)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 10, y: 120, width: Int(graphicsEnabledWidth!) - 20, height: Int(graphicsEnabledHeight!/2))
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 10, y: Int(graphicsEnabledHeight!/2) + 130, width: Int(graphicsEnabledWidth!) - 20, height: Int(graphicsEnabledHeight!/2))
            }
            
        }else{
            
            // Landscape
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 230, y: 120, width: 650, height: 300)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 230, y: 440, width: 650, height: 300)
                
            case .iPhone:
                
                pressuresGraph.legendDisplacement = CGPointMake(CGFloat(graphicsEnabledWidth!/4), -20.0)
                
                heartRateGraph.legendDisplacement = CGPointMake(CGFloat(graphicsEnabledWidth!/4), -20.0)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 20, y: 100, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: Int(graphicsEnabledWidth!/2) + 10, y: 100, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
            }
            
        }
        
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
        
        //theLegend.backgroundColor = UIColor.groupTableViewBackgroundColor().CGColor
        
        theLegendHeartRate.cornerRadius = 10.0
        
        //theLegendHeartRate.backgroundColor = UIColor.groupTableViewBackgroundColor().CGColor
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            theLegend.swatchSize = CGSizeMake(20.0, 20.0)
            theLegendHeartRate.swatchSize = CGSizeMake(50.0, 30.0)
            pressuresGraph.legendDisplacement = CGPointMake(450.0, -25.0)
            heartRateGraph.legendDisplacement = CGPointMake(450.0, -25.0)
            attrsLegend = [
                NSForegroundColorAttributeName : UIColor.blackColor(),
                NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 16)!,
                
            ]
        case .iPhone:
            theLegend.swatchSize = CGSizeMake(20.0, 7.0)
            theLegendHeartRate.swatchSize = CGSizeMake(50.0, 30.0)
            attrsLegend = [
                NSForegroundColorAttributeName : UIColor.blackColor(),
                NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 12)!,
                
            ]
        }

        theLegend.textStyle = CPTTextStyle(attributes: attrsLegend)
        
        pressuresGraph.legend = theLegend
        pressuresGraph.legendAnchor = CPTRectAnchor.TopLeft
        pressureContainerGraph.userInteractionEnabled = true
        
        theLegendHeartRate.textStyle = CPTTextStyle(attributes: attrsLegend)
        
        heartRateGraph.legend = theLegendHeartRate
        heartRateGraph.legendAnchor = CPTRectAnchor.TopLeft
        heartRateContainerGraph.userInteractionEnabled = true
    }
    
    func insertGraph(){
        
        pressuresGraph.plotWithIdentifier(4)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.systolicPressure.count-1), numberOfRecords: 1)
        pressuresGraph.plotWithIdentifier(5)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.diastolicPressure.count-1), numberOfRecords: 1)
        pressuresGraph.plotWithIdentifier(6)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.averagePressure.count-1), numberOfRecords: 1)
        heartRateGraph.plotWithIdentifier(7)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.heartRate.count-1), numberOfRecords: 1)
        
    }
    
    func scatterPlot(plot: CPTScatterPlot, plotSymbolWasSelectedAtRecordIndex index: Int, withEvent event: UIEvent) {
    
    }
    
    func autoSetXYGraph(){
        let plotSpacePressureGraph = pressuresGraph.defaultPlotSpace as! CPTXYPlotSpace
        let plotSpaceHeartRateGraph = heartRateGraph.defaultPlotSpace as! CPTXYPlotSpace
        
        plotSpacePressureGraph.yRange = CPTPlotRange(location: 0, length: 200)
        plotSpaceHeartRateGraph.yRange = CPTPlotRange(location: 0, length: 200)
        
        if PhysiologicalVariablesStoredInDatabaseSQL.hour.count>6{
            let startXRange = (PhysiologicalVariablesStoredInDatabaseSQL.hour.count - 3)/10
            
            plotSpacePressureGraph.xRange = CPTPlotRange(location: startXRange, length: 1)
            plotSpaceHeartRateGraph.xRange = CPTPlotRange(location: startXRange, length: 1)
            
        }else{
            plotSpacePressureGraph.xRange = CPTPlotRange(location: 0, length: 1)
            plotSpaceHeartRateGraph.xRange = CPTPlotRange(location: 0, length: 1)
        }
    }

    @IBAction func autoSetXYButton(sender: AnyObject) {
        autoSetXYGraph()
    }
}
