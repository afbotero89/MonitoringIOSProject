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
    let pressuresGraph = CPTXYGraph(frame: CGRect.zero)
    
    let heartRateGraph = CPTXYGraph(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let device = UIDevice.current.model
        
        if device == "iPad"{
            UserSelectedConfiguration.typeOfDevice = .iPad
        }else{
            UserSelectedConfiguration.typeOfDevice = .iPhone
        }
        
        
        if userSelectViewController == nil{
            userSelectViewController = UserSelectViewPrincipalViewController.realTimeViewController
        }
        
        configureGraph()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureGraph(){
        
        pressuresGraph.apply(CPTTheme(named: CPTThemeName.plainWhiteTheme))
        pressuresGraph.defaultPlotSpace?.allowsUserInteraction = true
        
        //Change the x and y range.
        let plotSpacePressureGraph = pressuresGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpacePressureGraph.graph?.cornerRadius = 20
        plotSpacePressureGraph.yRange = CPTPlotRange(location: 0, length: 1)
        plotSpacePressureGraph.xRange = CPTPlotRange(location: 0, length: 1)
    
        heartRateGraph.apply(CPTTheme(named: CPTThemeName.plainWhiteTheme))
        heartRateGraph.defaultPlotSpace?.allowsUserInteraction = true
        heartRateGraph.defaultPlotSpace?.graph?.cornerRadius = 20
        
        let titleTextStyle = CPTMutableTextStyle()
        titleTextStyle.color = CPTColor.gray()
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
        pressuresGraph.paddingLeft   = 50.0
        pressuresGraph.paddingRight  = 0.0
        pressuresGraph.paddingTop    = 0.0
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            pressuresGraph.paddingBottom = 50.0
            heartRateGraph.paddingBottom = 50.0
        case .iPhone:
            pressuresGraph.paddingBottom = 45.0
            heartRateGraph.paddingBottom = 45.0
        }
        
        plotAreaFrame.paddingTop    = 15.0
        plotAreaFrame.paddingRight  = 15.0
        plotAreaFrame.masksToBorder = false
        
        // Paddings
        heartRateGraph.paddingLeft   = 50.0
        heartRateGraph.paddingRight  = 0.0
        heartRateGraph.paddingTop    = 0.0
        
        plotAreaFrameHeartRate.paddingTop    = 15.0
        plotAreaFrameHeartRate.paddingRight  = 15.0
        plotAreaFrameHeartRate.masksToBorder = false
        
        // Axis pressure graph
        
        // X
        // Grid line styles. For the X axis
        var majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.35
        majorGridLineStyle.lineColor = CPTColor(genericGray: CGFloat()).withAlphaComponent(CGFloat(0.35))
        majorGridLineStyle.dashPattern = [3, 3]
        var minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.5
        minorGridLineStyle.lineColor = CPTColor.black().withAlphaComponent(CGFloat(0.1))
        minorGridLineStyle.dashPattern = [3, 3]
        
        let axisSet = pressuresGraph.axisSet as! CPTXYAxisSet
        
        let xAxis = axisSet.xAxis!
        xAxis.title = NSLocalizedString("Hour", comment: "")
        
        var locations = Set<NSNumber>()
        
        switch userSelectViewController!{
            
        case .realTimeViewController:
            xAxis.labelingPolicy = .none
            
        case .hitorialViewController:
            var labels:Set<CPTAxisLabel> = Set<CPTAxisLabel>()
            xAxis.labelingPolicy = .none
            //xAxis.hidden = false
            let style = CPTMutableTextStyle()
            style.color = CPTColor.black()
            style.fontName = "Helvetica-Neue"
            style.fontSize = 12.0
            
            let text =  PhysiologicalVariablesStoredInDatabaseSQL.hour
            
            for i in 0..<text.count{
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    let xLabel = CPTAxisLabel.init(text: String(text[i]), textStyle: style)
                    xLabel.tickLocation = NSNumber(value: Double(i)/10.0)
                    if i%2 == 0{
                        locations.insert(3)
                    }
                    xLabel.offset = 0
                    labels.insert(xLabel)
                    xAxis.majorTickLocations = locations
                    xAxis.axisLabels = labels
                case .iPhone:
                    let xLabel = CPTAxisLabel.init(text: text[i].components(separatedBy: ":")[0] + ":" + text[i].components(separatedBy: ":")[1], textStyle: style)
                    xLabel.rotation = 3.14/3.0;
                    xLabel.tickLocation = NSNumber(value: Double(i)/10.0)
                    if i%2 == 0{
                        locations.insert(3)
                    }
                    xLabel.offset = 0
                    labels.insert(xLabel)
                    xAxis.majorTickLocations = locations
                    xAxis.axisLabels = labels
                }
                
   
            }
        case .animationViewController:
            print("animation view controller")
        }

        xAxis.isHidden = false
        xAxis.orthogonalPosition = 0.0
        xAxis.majorGridLineStyle = majorGridLineStyle
        xAxis.minorGridLineStyle = minorGridLineStyle
        // Do not present the Ticks that appear over the X axis line
        xAxis.majorTickLineStyle = majorGridLineStyle
        xAxis.minorTickLineStyle = minorGridLineStyle
        xAxis.minorTicksPerInterval = 1
        
        xAxis.axisConstraints = CPTConstraints(lowerOffset: 0.0) // Fixes the axis to low left corner of the graph
        xAxis.labelFormatter = nil
        //xAxis.labelExclusionRanges = [CPTPlotRange(location: 0.0, length: 0.1)] // Do not show the vertical dashed line over the yAxis
        let labelFormatter = NumberFormatter()
        labelFormatter.numberStyle = NumberFormatter.Style.decimal
        xAxis.labelFormatter = labelFormatter
        //Do now show the vertical line over the x axis
        //xAxis.axisLineStyle =  nil
        xAxis.separateLayers = false
        xAxis.isHidden = false
        // Configure the text style for the labels
        var attributes:[String: AnyObject]?
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            attributes = [ NSForegroundColorAttributeName : UIColor(red:11/255, green:44/255,blue:65/255,alpha:1.0),
                               NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 12)!]
        case .iPhone:
            attributes = [ NSForegroundColorAttributeName : UIColor(red:11/255, green:44/255,blue:65/255,alpha:1.0),
                               NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 8)!]
        }
        
        let labelTextStyle = CPTMutableTextStyle(attributes: attributes)
        xAxis.labelTextStyle = labelTextStyle
        xAxis.titleTextStyle = labelTextStyle
        
        // Y
        // Grid line styles. For the Y axis
        majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.75
        majorGridLineStyle.lineColor = CPTColor(genericGray: CGFloat()).withAlphaComponent(CGFloat(0.2))
        majorGridLineStyle.dashPattern = [3, 3]
        minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = CPTColor.black().withAlphaComponent(CGFloat(0.1))
        
        let yAxis = axisSet.yAxis!
        yAxis.labelingPolicy = CPTAxisLabelingPolicy.automatic
        yAxis.orthogonalPosition = 0.0
        yAxis.majorGridLineStyle = majorGridLineStyle
        yAxis.minorGridLineStyle = minorGridLineStyle
        // Do not present the Ticks that appear over the X axis line
        yAxis.majorTickLineStyle = nil
        yAxis.minorTickLineStyle = nil
        yAxis.minorTicksPerInterval = 2
        yAxis.title = NSLocalizedString("Pressure", comment: "") + "(mmHg)"
        yAxis.axisConstraints = CPTConstraints(lowerOffset: 0.0) // Fixes the axis to low left corner of the graph
        yAxis.labelFormatter = nil
        //xAxis.labelExclusionRanges = [CPTPlotRange(location: 0.0, length: 0.1)] // Do not show the vertical dashed line over the yAxis
        labelFormatter.numberStyle = NumberFormatter.Style.decimal
        yAxis.labelFormatter = labelFormatter
        //Do now show the vertical line over the x axis
        //xAxis.axisLineStyle =  nil
        yAxis.separateLayers = false
        yAxis.isHidden = false
        // Configure the text style for the labels
    
        yAxis.labelTextStyle = labelTextStyle
        yAxis.titleTextStyle = labelTextStyle
        
        
        // Axis heart rate graph
        
        // X
        // Grid line styles. For the X axis
        var majorGridLineStyleHeartRate = CPTMutableLineStyle()
        majorGridLineStyleHeartRate.lineWidth = 0.35
        majorGridLineStyleHeartRate.lineColor = CPTColor(genericGray: CGFloat()).withAlphaComponent(CGFloat(0.35))
        majorGridLineStyleHeartRate.dashPattern = [3, 3]
        var minorGridLineStyleHeartRate = CPTMutableLineStyle()
        minorGridLineStyleHeartRate.lineWidth = 0.25
        minorGridLineStyleHeartRate.lineColor = CPTColor.black().withAlphaComponent(CGFloat(0.1))
        minorGridLineStyleHeartRate.dashPattern = [3, 3]
        
        let axisSetHeartRate = heartRateGraph.axisSet as! CPTXYAxisSet
        
        let xAxisHeartRate = axisSetHeartRate.xAxis!
        xAxisHeartRate.labelingPolicy = CPTAxisLabelingPolicy.automatic
        xAxisHeartRate.orthogonalPosition = 0.0
        xAxisHeartRate.majorGridLineStyle = majorGridLineStyleHeartRate
        xAxisHeartRate.minorGridLineStyle = minorGridLineStyleHeartRate
        // Do not present the Ticks that appear over the X axis line
        xAxisHeartRate.majorTickLineStyle = nil
        xAxisHeartRate.minorTickLineStyle = nil
        xAxisHeartRate.minorTicksPerInterval = 2
        xAxisHeartRate.title = NSLocalizedString("Hour", comment: "")
        switch userSelectViewController!{
            
        case .realTimeViewController:
            xAxisHeartRate.labelingPolicy = .none
            
        case .hitorialViewController:
            
            var labels:Set<CPTAxisLabel> = Set<CPTAxisLabel>()
            xAxisHeartRate.labelingPolicy = .none
            //xAxis.hidden = false
            let style = CPTMutableTextStyle()
            style.color = CPTColor.black()
            style.fontName = "Helvetica-Neue"
            style.fontSize = 12.0
            let text =  PhysiologicalVariablesStoredInDatabaseSQL.hour
            for i in 0..<text.count{
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    let xLabel = CPTAxisLabel.init(text: String(text[i]), textStyle: style)
                    xLabel.tickLocation = NSNumber(value: Double(i)/10.0)
                    xLabel.offset = 0
                    xAxisHeartRate.majorTickLocations = locations
                    labels.insert(xLabel)
                    xAxisHeartRate.axisLabels = labels
                case .iPhone:
                    let xLabel = CPTAxisLabel.init(text: text[i].components(separatedBy: ":")[0] + ":" + text[i].components(separatedBy: ":")[1], textStyle: style)
                    xLabel.rotation = 3.14/3.0;
                    xLabel.tickLocation = NSNumber(value: Double(i)/10.0)
                    xLabel.offset = 0
                    xAxisHeartRate.majorTickLocations = locations
                    labels.insert(xLabel)
                    xAxisHeartRate.axisLabels = labels
                }
                
                
            }
        case .animationViewController:
            print("animation view controller")
        }
        xAxisHeartRate.axisConstraints = CPTConstraints(lowerOffset: 0.0) // Fixes the axis to low left corner of the graph
        xAxisHeartRate.labelFormatter = nil
        //xAxis.labelExclusionRanges = [CPTPlotRange(location: 0.0, length: 0.1)] // Do not show the vertical dashed line over the yAxis
        let labelFormatterHeartRate = NumberFormatter()
        labelFormatterHeartRate.numberStyle = NumberFormatter.Style.decimal
        xAxisHeartRate.labelFormatter = labelFormatterHeartRate
        //Do now show the vertical line over the x axis
        //xAxis.axisLineStyle =  nil
        xAxisHeartRate.separateLayers = false
        xAxisHeartRate.isHidden = false
        // Configure the text style for the labels
        var attributesHeartRate:[String: AnyObject]?
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            attributesHeartRate = [NSForegroundColorAttributeName : UIColor(red:11/255, green:44/255,blue:65/255,alpha:1.0),
                                       NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 12)!]
        case .iPhone:
            attributesHeartRate = [NSForegroundColorAttributeName : UIColor(red:11/255, green:44/255,blue:65/255,alpha:1.0),
                                       NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 8)!]
        }
        
        let labelTextStyleHeartRate = CPTMutableTextStyle(attributes: attributesHeartRate)
        xAxisHeartRate.labelTextStyle = labelTextStyleHeartRate
        xAxisHeartRate.titleTextStyle = labelTextStyleHeartRate
        
        // Y
        // Grid line styles. For the Y axis
        majorGridLineStyleHeartRate = CPTMutableLineStyle()
        majorGridLineStyleHeartRate.lineWidth = 0.75
        majorGridLineStyleHeartRate.lineColor = CPTColor(genericGray: CGFloat()).withAlphaComponent(CGFloat(0.1))
        majorGridLineStyleHeartRate.dashPattern = [3, 3]
        minorGridLineStyleHeartRate = CPTMutableLineStyle()
        minorGridLineStyleHeartRate.lineWidth = 0.25
        minorGridLineStyleHeartRate.lineColor = CPTColor.black().withAlphaComponent(CGFloat(0.2))
        
        let yAxisHeartRate = axisSetHeartRate.yAxis!
        yAxisHeartRate.labelingPolicy = CPTAxisLabelingPolicy.automatic
        yAxisHeartRate.orthogonalPosition = 0.0
        yAxisHeartRate.majorGridLineStyle = majorGridLineStyleHeartRate
        yAxisHeartRate.minorGridLineStyle = minorGridLineStyleHeartRate
        // Do not present the Ticks that appear over the X axis line
        yAxisHeartRate.majorTickLineStyle = nil
        yAxisHeartRate.minorTickLineStyle = nil
        yAxisHeartRate.minorTicksPerInterval = 2
        yAxisHeartRate.title = NSLocalizedString("Beats per minute", comment: "") + "(BPM)"
        yAxisHeartRate.axisConstraints = CPTConstraints(lowerOffset: 0.0) // Fixes the axis to low left corner of the graph
        yAxisHeartRate.labelFormatter = nil
        //xAxis.labelExclusionRanges = [CPTPlotRange(location: 0.0, length: 0.1)] // Do not show the vertical dashed line over the yAxis
        //let labelFormatterHeartRate = NSNumberFormatter()
        labelFormatterHeartRate.numberStyle = NumberFormatter.Style.decimal
        yAxisHeartRate.labelFormatter = labelFormatterHeartRate
        //Do now show the vertical line over the x axis
        //xAxis.axisLineStyle =  nil
        yAxisHeartRate.separateLayers = false
        yAxisHeartRate.isHidden = false
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
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        
        switch plot.identifier as! NSInteger{
        case 0,1,2,3:
            return UInt(VectorPhysiologicalVariables.vectorNumberOfSamples.count)
        case 4,5,6,7:
            return UInt(PhysiologicalVariablesStoredInDatabaseSQL.hour.count)
        default:
            return 0
        }
        
        //return UInt(VectorPhysiologicalVariables.vectorNumberOfSamples.count)
    }
    
    func numberForPlot(_ plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        
        plot.delegate = self
        
        switch CPTScatterPlotField(rawValue: Int(fieldEnum))! {
        case .X:
            
            switch plot.identifier as! NSInteger{
            case 0,1,2,3:
                return VectorPhysiologicalVariables.vectorNumberOfSamples[Int(idx)] as AnyObject?
            case 4,5,6,7:
                return Double(idx)/10 as AnyObject?
            default:
                return 0 as AnyObject?
            }
            
            
        case .Y:
            var yLabel:Double?
            
            switch plot.identifier as! NSInteger{
            case 0:
                yLabel = VectorPhysiologicalVariables.systolicPressure[Int(idx)]
            case 1:
                yLabel = VectorPhysiologicalVariables.diastolicPressure[Int(idx)]
            case 2:
                yLabel = VectorPhysiologicalVariables.averagePressure[Int(idx)]
            case 3:
                yLabel = VectorPhysiologicalVariables.heartRate[Int(idx)]
            case 4:
                yLabel = PhysiologicalVariablesStoredInDatabaseSQL.systolicPressure[Int(idx)]
            case 5:
                yLabel = PhysiologicalVariablesStoredInDatabaseSQL.diastolicPressure[Int(idx)]
            case 6:
                yLabel = PhysiologicalVariablesStoredInDatabaseSQL.averagePressure[Int(idx)]
            case 7:
                yLabel = PhysiologicalVariablesStoredInDatabaseSQL.heartRate[Int(idx)]
            default:
                yLabel = 0
            }
            return yLabel as AnyObject?
        }
    }
    
    func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
        //tickLocation
        
        let style = CPTMutableTextStyle()
        style.color = CPTColor.black()
        style.fontName = "HelveticaNeue-Light"
        style.fontSize = 10.0
        
        switch plot.identifier as! NSInteger{
        case 0,1,2,3:
            return CPTTextLayer()
        case 4:
            return CPTTextLayer(text: String(PhysiologicalVariablesStoredInDatabaseSQL.systolicPressure[Int(idx)]), style: style)
        case 5:
            return CPTTextLayer(text: String(PhysiologicalVariablesStoredInDatabaseSQL.diastolicPressure[Int(idx)]), style: style)
        case 6:
            return CPTTextLayer(text: String(PhysiologicalVariablesStoredInDatabaseSQL.averagePressure[Int(idx)]), style: style)
        case 7:
            return CPTTextLayer(text: String(PhysiologicalVariablesStoredInDatabaseSQL.heartRate[Int(idx)]), style: style)
            
        default:
            return CPTTextLayer()
        }
        
    }

}

