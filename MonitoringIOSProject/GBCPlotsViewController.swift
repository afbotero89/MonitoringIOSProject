//
//  GBCPlotsViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 27/4/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit

class GBCPlotsViewController: UIViewController {

    // Graph
    let pressuresGraph = CPTXYGraph(frame: CGRectZero)
    
    let heartRateGraph = CPTXYGraph(frame: CGRectZero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let device = UIDevice.currentDevice().model
        
        if device == "iPad"{
            UserSelectedConfiguration.typeOfDevice = .iPad
        }else{
            UserSelectedConfiguration.typeOfDevice = .iPhone
        }
        configureGraph()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureGraph(){
        
        pressuresGraph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))
        pressuresGraph.defaultPlotSpace?.allowsUserInteraction = true
        
        //Change the x and y range.
        let plotSpacePressureGraph = pressuresGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpacePressureGraph.yRange = CPTPlotRange(location: 0, length: 1)
        plotSpacePressureGraph.xRange = CPTPlotRange(location: 0, length: 1)
        
        heartRateGraph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))
        heartRateGraph.defaultPlotSpace?.allowsUserInteraction = true
        
        let titleTextStyle = CPTMutableTextStyle()
        titleTextStyle.color = CPTColor.grayColor()
        titleTextStyle.fontName = "Helveltica-Neue"
        
        /*
        // Graph's hosting view
        let hostingView = view as! CPTGraphHostingView
        hostingView.hostedGraph = newGraph
        // In order to optimize memory spenditures, plot all the graphs on the same single layer.
        hostingView.collapsesLayers = true
        */
        let plotAreaFrame = pressuresGraph.plotAreaFrame!
        let plotAreaFrameHeartRate = heartRateGraph.plotAreaFrame!
        
        // Border
        plotAreaFrame.borderLineStyle = nil
        plotAreaFrame.cornerRadius    = 20.0
        plotAreaFrame.masksToBorder   = false
        
        // Border
        plotAreaFrameHeartRate.borderLineStyle = nil
        plotAreaFrameHeartRate.cornerRadius    = 20.0
        plotAreaFrameHeartRate.masksToBorder   = false
        
        // Paddings
        pressuresGraph.paddingLeft   = 60.0
        pressuresGraph.paddingRight  = 0.0
        pressuresGraph.paddingTop    = 0.0
        pressuresGraph.paddingBottom = 60.0
        
        plotAreaFrame.paddingTop    = 15.0
        plotAreaFrame.paddingRight  = 15.0
        plotAreaFrame.masksToBorder = false
        
        // Paddings
        heartRateGraph.paddingLeft   = 60.0
        heartRateGraph.paddingRight  = 0.0
        heartRateGraph.paddingTop    = 0.0
        heartRateGraph.paddingBottom = 60.0
        
        plotAreaFrameHeartRate.paddingTop    = 15.0
        plotAreaFrameHeartRate.paddingRight  = 15.0
        plotAreaFrameHeartRate.masksToBorder = false
        
        // Axis pressure graph
        
        // X
        // Grid line styles. For the X axis
        var majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.75
        majorGridLineStyle.lineColor = CPTColor(genericGray: CGFloat()).colorWithAlphaComponent(CGFloat(0.75))
        majorGridLineStyle.dashPattern = [CGFloat(3), CGFloat(3)]
        var minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = CPTColor.blackColor().colorWithAlphaComponent(CGFloat(0.1))
        minorGridLineStyle.dashPattern = [CGFloat(3), CGFloat(3)]
        
        let axisSet = pressuresGraph.axisSet as! CPTXYAxisSet
        
        let xAxis = axisSet.xAxis!
        xAxis.labelingPolicy = CPTAxisLabelingPolicy.Automatic
        xAxis.orthogonalPosition = 0.0
        xAxis.majorGridLineStyle = majorGridLineStyle
        xAxis.minorGridLineStyle = minorGridLineStyle
        // Do not present the Ticks that appear over the X axis line
        xAxis.majorTickLineStyle = nil
        xAxis.minorTickLineStyle = nil
        xAxis.minorTicksPerInterval = 2
        xAxis.title = "Time (s)"
        xAxis.axisConstraints = CPTConstraints(lowerOffset: 0.0) // Fixes the axis to low left corner of the graph
        xAxis.labelFormatter = nil
        //xAxis.labelExclusionRanges = [CPTPlotRange(location: 0.0, length: 0.1)] // Do not show the vertical dashed line over the yAxis
        let labelFormatter = NSNumberFormatter()
        labelFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        xAxis.labelFormatter = labelFormatter
        //Do now show the vertical line over the x axis
        //xAxis.axisLineStyle =  nil
        xAxis.separateLayers = false
        xAxis.hidden = false
        // Configure the text style for the labels
        var attributes:[String: AnyObject]?
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            attributes = [ NSForegroundColorAttributeName : UIColor(red:11/255, green:44/255,blue:65/255,alpha:1.0),
                               NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 16)!]
        case .iPhone:
            attributes = [ NSForegroundColorAttributeName : UIColor(red:11/255, green:44/255,blue:65/255,alpha:1.0),
                               NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 10)!]
        }
        
        let labelTextStyle = CPTMutableTextStyle(attributes: attributes)
        xAxis.labelTextStyle = labelTextStyle
        xAxis.titleTextStyle = labelTextStyle
        
        // Y
        // Grid line styles. For the Y axis
        majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.75
        majorGridLineStyle.lineColor = CPTColor(genericGray: CGFloat()).colorWithAlphaComponent(CGFloat(0.1))
        majorGridLineStyle.dashPattern = [CGFloat(3), CGFloat(3)]
        minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = CPTColor.blackColor().colorWithAlphaComponent(CGFloat(0.1))
        
        let yAxis = axisSet.yAxis!
        yAxis.labelingPolicy = CPTAxisLabelingPolicy.Automatic
        yAxis.orthogonalPosition = 0.0
        yAxis.majorGridLineStyle = majorGridLineStyle
        yAxis.minorGridLineStyle = minorGridLineStyle
        // Do not present the Ticks that appear over the X axis line
        yAxis.majorTickLineStyle = nil
        yAxis.minorTickLineStyle = nil
        yAxis.minorTicksPerInterval = 2
        yAxis.title = "Pressure (mmHg)"
        yAxis.axisConstraints = CPTConstraints(lowerOffset: 0.0) // Fixes the axis to low left corner of the graph
        yAxis.labelFormatter = nil
        //xAxis.labelExclusionRanges = [CPTPlotRange(location: 0.0, length: 0.1)] // Do not show the vertical dashed line over the yAxis
        labelFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        yAxis.labelFormatter = labelFormatter
        //Do now show the vertical line over the x axis
        //xAxis.axisLineStyle =  nil
        yAxis.separateLayers = false
        yAxis.hidden = false
        // Configure the text style for the labels
    
        yAxis.labelTextStyle = labelTextStyle
        yAxis.titleTextStyle = labelTextStyle
        
        
        // Axis heart rate graph
        
        // X
        // Grid line styles. For the X axis
        var majorGridLineStyleHeartRate = CPTMutableLineStyle()
        majorGridLineStyleHeartRate.lineWidth = 0.75
        majorGridLineStyleHeartRate.lineColor = CPTColor(genericGray: CGFloat()).colorWithAlphaComponent(CGFloat(0.75))
        majorGridLineStyleHeartRate.dashPattern = [CGFloat(3), CGFloat(3)]
        var minorGridLineStyleHeartRate = CPTMutableLineStyle()
        minorGridLineStyleHeartRate.lineWidth = 0.25
        minorGridLineStyleHeartRate.lineColor = CPTColor.blackColor().colorWithAlphaComponent(CGFloat(0.1))
        minorGridLineStyleHeartRate.dashPattern = [CGFloat(3), CGFloat(3)]
        
        let axisSetHeartRate = heartRateGraph.axisSet as! CPTXYAxisSet
        
        let xAxisHeartRate = axisSetHeartRate.xAxis!
        xAxisHeartRate.labelingPolicy = CPTAxisLabelingPolicy.Automatic
        xAxisHeartRate.orthogonalPosition = 0.0
        xAxisHeartRate.majorGridLineStyle = majorGridLineStyleHeartRate
        xAxisHeartRate.minorGridLineStyle = minorGridLineStyleHeartRate
        // Do not present the Ticks that appear over the X axis line
        xAxisHeartRate.majorTickLineStyle = nil
        xAxisHeartRate.minorTickLineStyle = nil
        xAxisHeartRate.minorTicksPerInterval = 2
        xAxisHeartRate.title = "Time (s)"
        xAxisHeartRate.axisConstraints = CPTConstraints(lowerOffset: 0.0) // Fixes the axis to low left corner of the graph
        xAxisHeartRate.labelFormatter = nil
        //xAxis.labelExclusionRanges = [CPTPlotRange(location: 0.0, length: 0.1)] // Do not show the vertical dashed line over the yAxis
        let labelFormatterHeartRate = NSNumberFormatter()
        labelFormatterHeartRate.numberStyle = NSNumberFormatterStyle.DecimalStyle
        xAxisHeartRate.labelFormatter = labelFormatterHeartRate
        //Do now show the vertical line over the x axis
        //xAxis.axisLineStyle =  nil
        xAxisHeartRate.separateLayers = false
        xAxisHeartRate.hidden = false
        // Configure the text style for the labels
        var attributesHeartRate:[String: AnyObject]?
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            attributesHeartRate = [NSForegroundColorAttributeName : UIColor(red:11/255, green:44/255,blue:65/255,alpha:1.0),
                                       NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 16)!]
        case .iPhone:
            attributesHeartRate = [NSForegroundColorAttributeName : UIColor(red:11/255, green:44/255,blue:65/255,alpha:1.0),
                                       NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 10)!]
        }
        
        let labelTextStyleHeartRate = CPTMutableTextStyle(attributes: attributesHeartRate)
        xAxisHeartRate.labelTextStyle = labelTextStyleHeartRate
        xAxisHeartRate.titleTextStyle = labelTextStyleHeartRate
        
        // Y
        // Grid line styles. For the Y axis
        majorGridLineStyleHeartRate = CPTMutableLineStyle()
        majorGridLineStyleHeartRate.lineWidth = 0.75
        majorGridLineStyleHeartRate.lineColor = CPTColor(genericGray: CGFloat()).colorWithAlphaComponent(CGFloat(0.1))
        majorGridLineStyleHeartRate.dashPattern = [CGFloat(3), CGFloat(3)]
        minorGridLineStyleHeartRate = CPTMutableLineStyle()
        minorGridLineStyleHeartRate.lineWidth = 0.25
        minorGridLineStyleHeartRate.lineColor = CPTColor.blackColor().colorWithAlphaComponent(CGFloat(0.2))
        
        let yAxisHeartRate = axisSetHeartRate.yAxis!
        yAxisHeartRate.labelingPolicy = CPTAxisLabelingPolicy.Automatic
        yAxisHeartRate.orthogonalPosition = 0.0
        yAxisHeartRate.majorGridLineStyle = majorGridLineStyleHeartRate
        yAxisHeartRate.minorGridLineStyle = minorGridLineStyleHeartRate
        // Do not present the Ticks that appear over the X axis line
        yAxisHeartRate.majorTickLineStyle = nil
        yAxisHeartRate.minorTickLineStyle = nil
        yAxisHeartRate.minorTicksPerInterval = 2
        yAxisHeartRate.title = "Beats per minute (BPM)"
        yAxisHeartRate.axisConstraints = CPTConstraints(lowerOffset: 0.0) // Fixes the axis to low left corner of the graph
        yAxisHeartRate.labelFormatter = nil
        //xAxis.labelExclusionRanges = [CPTPlotRange(location: 0.0, length: 0.1)] // Do not show the vertical dashed line over the yAxis
        //let labelFormatterHeartRate = NSNumberFormatter()
        labelFormatterHeartRate.numberStyle = NSNumberFormatterStyle.DecimalStyle
        yAxisHeartRate.labelFormatter = labelFormatterHeartRate
        //Do now show the vertical line over the x axis
        //xAxis.axisLineStyle =  nil
        yAxisHeartRate.separateLayers = false
        yAxisHeartRate.hidden = false
        // Configure the text style for the labels
        //let attributesHeartRate = [NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 20)!]
        //let labelTextStyleHeartRate = CPTMutableTextStyle(attributes: attributesHeartRate)
        yAxisHeartRate.labelTextStyle = labelTextStyleHeartRate
        yAxisHeartRate.titleTextStyle = labelTextStyleHeartRate
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension GBCPlotsViewController:CPTPlotDataSource, CPTPieChartDelegate, CPTLegendDelegate, CPTPlotSpaceDelegate, CPTPlotDelegate{
    
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        
        return UInt(VectorPhysiologicalVariables.vectorNumberOfSamples.count)
    }
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        
        plot.delegate = self
        
        switch CPTScatterPlotField(rawValue: Int(fieldEnum))! {
        case .X:
            return VectorPhysiologicalVariables.vectorNumberOfSamples[Int(idx)]
            
        case .Y:
            var yLabel:Double?
            //Systolic pressure
            if (plot.identifier as! NSInteger == 0){
                yLabel = VectorPhysiologicalVariables.systolicPressure[Int(idx)]
            //Diastolic pressure
            }else if(plot.identifier as! NSInteger == 1){
                yLabel = VectorPhysiologicalVariables.diastolicPressure[Int(idx)]
            //Average pressure
            }else if(plot.identifier as! NSInteger == 2){
                yLabel = VectorPhysiologicalVariables.averagePressure[Int(idx)]
            //Heart rate pressure
            }else{
                yLabel = VectorPhysiologicalVariables.heartRate[Int(idx)]
            }
            return yLabel
        }
    }

}

