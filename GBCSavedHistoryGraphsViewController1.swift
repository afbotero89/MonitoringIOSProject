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
        
        DispatchQueue.main.async(execute: {
            // code here
        
        self.title = NSLocalizedString("Historical", comment: "")
            
        // Do any additional setup after loading the view, typically from a nib.
        self.systolicPressurePlot.identifier = 4 as (NSCoding & NSCopying & NSObjectProtocol)?
        self.diastolicPressurePlot.identifier = 5 as (NSCoding & NSCopying & NSObjectProtocol)?
        self.averagePressurePlot.identifier = 6 as (NSCoding & NSCopying & NSObjectProtocol)?
        self.heartRatePressurePlot.identifier = 7 as (NSCoding & NSCopying & NSObjectProtocol)?
        
        // Set the lineStyle for the plot
        self.systolicPressurePlot.dataSource = self
        self.diastolicPressurePlot.dataSource = self
        self.averagePressurePlot.dataSource = self
        self.heartRatePressurePlot.dataSource = self
        
        // Plot simbol
        let lowSymbol = CPTPlotSymbol.ellipse()
        lowSymbol.fill = CPTFill(color: CPTColor.black())
            
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
            NSForegroundColorAttributeName : UIColor.black,
            NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 16)!,
                
        ]
            
        self.pressuresGraph.title = NSLocalizedString("Pressure graphics", comment: "")
        self.pressuresGraph.titleTextStyle = CPTTextStyle(attributes: attrs)
        self.heartRateGraph.title = NSLocalizedString("Heart rate graphic", comment: "")
        self.heartRateGraph.titleTextStyle = CPTTextStyle(attributes: attrs)
            
        self.pressuresGraph.add(self.systolicPressurePlot)
        self.pressuresGraph.add(self.diastolicPressurePlot)
        self.pressuresGraph.add(self.averagePressurePlot)
        self.heartRateGraph.add(self.heartRatePressurePlot)
        
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
        let areaGradient = CPTGradient(beginning: areaColor.withAlphaComponent(0.2), ending: CPTColor.clear())
        areaGradient.angle = -90
        let areaGradientFill = CPTFill.init(gradient: areaGradient)
            //CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
        self.systolicPressurePlot.areaFill = areaGradientFill
        self.systolicPressurePlot.areaBaseValue = 0
            
        self.heartRatePressurePlot.areaFill = areaGradientFill
        self.heartRatePressurePlot.areaBaseValue = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
 
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {

        
    }
    func addAttributesToContainerGraph(){
        
        // Add gradient layer
        let color1 = UIColor.white.cgColor
        let color2 = UIColor(red: 0/255, green: 64/255, blue: 128/255, alpha: 0.7).cgColor
        
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.1, 1]
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        
        view.layer.insertSublayer(gradientLayer, at:0)
        
        // attributes pressure container
        pressureContainerGraph.layer.borderWidth = 0
        pressureContainerGraph.layer.borderColor = UIColor.black.cgColor
        pressureContainerGraph.layer.cornerRadius = 20
        pressureContainerGraph.hostedGraph = pressuresGraph
        
        // attributes heart rate container graph
        heartRateContainerGraph.layer.borderWidth = 0
        heartRateContainerGraph.layer.borderColor = UIColor.black.cgColor
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
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation))
        {
            // Portrait
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 50, y: 140, width: 650, height: 400)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 50, y: 550, width: 650, height: 400)
                
            case .iPhone:
                
                pressuresGraph.legendDisplacement = CGPoint(x: CGFloat(graphicsEnabledWidth!/1.8), y: -20.0)
                
                heartRateGraph.legendDisplacement = CGPoint(x: CGFloat(graphicsEnabledWidth!/1.8), y: -20.0)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 0, y: 120, width: Int(graphicsEnabledWidth!), height: Int(graphicsEnabledHeight!/2) + 15)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 0, y: Int(graphicsEnabledHeight!/2) + 140, width: Int(graphicsEnabledWidth!), height: Int(graphicsEnabledHeight!/2) + 15)
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
                
                pressuresGraph.legendDisplacement = CGPoint(x: CGFloat(graphicsEnabledWidth!/4), y: -20.0)
                
                heartRateGraph.legendDisplacement = CGPoint(x: CGFloat(graphicsEnabledWidth!/4), y: -20.0)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 20, y: 100, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!) + 20)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: Int(graphicsEnabledWidth!/2) + 10, y: 100, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!) + 20)
            }
            
        }
        
    }

    
    func setLegendGraph(){
        // Set legend pressure graph
        let theLegend=CPTLegend(graph: pressuresGraph)
        let theLegendHeartRate=CPTLegend(graph: heartRateGraph)
        
        let legendLineStyle = CPTMutableLineStyle()
        theLegend.fill = CPTFill(color: CPTColor.white())
        legendLineStyle.lineColor = CPTColor.white()
        theLegend.borderLineStyle = legendLineStyle
        theLegend.numberOfColumns = 1
        theLegend.numberOfRows = 4
        
        theLegendHeartRate.fill = CPTFill(color: CPTColor.white())
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
            theLegend.swatchSize = CGSize(width: 20.0, height: 20.0)
            theLegendHeartRate.swatchSize = CGSize(width: 50.0, height: 30.0)
            pressuresGraph.legendDisplacement = CGPoint(x: 450.0, y: -25.0)
            heartRateGraph.legendDisplacement = CGPoint(x: 450.0, y: -25.0)
            attrsLegend = [
                NSForegroundColorAttributeName : UIColor.black,
                NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 16)!,
                
            ]
        case .iPhone:
            theLegend.swatchSize = CGSize(width: 20.0, height: 7.0)
            theLegendHeartRate.swatchSize = CGSize(width: 50.0, height: 30.0)
            attrsLegend = [
                NSForegroundColorAttributeName : UIColor.black,
                NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 12)!,
                
            ]
        }

        theLegend.textStyle = CPTTextStyle(attributes: attrsLegend)
        
        pressuresGraph.legend = theLegend
        pressuresGraph.legendAnchor = CPTRectAnchor.topLeft
        pressureContainerGraph.isUserInteractionEnabled = true
        
        theLegendHeartRate.textStyle = CPTTextStyle(attributes: attrsLegend)
        
        heartRateGraph.legend = theLegendHeartRate
        heartRateGraph.legendAnchor = CPTRectAnchor.topLeft
        heartRateContainerGraph.isUserInteractionEnabled = true
    }
    
    func insertGraph(){
        
        pressuresGraph.plot(withIdentifier: 4 as NSCopying?)?.insertData(at: UInt(VectorPhysiologicalVariables.systolicPressure.count-1), numberOfRecords: 1)
        pressuresGraph.plot(withIdentifier: 5 as NSCopying?)?.insertData(at: UInt(VectorPhysiologicalVariables.diastolicPressure.count-1), numberOfRecords: 1)
        pressuresGraph.plot(withIdentifier: 6 as NSCopying?)?.insertData(at: UInt(VectorPhysiologicalVariables.averagePressure.count-1), numberOfRecords: 1)
        heartRateGraph.plot(withIdentifier: 7 as NSCopying?)?.insertData(at: UInt(VectorPhysiologicalVariables.heartRate.count-1), numberOfRecords: 1)
        
    }
    
    func scatterPlot(_ plot: CPTScatterPlot, plotSymbolWasSelectedAtRecordIndex index: Int, withEvent event: UIEvent) {
    
    }
    
    func autoSetXYGraph(){
        let plotSpacePressureGraph = pressuresGraph.defaultPlotSpace as! CPTXYPlotSpace
        let plotSpaceHeartRateGraph = heartRateGraph.defaultPlotSpace as! CPTXYPlotSpace
        
        plotSpacePressureGraph.yRange = CPTPlotRange(location: 0, length: 200)
        plotSpaceHeartRateGraph.yRange = CPTPlotRange(location: 0, length: 200)
        
        if PhysiologicalVariablesStoredInDatabaseSQL.hour.count>6{
            let startXRange = (PhysiologicalVariablesStoredInDatabaseSQL.hour.count - 3)/10
            
            plotSpacePressureGraph.xRange = CPTPlotRange(location: NSNumber(value: startXRange), length: 1)
            plotSpaceHeartRateGraph.xRange = CPTPlotRange(location: NSNumber(value: startXRange), length: 1)
            
        }else{
            plotSpacePressureGraph.xRange = CPTPlotRange(location: 0, length: 1)
            plotSpaceHeartRateGraph.xRange = CPTPlotRange(location: 0, length: 1)
        }
    }

    @IBAction func autoSetXYButton(_ sender: AnyObject) {
        autoSetXYGraph()
    }
}
