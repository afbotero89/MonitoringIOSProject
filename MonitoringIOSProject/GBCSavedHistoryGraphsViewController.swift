//
//  GBCSavedHistoryGraphsViewController.swift
//  MonitoringIOSProject
//
//  Created by Felipe Botero on 15/05/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

class GBCSavedHistoryGraphsViewController: GBCPlotsViewController {

    let systolicPressurePlot = CPTScatterPlot()
    
    let diastolicPressurePlot = CPTScatterPlot()
    
    let averagePressurePlot = CPTScatterPlot()
    
    let heartRatePressurePlot = CPTScatterPlot()
    
    var pressureContainerGraph = CPTGraphHostingView()
    
    var heartRateContainerGraph = CPTGraphHostingView()
    
    let labelPressure = UILabel()
    
    let labelHeartRate = UILabel()
    
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
        
        addAttributesToContainerGraph()
        // Do any additional setup after loading the view.
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
    
    func deviceRotated(){
        
        // 2*navigationController, because navigation bar and button bar
        graphicsEnabledHeight = Double(20)
        
        graphicsEnabledWidth = Double(view.frame.width)
        
        print(graphicsEnabledHeight)
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            // Portrait
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                
                // Labe1: pressure value
                labelPressure.frame = CGRect(x: 500, y: 360, width: 190, height: 120)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: 500, y: 800, width: 190, height: 80)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 20, y: 50, width: self.view.frame.width - 60, height: 250)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 20, y: 310, width: self.view.frame.width - 60, height: 250)
                
            case .iPhone:
                
                // Labe1: pressure value
                labelPressure.frame = CGRect(x: 500, y: 360, width: 190, height: 120)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: 500, y: 800, width: 190, height: 80)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 10, y: 100, width: Int(graphicsEnabledWidth!) - 20, height: Int(graphicsEnabledHeight!/2))
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 10, y: Int(graphicsEnabledHeight!/2) + 120, width: Int(graphicsEnabledWidth!) - 20, height: Int(graphicsEnabledHeight!/2))
            }
            
        }else{
            
            // Landscape
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                
                // Labe1: pressure value
                labelPressure.frame = CGRect(x: 680, y: 200, width: 190, height: 120)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: 680, y: 550, width: 190, height: 80)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 230, y: 80, width: 650, height: 300)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 230, y: 390, width: 650, height: 300)
                
            case .iPhone:
                
                // Labe1: pressure value
                labelPressure.frame = CGRect(x: 500, y: 360, width: 190, height: 120)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: 500, y: 800, width: 190, height: 80)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 20, y: 40, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: Int(graphicsEnabledWidth!/2) + 10, y: 40, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func insertGraph(){
        
        pressuresGraph.plotWithIdentifier(4)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.systolicPressure.count-1), numberOfRecords: 1)
        pressuresGraph.plotWithIdentifier(5)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.diastolicPressure.count-1), numberOfRecords: 1)
        pressuresGraph.plotWithIdentifier(6)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.averagePressure.count-1), numberOfRecords: 1)
        heartRateGraph.plotWithIdentifier(7)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.heartRate.count-1), numberOfRecords: 1)
        
        // Label update with latest measures
        labelPressure.text = "Last messure \n\nSystolic: \(VectorPhysiologicalVariables.systolicPressure.last!) mmHg\nDiastolic: \(VectorPhysiologicalVariables.diastolicPressure.last!) mmHg\nAverage: \(VectorPhysiologicalVariables.averagePressure.last!) mmHg"
        labelHeartRate.text = "Last messure \n\nHeart Rate: \(VectorPhysiologicalVariables.heartRate.last!) BPM"
        
    }

}
