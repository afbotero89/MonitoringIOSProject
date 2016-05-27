//
//  ViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 27/4/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit
import SystemConfiguration


var activeCurrentMeasurementFlag = false

var activeCurrentHourFlag = false

var activeMeasurementTimeFlag = false

var userSelectViewController : UserSelectViewPrincipalViewController?

var typeError:Int?

var configurationHour:String?

var hourOnDevice:String?

class ViewController: GBCPlotsViewController, UIPopoverPresentationControllerDelegate  {
    
    let systolicPressurePlot = CPTScatterPlot()
    
    let diastolicPressurePlot = CPTScatterPlot()
    
    let averagePressurePlot = CPTScatterPlot()
    
    let heartRatePressurePlot = CPTScatterPlot()
    
    var pressureContainerGraph = CPTGraphHostingView()
    
    var heartRateContainerGraph = CPTGraphHostingView()
    
    let requestSetDataBaseSQL = NSMutableURLRequest(URL: NSURL(string:"http://www.sibxe.co/appMonitoreo/querysToDatabase.php")!)
    
    var bluetoothManager:BluetoothManager!
    
    let labelPressure = UILabel()
    
    let labelHeartRate = UILabel()
    
    let gradientLayer = CAGradientLayer()
    
    var graphicsEnabledHeight:Double?
    
    var graphicsEnabledWidth:Double?
    
    var labels:Set<CPTAxisLabel> = Set<CPTAxisLabel>()
    
    var locations = Set<NSNumber>()
    
    var labelsHeartRate:Set<CPTAxisLabel> = Set<CPTAxisLabel>()
    
    var locationsHeartRate = Set<NSNumber>()
    
    let configurationHourInstance = GBCSettingsHour()
    
    @IBOutlet weak var currentMeasurementLabel: UIButton!
    
    @IBOutlet weak var statusConnectionLabel: UILabel!
    
    @IBOutlet weak var imageStatusConnection: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Configuracion hora
        ////////////
        let horaConexion = "19:38:19"
        let tiempoDispositivoEncendido = "00:30:42"
        let startDeviceHour = configurationHourInstance.horaInicioDispositivo(horaConexion,tiempoDispositivoEncendido: tiempoDispositivoEncendido)
        
        let horaActual = "00:30:42"
        let horaEncendidoDispositivo = startDeviceHour
        let meassureHour = configurationHourInstance.horaNoConfigurada(horaActual,horaEncendidoDispositivo: horaEncendidoDispositivo)
        print(startDeviceHour)
        print(meassureHour)
        ///////////
        */
        
        
        /*
        var vector1 = [1,2,3,4]
        var comodin = vector1[3]
        vector1[3] = vector1[2]
        vector1[2] = comodin
        print(vector1)
        */
        var vector1 = [1,2,3,4]
        /*
        let comodin = vector1[vector1.count - 1]
        vector1.removeAtIndex(vector1.count - 1)
        vector1.insert(comodin, atIndex: 0)
         */
        vector1.removeAtIndex(0)
        print(vector1)
        
        addAttributesToViewController()
        
        // Initialize the bluetooth manager.
        self.bluetoothManager = BluetoothManager()
        
        notifications()

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
        
        let attrs = [
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 16)!,
            
        ]
        
        pressuresGraph.title = "Pressure graphics"
        pressuresGraph.titleTextStyle = CPTTextStyle(attributes: attrs)
        heartRateGraph.title = "Heart rate graphic"
        heartRateGraph.titleTextStyle = CPTTextStyle(attributes: attrs)
        
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
        
        requestSetDataBaseSQL.HTTPMethod = "POST"
        
        //uploadToServerDataBaseSQL(180,diastolicPressure: 80,mediumPressure: 100,heartRate: 60,hour:"10:30:60")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        userSelectViewController = UserSelectViewPrincipalViewController.realTimeViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: BLEServiceChangedStatusNotification, object: nil)
    }
    
    // MARK: - Functions
    
    /**
     Notification Center
     */
    func notifications(){
    
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(ViewController.insertPoint),
                                                         
                                                         name: "insertNewPlot",
                                                         
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(ViewController.displayDisconnectBluetoothMessage),
                                                         
                                                         name: "displayDisconnectBluetoothAlertMessage",
                                                         
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(ViewController.displayCurrentMeasurementPopover),
                                                         
                                                         name: "displayCurrentMeasurementPopoverNotification",
                                                         
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(ViewController.displaySavedHistoryGraphs),
                                                         
                                                         name: "displaySavedHistoryGraphsNotification",
                                                         
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(ViewController.displayAlertThereIsNoDataController),
                                                         
                                                         name: "displayAlertThereIsNoDataNotification",
                                                         
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(ViewController.displayErrorMessage),
                                                         
                                                         name: "displayErrorMessage",
                                                         
                                                         object: nil)
        
        // Watch Bluetooth connection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: BLEServiceChangedStatusNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.deviceRotated), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    
    func addAttributesToContainerGraph(){
        
        // Labe1: pressure value
        labelPressure.numberOfLines = 10
        labelPressure.text = " Last messure \n\n Systolic:\n Diastolic:\n Average:"
        labelPressure.textColor = UIColor.whiteColor()
        labelPressure.backgroundColor =  UIColor(red: 11/255, green: 44/255, blue: 65/255, alpha: 0.7)
        labelPressure.layer.cornerRadius = 5
        
        
        // Label2: heart rate value
        labelHeartRate.numberOfLines = 10
        labelHeartRate.text = " Last messure \n\n Heart Rate:"
        labelHeartRate.textColor = UIColor.whiteColor()
        labelHeartRate.backgroundColor =  UIColor(red: 11/255, green: 44/255, blue: 65/255, alpha: 0.7)
        labelHeartRate.layer.cornerRadius = 10
        
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            labelPressure.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            labelHeartRate.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        case .iPhone:
            labelPressure.font = UIFont(name: "HelveticaNeue-Light", size: 12)
            labelHeartRate.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        }
        
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
        
        let color1 = UIColor.whiteColor().CGColor
        
        let color2 = UIColor(red: 0/255, green: 64/255, blue: 128/255, alpha: 0.7).CGColor
        
        gradientLayer.colors = [color1, color2]
        
        gradientLayer.locations = [0.1, 1]
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        
        gradientLayer.accessibilityElementAtIndex(0)
        
        view.layer.insertSublayer(gradientLayer, atIndex:0)
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 64/255, blue: 128/255, alpha: 1.0)
        
        labelHeartRate.clipsToBounds = true
        
        labelHeartRate.layer.cornerRadius = 10
        
        labelPressure.clipsToBounds = true
        
        labelPressure.layer.cornerRadius = 10
        
        currentMeasurementLabel.clipsToBounds = true
        
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
        
        //theLegend.backgroundColor = UIColor.groupTableViewBackgroundColor().CGColor
        
        theLegendHeartRate.cornerRadius = 10.0
        
        //theLegendHeartRate.backgroundColor = UIColor.groupTableViewBackgroundColor().CGColor
        // Portrait
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
    
    func insertPoint(){

        if VectorPhysiologicalVariables.systolicPressure.count > 0 && VectorPhysiologicalVariables.diastolicPressure.count > 0 && VectorPhysiologicalVariables.averagePressure.count > 0 && VectorPhysiologicalVariables.heartRate.count > 0{
            
            let style = CPTMutableTextStyle()
            style.color = CPTColor.blackColor()
            style.fontName = "Helvetica-Neue"
            style.fontSize = 12.0
            
            var text =  VectorPhysiologicalVariables.measuringTime.last
            
            let hourMS = text?.componentsSeparatedByString(":")
            let currentHour = Int(hourMS![0])
            let currentMinute = Int(hourMS![1])
            let currentSecond = hourMS![2]
            let configureOrNotConfigureHour = currentSecond.componentsSeparatedByString(".")
            
            /*
            let horaActual = "00:30:42"
            
            let meassureHour = configurationHourInstance.horaNoConfigurada(horaActual,horaEncendidoDispositivo: horaEncendidoDispositivo)
            print(startDeviceHour)
            print(meassureHour)
 
             */
            /////////
            //var configurationHour:String?
            
            //var hourOnDevice:String?
            
            
            // Hour
            if configureOrNotConfigureHour.count > 1{
            if configureOrNotConfigureHour[1] == "c"{
                
                text = "\(currentHour!):\(currentMinute!):\(configureOrNotConfigureHour[0])"
                print("hora configurada")
                
            }else{
                
                    ////////// Calcula la hora en que se encendio el monitor
                
                    let horaConexion = configurationHour
                    let tiempoDispositivoEncendido = hourOnDevice
                    let startDeviceHour = configurationHourInstance.horaInicioDispositivo(horaConexion!,tiempoDispositivoEncendido: (tiempoDispositivoEncendido?.componentsSeparatedByString(".")[0])!)
                
                    print("hora de encendido del monitor")
                    print(startDeviceHour)
                    print("tiempo dispositivo encendido")
                    print(tiempoDispositivoEncendido)
                    print("hora actual recibida")
                    print("\(currentHour!):\(currentMinute!):\(configureOrNotConfigureHour[0])")
                
                    if horaConexion != nil {
                        // Calcula horas no configuradas
                        let horaEncendidoDispositivo = startDeviceHour
                        
                        let currentHour = "\(currentHour!):\(currentMinute!):\(configureOrNotConfigureHour[0])"
                        
                        text = configurationHourInstance.horaNoConfigurada(currentHour,horaEncendidoDispositivo: horaEncendidoDispositivo)
                        VectorPhysiologicalVariables.measuringTime[VectorPhysiologicalVariables.measuringTime.count - 1] = text!
                    }
                }
            }
            
            var reloadGraphData = false
            
            if configureOrNotConfigureHour.count > 1{
            
                if configureOrNotConfigureHour[1] == "c"{
                
                    reloadGraphData = false
                
                }else{
                    
                    reloadGraphData = true
                
                }
            }
            
            if reloadGraphData == false{
                
                let measuringHour =  VectorPhysiologicalVariables.measuringTime.last?.componentsSeparatedByString(".")[0]
                var hour = measuringHour?.componentsSeparatedByString(":")[0]
                var minutes = measuringHour?.componentsSeparatedByString(":")[1]
                var seconds = measuringHour?.componentsSeparatedByString(":")[2]
                
                if Int(hour!)! < 10{
                    hour = "0" + hour!
                }
                if Int(minutes!)! < 10{
                    minutes = "0" + minutes!
                }
                if Int(seconds!)! < 10{
                    seconds = "0" + seconds!
                }
                
                // xAxis pressure graph
                let axisSet = pressuresGraph.axisSet as! CPTXYAxisSet
                
                let xAxis = axisSet.xAxis!
                
                let xLabel = CPTAxisLabel.init(text: String(measuringHour!), textStyle: style)
                xLabel.tickLocation = Double(VectorPhysiologicalVariables.measuringTime.count)/10.0
                if (VectorPhysiologicalVariables.measuringTime.count - 1)%2 == 0{
                    locations.insert(Double(VectorPhysiologicalVariables.measuringTime.count)/10.0)
                }
                xLabel.offset = 0
                labels.insert(xLabel)
                xAxis.majorTickLocations = locations
                xAxis.axisLabels = labels
                
                
                // xAxis heart rate graph
                let axisSetHeartRate = heartRateGraph.axisSet as! CPTXYAxisSet
                let xAxisHeartRate = axisSetHeartRate.xAxis!
                let xLabelHeartRate = CPTAxisLabel.init(text: String(measuringHour!), textStyle: style)
                xLabelHeartRate.tickLocation = Double(VectorPhysiologicalVariables.measuringTime.count)/10.0
                if (VectorPhysiologicalVariables.measuringTime.count - 1)%2 == 0{
                    locationsHeartRate.insert(Double(VectorPhysiologicalVariables.measuringTime.count)/10.0)
                }
                xLabelHeartRate.offset = 0
                labelsHeartRate.insert(xLabelHeartRate)
                xAxisHeartRate.majorTickLocations = locationsHeartRate
                xAxisHeartRate.axisLabels = labelsHeartRate
                
                
                pressuresGraph.plotWithIdentifier(0)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.systolicPressure.count-1), numberOfRecords: 1)
                pressuresGraph.plotWithIdentifier(1)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.diastolicPressure.count-1), numberOfRecords: 1)
                pressuresGraph.plotWithIdentifier(2)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.averagePressure.count-1), numberOfRecords: 1)
                heartRateGraph.plotWithIdentifier(3)?.insertDataAtIndex(UInt(VectorPhysiologicalVariables.heartRate.count-1), numberOfRecords: 1)
            }else{
                
                let pressureSystolicLastElement = VectorPhysiologicalVariables.systolicPressure[VectorPhysiologicalVariables.heartRate.count - 1]
                let pressureDiastolicLastElement = VectorPhysiologicalVariables.diastolicPressure[VectorPhysiologicalVariables.diastolicPressure.count - 1]
                let averagePressureLastElement = VectorPhysiologicalVariables.averagePressure[VectorPhysiologicalVariables.averagePressure.count - 1]
                let heartRateLastElement = VectorPhysiologicalVariables.heartRate[VectorPhysiologicalVariables.heartRate.count - 1]
                let measuringTimeLastElement = VectorPhysiologicalVariables.measuringTime[VectorPhysiologicalVariables.measuringTime.count - 1]
                
                VectorPhysiologicalVariables.systolicPressure.removeAtIndex(VectorPhysiologicalVariables.systolicPressure.count - 1)
                VectorPhysiologicalVariables.diastolicPressure.removeAtIndex(VectorPhysiologicalVariables.diastolicPressure.count - 1)
                VectorPhysiologicalVariables.averagePressure.removeAtIndex(VectorPhysiologicalVariables.averagePressure.count - 1)
                
                VectorPhysiologicalVariables.heartRate.removeAtIndex(VectorPhysiologicalVariables.heartRate.count - 1)
                VectorPhysiologicalVariables.measuringTime.removeAtIndex(VectorPhysiologicalVariables.measuringTime.count - 1)
                
                
                VectorPhysiologicalVariables.systolicPressure.insert(pressureSystolicLastElement, atIndex: 0)
                VectorPhysiologicalVariables.diastolicPressure.insert(pressureDiastolicLastElement, atIndex: 0)
                VectorPhysiologicalVariables.averagePressure.insert(averagePressureLastElement, atIndex: 0)
                VectorPhysiologicalVariables.heartRate.insert(heartRateLastElement, atIndex: 0)
                VectorPhysiologicalVariables.measuringTime.insert(measuringTimeLastElement, atIndex: 0)
                
                for i in 0..<VectorPhysiologicalVariables.measuringTime.count{
                    let measuringHour:String?
                    if VectorPhysiologicalVariables.measuringTime[i].componentsSeparatedByString(".").count >= 1{
                        measuringHour =  VectorPhysiologicalVariables.measuringTime[i].componentsSeparatedByString(".")[0]
                    }else{
                        measuringHour =  VectorPhysiologicalVariables.measuringTime[i]
                    }
                
                print("hora !!!")
                print(measuringHour)
                var xLabelHour = measuringHour!.componentsSeparatedByString(":")
                var hour = xLabelHour[0]
                let minute = xLabelHour[1]
                var seconds = xLabelHour[2]
                
                if Int(seconds)<10{
                    seconds = "0" + seconds
                }
                    
                if Int(minute)<10{
                    hour = hour + ":" + "0" + minute + ":" + seconds
                }else{
                    hour = measuringHour!
                }
                
            
                    
                // xAxis pressure graph
                let axisSet = pressuresGraph.axisSet as! CPTXYAxisSet
                
                let xAxis = axisSet.xAxis!
                
                let xLabel = CPTAxisLabel.init(text: String(hour), textStyle: style)
                xLabel.tickLocation = Double(i + 1)/10.0
                if (VectorPhysiologicalVariables.measuringTime.count - 1)%2 == 0{
                    locations.insert(Double(VectorPhysiologicalVariables.measuringTime.count)/10.0)
                }
                xLabel.offset = 0
                labels.insert(xLabel)
                xAxis.majorTickLocations = locations
                xAxis.axisLabels = labels
                
                
                // xAxis heart rate graph
                let axisSetHeartRate = heartRateGraph.axisSet as! CPTXYAxisSet
                let xAxisHeartRate = axisSetHeartRate.xAxis!
                let xLabelHeartRate = CPTAxisLabel.init(text: String(hour), textStyle: style)
                xLabelHeartRate.tickLocation = Double(i + 1)/10.0
                if (VectorPhysiologicalVariables.measuringTime.count - 1)%2 == 0{
                    locationsHeartRate.insert(Double(VectorPhysiologicalVariables.measuringTime.count)/10.0)
                }
                xLabelHeartRate.offset = 0
                labelsHeartRate.insert(xLabelHeartRate)
                xAxisHeartRate.majorTickLocations = locationsHeartRate
                xAxisHeartRate.axisLabels = labelsHeartRate
                }
                
                pressuresGraph.reloadData()
                heartRateGraph.reloadData()
            }
            
            /*
            let axisSet = pressuresGraph.axisSet as! CPTXYAxisSet
            
            var locations = Set<NSNumber>()
            var labels:Set<CPTAxisLabel> = Set<CPTAxisLabel>()
            let xAxis = axisSet.xAxis!
            //xAxis.labelingPolicy = .None
            //xAxis.hidden = false
            let style = CPTMutableTextStyle()
            style.color = CPTColor.blackColor()
            style.fontName = "Helvetica-Neue"
            style.fontSize = 12.0

            let xLabel = CPTAxisLabel.init(text: String(1), textStyle: style)
            xLabel.tickLocation = VectorPhysiologicalVariables.vectorNumberOfSamples.last!
            
            locations.insert(VectorPhysiologicalVariables.vectorNumberOfSamples.last!)
            
            xLabel.offset = 0
            labels.insert(xLabel)
            xAxis.majorTickLocations = locations
            xAxis.axisLabels = labels
            */
            // Label update with latest measures
            labelPressure.text = " Last messure \n\n Systolic:  \(VectorPhysiologicalVariables.systolicPressure.last!) mmHg\n Diastolic: \(VectorPhysiologicalVariables.diastolicPressure.last!) mmHg\n Average:  \(VectorPhysiologicalVariables.averagePressure.last!) mmHg"
            labelHeartRate.text = " Last messure \n\n Heart Rate: \(VectorPhysiologicalVariables.heartRate.last!) BPM"
        
            //Change the x and y range.
        
            autoSetXYRangePressureGraphAndHeartRateGraph()
        
            if defaults.arrayForKey("VectorToUpLoadServer")?.count > 0{
                // Check internet connection to upload lost data
                let conexion = Reachability.isConnectedToNetwork()
                
                if conexion == true{
                    for i in defaults.arrayForKey("VectorToUpLoadServer")!{
                        upLoadLostDataToServer(i as! String)
                    }
                }
            }
            
            uploadToServerDataBaseSQL(VectorPhysiologicalVariables.systolicPressure.last!,diastolicPressure: VectorPhysiologicalVariables.diastolicPressure.last!,mediumPressure: VectorPhysiologicalVariables.averagePressure.last!,heartRate: VectorPhysiologicalVariables.heartRate.last!,hour:(VectorPhysiologicalVariables.measuringTime.last?.componentsSeparatedByString(".")[0])!)
        }
    }
    
    /**
     Insert data into data base SQL (Systolic pressure, diastolic pressure, medium pressure heart rate, hour and date)
    */
    func uploadToServerDataBaseSQL(systolicPressure: Double,diastolicPressure: Double,mediumPressure: Double,heartRate: Double, hour:String){
        
        // todays date.
        let date = NSDate()
        
        let postString = "a=\(systolicPressure)&b=\(diastolicPressure)&c=\(mediumPressure)&d=\(heartRate)&e=\(hour)&f=\(date.year)-\(date.month)-\(date.day)"
        requestSetDataBaseSQL.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(requestSetDataBaseSQL) {
            data, response, error in
            
            if error != nil {
                //print("error=\(error)")
                if defaults.arrayForKey("VectorToUpLoadServer")?.count > 0{
                    VectorPhysiologicalVariables.vectorToUploadServer = defaults.arrayForKey("VectorToUpLoadServer")!
                }
                VectorPhysiologicalVariables.vectorToUploadServer.append(postString)
                defaults.setObject(VectorPhysiologicalVariables.vectorToUploadServer, forKey: "VectorToUpLoadServer")
                print("variables almacenadas db sql")
                print(defaults.arrayForKey("VectorToUpLoadServer"))
                return
            }

            print("response = \(response)")
            
            //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    func upLoadLostDataToServer(lostData:String){
        
        //print(defaults.arrayForKey("VectorToUpLoadServer")?.count)
        
        let postString = lostData
        requestSetDataBaseSQL.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(requestSetDataBaseSQL) {
            data, response, error in
            
            if error != nil {
                
                return
            }
            
            print("response = \(response)")
            
            //let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print("responseString = \(responseString)")
            defaults.removeObjectForKey("VectorToUpLoadServer")
        }
        task.resume()
        
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
        
        if VectorPhysiologicalVariables.measuringTime[indexPoint].componentsSeparatedByString(".").count >= 1{
            additionalInformationPopup.measuringTimeString = VectorPhysiologicalVariables.measuringTime[indexPoint].componentsSeparatedByString(".")[0]
        }else{
            additionalInformationPopup.measuringTimeString = VectorPhysiologicalVariables.measuringTime[indexPoint]
        }
        
        let presentationController = additionalInformationPopup.popoverPresentationController!
        presentationController.permittedArrowDirections = UIPopoverArrowDirection.Any
        additionalInformationPopup.preferredContentSize = CGSize(width: 320, height: 200)
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
        
        graphicsEnabledHeight = Double(view.frame.height) - 4*Double((navigationController?.navigationBar.frame.height)!)
        
        graphicsEnabledWidth = Double(view.frame.width)
        
        
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
                imageStatusConnection.frame = CGRect(x: 0, y: 70, width: 21, height: 21)
                
                // Status connection label
                statusConnectionLabel.frame = CGRect(x: 20, y: 70, width: 188, height: 21)
                
                // Labe1: pressure value
                labelPressure.frame = CGRect(x: Int(graphicsEnabledWidth!) - 140, y: Int(graphicsEnabledHeight!/2)-20, width: 130, height: 80)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: Int(graphicsEnabledWidth!) - 140, y: Int(graphicsEnabledHeight!)+20, width: 130, height: 50)
                
                
                pressuresGraph.legendDisplacement = CGPointMake(CGFloat(graphicsEnabledWidth!/1.8), -20.0)
                
                heartRateGraph.legendDisplacement = CGPointMake(CGFloat(graphicsEnabledWidth!/1.8), -20.0)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 10, y: 100, width: Int(graphicsEnabledWidth!) - 20, height: Int(graphicsEnabledHeight!/2)+10)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 10, y: Int(graphicsEnabledHeight!/2) + 110, width: Int(graphicsEnabledWidth!) - 20, height: Int(graphicsEnabledHeight!/2)+10)
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
                imageStatusConnection.frame = CGRect(x: 0, y: 40, width: 21, height: 21)
                
                // Status connection label
                statusConnectionLabel.frame = CGRect(x: 20, y: 40, width: 188, height: 21)
                
                // Labe1: pressure value
                labelPressure.frame = CGRect(x: Int(graphicsEnabledWidth!/2)-130, y: Int(graphicsEnabledHeight!)-40, width: 130, height: 80)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: Int(graphicsEnabledWidth!)-140, y: Int(graphicsEnabledHeight!)-40, width: 130, height: 50)
                
                pressuresGraph.legendDisplacement = CGPointMake(CGFloat(graphicsEnabledWidth!/4), -20.0)
                
                heartRateGraph.legendDisplacement = CGPointMake(CGFloat(graphicsEnabledWidth!/4), -20.0)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 20, y: 70, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: Int(graphicsEnabledWidth!/2) + 10, y: 70, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
            }
  
        }
 
    }
    
    func displayDisconnectBluetoothMessage(){
        print("revisar conexion bluetooth")
        //let alertController = UIAlertController(title: "There is no connection", message: "Check connection", preferredStyle:UIAlertControllerStyle.Alert)
        //self.presentViewController(alertController, animated: true, completion: nil)
    }

    func displayCurrentMeasurementPopover(){
        
        let popoverContent = (self.storyboard?.instantiateViewControllerWithIdentifier("currentMeasurement"))! as! GBCCurrentMeasurementViewController
        
        popoverContent.systolicPressureString = String(VectorPhysiologicalVariables.systolicPressure.last!) + " mmHg"
        popoverContent.diastolicPressureString = String(VectorPhysiologicalVariables.averagePressure.last!) + " mmHg"
        popoverContent.averagePressureString = String(VectorPhysiologicalVariables.diastolicPressure.last!) + " mmHg"
        popoverContent.heartRatePressureString = String(VectorPhysiologicalVariables.heartRate.last!) + " BPM"
        popoverContent.batteryLevelString = String(VectorPhysiologicalVariables.batteryLevel.last!) + " %"
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            let nav = UINavigationController(rootViewController: popoverContent)
            nav.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover = nav.popoverPresentationController
            popoverContent.preferredContentSize = CGSizeMake(500,500)
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRectMake(self.view.frame.width/2,self.view.frame.height/6,0,0)
            
            self.presentViewController(nav, animated: true, completion: nil)
        case .iPhone:
            let popoverContentIPhone = (self.storyboard?.instantiateViewControllerWithIdentifier("currentMeasurementiPhone"))! as! GBCCurrentMeasurementViewController
            navigationController?.pushViewController(popoverContentIPhone, animated: true)
        }
    }
    
    /**
     Auto set XY range
     */
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
    
    /**
     
     */
    func scatterPlot(plot: CPTScatterPlot, plotSymbolWasSelectedAtRecordIndex index: Int, withEvent event: UIEvent) {
        
        let touch = event.allTouches()?.first?.preciseLocationInView(self.view)
        displayGeneralInformationPopPup(touch!, plotIdentifier: plot.identifier as! NSInteger, indexPoint: index)
        
    }
    
    func displayAlertThereIsNoDataController(){
        if internetConnectionError == true{
            let alert = UIAlertController(title: "Connection fail", message: "Check your internet connection", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Done", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
        }else{
            let alert = UIAlertController(title: "Connection fail", message: "There is not data", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Done", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
        }

    }
    
    func displaySavedHistoryGraphs(){
        
        let popoverContent = (self.storyboard?.instantiateViewControllerWithIdentifier("savedHistoryGraphs"))
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            /*
            let nav:UINavigationController?
            nav = UINavigationController(rootViewController: popoverContent!)
            nav!.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover = nav!.popoverPresentationController
            popoverContent!.preferredContentSize = CGSizeMake(self.view.frame.width,600)
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRectMake(100,100,0,0)
 
            self.presentViewController(nav!, animated: true, completion: nil)
             */
            navigationController?.pushViewController(popoverContent!, animated: true)
        case .iPhone:
            
            navigationController?.pushViewController(popoverContent!, animated: true)
        }
        
    }
    
    func displayErrorMessage(){
        let alertController:UIAlertController?
        
        switch typeError!{
        case 1:
            alertController = UIAlertController(title: "Device error", message: "e\(typeError!). Desconexión de manguera", preferredStyle:UIAlertControllerStyle.Alert)
        case 2:
            alertController = UIAlertController(title: "Device error", message: "e\(typeError!). Fugas en el circuito", preferredStyle:UIAlertControllerStyle.Alert)
        case 3:
            alertController = UIAlertController(title: "Device error", message: "e\(typeError!). Presión incorrecta", preferredStyle:UIAlertControllerStyle.Alert)
        case 4:
            alertController = UIAlertController(title: "Device error", message: "e\(typeError!). Se cancela medición desde el monitor", preferredStyle:UIAlertControllerStyle.Alert)
        case 5:
            alertController = UIAlertController(title: "Device error", message: "e\(typeError!). No se pudo calcular frecuencia cardiaca", preferredStyle:UIAlertControllerStyle.Alert)
        case 6:
            alertController = UIAlertController(title: "Device error", message: "e\(typeError!). Presión incorrecta", preferredStyle:UIAlertControllerStyle.Alert)
        default:
            alertController = UIAlertController(title: "Device error", message: "Default", preferredStyle:UIAlertControllerStyle.Alert)
        }
        alertController!.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
        self.presentViewController(alertController!, animated: true, completion: nil)
    }

    // MARK: - Buttons
    
    @IBAction func configurationButton(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let documentationTableViewController = storyboard.instantiateViewControllerWithIdentifier("sliderConfiguration")
        documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = documentationTableViewController.popoverPresentationController!
        documentationTableViewController.preferredContentSize = CGSizeMake(380,450)
        
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
        documentationTableViewController.preferredContentSize = CGSizeMake(350,150)
        
        popover.permittedArrowDirections = .Any
        
        // Depending on the source, set the popover properties accordingly.
        if let barButtonItem = sender as? UIBarButtonItem{
            popover.barButtonItem = barButtonItem
        } else if let view = sender as? UIView{
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
        
        //NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentTimeToPeripheral", object: nil, userInfo: nil)
        popover.delegate = self
        self.presentViewController(documentationTableViewController, animated: true, completion: nil)
    }
    
    @IBAction func currentMeasurementButton(sender: AnyObject) {
        //displayCurrentMeasurementPopover()
        
        currentMeasurementLabel.setTitle("Get a measure", forState: .Normal)
        
        activeCurrentMeasurementFlag = true
        
        NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentMeasurementToPeripheral", object: nil, userInfo: nil)
        /*
        if activeCurrentMeasurementFlag == false{
            
            currentMeasurementLabel.setTitle("Cancel measure", forState: .Normal)
            
            activeCurrentMeasurementFlag = true
            
            NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentMeasurementToPeripheral", object: nil, userInfo: nil)
        }else{
            currentMeasurementLabel.setTitle("Current measurement", forState: .Normal)
            
            activeCurrentMeasurementFlag = false
            
            NSNotificationCenter.defaultCenter().postNotificationName("cancelCurrentMeasurementToPeripheral", object: nil, userInfo: nil)
            
        }*/
        
    }
    
    @IBAction func autoSetGraph(sender: AnyObject) {
        //Change the x and y range.
        autoSetXYRangePressureGraphAndHeartRateGraph()
    }
    
    @IBAction func displayCalendar(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            
            let documentationTableViewController = storyboard.instantiateViewControllerWithIdentifier("calendarViewControllerIPad")
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
            //NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentTimeToPeripheral", object: nil, userInfo: nil)
            
            self.presentViewController(documentationTableViewController, animated: true, completion: nil)
            
        case .iPhone:
            
            let documentationTableViewController = storyboard.instantiateViewControllerWithIdentifier("calendarViewControllerIPhone")
            
            //NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentTimeToPeripheral", object: nil, userInfo: nil)
            navigationController?.pushViewController(documentationTableViewController, animated: true)
        }
    }
}
// MARK: - Extension
/**
    Extension popover presentation controller
 */
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
public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

