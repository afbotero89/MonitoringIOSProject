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
        
        
        // Do any additional setup after loading the view, typically from a nib.
        systolicPressurePlot.identifier = 4
        diastolicPressurePlot.identifier = 5
        averagePressurePlot.identifier = 6
        heartRatePressurePlot.identifier = 7
        
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
        
        autoSetXYGraph()
        
        titleLabelUserSelectedDate.text = PhysiologicalVariablesStoredInDatabaseSQL.dateSelectedByTheUser
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addAttributesToContainerGraph(){
        
        // attributes pressure container
        pressureContainerGraph.layer.borderWidth = 1
        pressureContainerGraph.layer.borderColor = UIColor.blackColor().CGColor
        pressureContainerGraph.layer.cornerRadius = 20
        pressureContainerGraph.hostedGraph = pressuresGraph
        
        
        
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
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 50, y: 140, width: 650, height: 400)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 50, y: 550, width: 650, height: 400)
                
            case .iPhone:
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 10, y: 100, width: Int(graphicsEnabledWidth!) - 20, height: Int(graphicsEnabledHeight!/2))
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 10, y: Int(graphicsEnabledHeight!/2) + 120, width: Int(graphicsEnabledWidth!) - 20, height: Int(graphicsEnabledHeight!/2))
            }
            
        }else{
            
            // Landscape
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 230, y: 80, width: 650, height: 300)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 230, y: 390, width: 650, height: 300)
                
            case .iPhone:
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 20, y: 40, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: Int(graphicsEnabledWidth!/2) + 10, y: 40, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
            }
            
        }
        
    }
    
    func autoSetXYRange(){
        
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
            pressuresGraph.legendDisplacement = CGPointMake(170.0, -5.0)
            heartRateGraph.legendDisplacement = CGPointMake(170.0, -5.0)
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
            let startXRange = (PhysiologicalVariablesStoredInDatabaseSQL.hour.count - 5)/10
            
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