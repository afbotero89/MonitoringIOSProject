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
    let newGraph = CPTXYGraph(frame: CGRectZero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGraph()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureGraph(){
        
        
        newGraph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))
        
        let titleTextStyle = CPTMutableTextStyle()
        titleTextStyle.color = CPTColor.grayColor()
        titleTextStyle.fontName = "Helveltica-Neue"
        
        
        // Graph's hosting view
        let hostingView = view as! CPTGraphHostingView
        hostingView.hostedGraph = newGraph
        // In order to optimize memory spenditures, plot all the graphs on the same single layer.
        hostingView.collapsesLayers = true
        
        let plotAreaFrame = newGraph.plotAreaFrame!
        
        // Border
        plotAreaFrame.borderLineStyle = nil
        plotAreaFrame.cornerRadius    = 0.0
        plotAreaFrame.masksToBorder   = false
        
        // Paddings
        newGraph.paddingLeft   = 40.0
        newGraph.paddingRight  = 0.0
        newGraph.paddingTop    = 0.0
        newGraph.paddingBottom = 60.0
        
        plotAreaFrame.paddingTop    = 15.0
        plotAreaFrame.paddingRight  = 15.0
        plotAreaFrame.masksToBorder = false
        
        // Axis
        
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
        
        let axisSet = newGraph.axisSet as! CPTXYAxisSet
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
        xAxis.axisLineStyle =  nil
        xAxis.separateLayers = false
        // Configure the text style for the labels
        let attributes = [NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 20)!]
        let labelTextStyle = CPTMutableTextStyle(attributes: attributes)
        xAxis.labelTextStyle = labelTextStyle
        xAxis.titleTextStyle = labelTextStyle
        
        // Y
        // Grid line styles. For the Y axis
        majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.25
        majorGridLineStyle.lineColor = CPTColor(genericGray: CGFloat()).colorWithAlphaComponent(CGFloat(0.1))
        majorGridLineStyle.dashPattern = [CGFloat(3), CGFloat(3)]
        minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = CPTColor.blackColor().colorWithAlphaComponent(CGFloat(0.1))
        
        let yAxis = axisSet.yAxis!
        yAxis.labelingPolicy = .Automatic
        yAxis.orthogonalPosition = 0.0
        yAxis.majorGridLineStyle = majorGridLineStyle
        yAxis.minorGridLineStyle = minorGridLineStyle
        // Do not present the Ticks that appear over the axis
        yAxis.majorTickLineStyle = nil
        yAxis.minorTickLineStyle = nil
        yAxis.minorTicksPerInterval = 0
        
        //yAxis.title = "Y Axis"
        yAxis.title = nil
        yAxis.titleOffset = 0
        yAxis.axisConstraints = CPTConstraints(lowerOffset: 0.0) // Fixes the axis to low left corner of the graph
        //yAxis.labelFormatter = nil
        yAxis.labelingPolicy = .None
        //Store the label style
        
        yAxis.axisLineStyle = nil
        yAxis.labelTextStyle = labelTextStyle
        yAxis.titleTextStyle = labelTextStyle
        
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
        
        return UInt(x.count)
    }
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        switch CPTScatterPlotField(rawValue: Int(fieldEnum))! {
        case .X:
            return x[Int(idx)]
        case .Y:
            var yLabel = y[Int(idx)]
            if plot.identifier as! NSInteger == 1{
                yLabel = yLabel + 0.2
            }else{
                yLabel = y[Int(idx)]
            }
            
            return yLabel
        }
    }

}