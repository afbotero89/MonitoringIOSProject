//
//  ViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 27/4/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit
import SystemConfiguration


class ViewControllerPatientVersion: GBCPlotsViewController, UIPopoverPresentationControllerDelegate  {
    
    /// Systolic pressure graph core plot
    let systolicPressurePlot = CPTScatterPlot()
    
    /// Systolic pressure graph core plot
    let diastolicPressurePlot = CPTScatterPlot()
    
    /// Average pressure graph core plot
    let averagePressurePlot = CPTScatterPlot()
    
    /// heart rate graph core plot
    let heartRatePressurePlot = CPTScatterPlot()
    
    /// Graphics container pressure(systolic, average and diastolic pressure)
    var pressureContainerGraph = CPTGraphHostingView()
    
    /// Graphic container heart rate
    var heartRateContainerGraph = CPTGraphHostingView()
    
    /// Request to remote data base sql: Type post
    let requestSetDataBaseSQL = NSMutableURLRequest(url: NSURL(string:"http://www.sibxe.co/appMonitoreo/querysToDatabase.php")! as URL)
    
    /// Request to remote data base sql: Type get
    let requestGetDayMonthYearDataBaseSQL = NSMutableURLRequest(url: NSURL(string:"http://www.sibxe.co/appMonitoreo/querysToDatabaseGetDayMonthYear.php")! as URL)
    
    /// Remote server response
    var serverResponse:NSString?
    
    /// Bluetooth manager
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
    
    @IBOutlet weak var imageStatusConnection: UIImageView!
    
    @IBOutlet weak var constraintSeparation: NSLayoutConstraint!
    
    @IBOutlet weak var batteryLevelImageView: UIImageView!
    
    @IBOutlet weak var batteryLevelTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title =  NSLocalizedString("Monitoring", comment: "")
        
        //statusConnectionLabel.text = NSLocalizedString("Scanning bluetooth", comment: "") + "..."
        
        currentMeasurementLabel.setTitle(NSLocalizedString("Get a measure", comment: ""), for: .normal)
        
        addAttributesToViewController()
        
        // Initialize the bluetooth manager.
        self.bluetoothManager = BluetoothManager()
        
        notifications()

        // Do any additional setup after loading the view, typically from a nib.
        systolicPressurePlot.identifier = 0 as (NSCoding & NSCopying & NSObjectProtocol)?
        diastolicPressurePlot.identifier = 1 as (NSCoding & NSCopying & NSObjectProtocol)?
        averagePressurePlot.identifier = 2 as (NSCoding & NSCopying & NSObjectProtocol)?
        heartRatePressurePlot.identifier = 3 as (NSCoding & NSCopying & NSObjectProtocol)?
        
        // Set the lineStyle for the plot
        systolicPressurePlot.dataSource = self
        diastolicPressurePlot.dataSource = self
        averagePressurePlot.dataSource = self
        heartRatePressurePlot.dataSource = self
        
        // Plot simbol
        let lowSymbol = CPTPlotSymbol.ellipse()
        lowSymbol.fill = CPTFill(color: CPTColor.black())
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            lowSymbol.size = CGSize(width: 6, height: 6) //Inflection point size
        case .iPhone:
            lowSymbol.size = CGSize(width: 3, height: 3) //Inflection point size
        }
        
    
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
        
        systolicPressurePlot.title = NSLocalizedString("Systolic pressure", comment: "")
        diastolicPressurePlot.title = NSLocalizedString("Diastolic pressure", comment: "")
        averagePressurePlot.title =  NSLocalizedString("Average pressure", comment: "")
        heartRatePressurePlot.title = NSLocalizedString("Heart Rate", comment: "")
        
        let attrs = [
            NSForegroundColorAttributeName : UIColor.black,
            NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 16)!,
            
        ]
        
        pressuresGraph.title = NSLocalizedString("Pressure graphics", comment: "")
        pressuresGraph.titleTextStyle = CPTTextStyle(attributes: attrs)
        heartRateGraph.title = NSLocalizedString("Heart rate graphic", comment: "")
        heartRateGraph.titleTextStyle = CPTTextStyle(attributes: attrs)
        
        pressuresGraph.add(systolicPressurePlot)
        pressuresGraph.add(diastolicPressurePlot)
        pressuresGraph.add(averagePressurePlot)
        heartRateGraph.add(heartRatePressurePlot)

        let plotSpacePressureGraph = pressuresGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpacePressureGraph.yRange = CPTPlotRange(location: 0, length: 200)
        
        let plotSpaceHeartRateGraph = heartRateGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpaceHeartRateGraph.yRange = CPTPlotRange(location: 0, length: 200)
        
        setLegendGraph()
        
        addAttributesToContainerGraph()
        
        requestSetDataBaseSQL.httpMethod = "POST"
        
        getDataFromDataBaseSQLDayMonthYear()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        userSelectViewController = UserSelectViewPrincipalViewController.realTimeViewController
        
    }
    override func viewDidAppear(_ animated: Bool) {
        deviceRotated()
        
        batteryLevelImageView.image = UIImage(named: "BatteryLevel0")
        
        let storyBoardPatientVersion =  UIStoryboard(name: "MainPatientVersion", bundle: nil)
        
        let principalView = storyBoardPatientVersion.instantiateViewController(withIdentifier: "currentMeasurementNavigationController")
        
        self.present(principalView, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    }
    
    // MARK: - Functions
    
    /**
     Notification Center
     */
    func notifications(){
    
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(ViewController.insertPoint),
                                                         
                                                         name: NSNotification.Name(rawValue: "insertNewPlot"),
                                                         
                                                         object: nil)
        

        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(ViewController.displaySavedHistoryGraphs),
                                                         
                                                         name: NSNotification.Name(rawValue: "displaySavedHistoryGraphsNotification"),
                                                         
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(ViewController.displayAlertThereIsNoDataController),
                                                         
                                                         name: NSNotification.Name(rawValue: "displayAlertThereIsNoDataNotification"),
                                                         
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(ViewController.startAnimation),
                                                         
                                                         name: NSNotification.Name(rawValue: "startAnimation"),
                                                         
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(ViewController.displayErrorMessageMainView),
                                                         
                                                         name: NSNotification.Name(rawValue: "displayErrorMessageMainViewNotification"),
                                                         
                                                         object: nil)
        
        // Watch Bluetooth connection
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    
    func addAttributesToContainerGraph(){
        
        // Labe1: pressure value
        labelPressure.numberOfLines = 10
        labelPressure.text = " \(NSLocalizedString("Last messure", comment: "")) \n\n \(NSLocalizedString("Systolic", comment: "")):\n \(NSLocalizedString("Average", comment: "")):\n \(NSLocalizedString("Diastolic", comment: "")):"
        labelPressure.textColor = UIColor.white
        labelPressure.backgroundColor =  UIColor(red: 11/255, green: 44/255, blue: 65/255, alpha: 0.7)
        labelPressure.layer.cornerRadius = 5
        
        
        // Label2: heart rate value
        labelHeartRate.numberOfLines = 10
        labelHeartRate.text = " \(NSLocalizedString("Last messure", comment: "")) \n\n \(NSLocalizedString("Heart Rate", comment: "")):"
        labelHeartRate.textColor = UIColor.white
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
        pressureContainerGraph.layer.borderColor = UIColor.black.cgColor
        pressureContainerGraph.layer.cornerRadius = 20
        pressureContainerGraph.hostedGraph = pressuresGraph
        pressureContainerGraph.addSubview(labelPressure)
        
        
        // attributes heart rate container graph
        heartRateContainerGraph.layer.borderWidth = 1
        heartRateContainerGraph.layer.borderColor = UIColor.black.cgColor
        heartRateContainerGraph.layer.cornerRadius = 20
        heartRateContainerGraph.hostedGraph = heartRateGraph
        
        
        // Insert subviews
        view.addSubview(pressureContainerGraph)
        view.addSubview(heartRateContainerGraph)
        view.addSubview(labelHeartRate)
        view.addSubview(labelPressure)
    }
    
    func addAttributesToViewController(){
        
        let color1 = UIColor.white.cgColor
        
        let color2 = UIColor(red: 0/255, green: 64/255, blue: 128/255, alpha: 0.7).cgColor
        
        gradientLayer.colors = [color1, color2]
        
        gradientLayer.locations = [0.1, 1]
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        
        gradientLayer.accessibilityElement(at: 0)
        
        view.layer.insertSublayer(gradientLayer, at:0)
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 64/255, blue: 128/255, alpha: 1.0)
        
        labelHeartRate.clipsToBounds = true
        
        labelHeartRate.layer.cornerRadius = 10
        
        labelPressure.clipsToBounds = true
        
        labelPressure.layer.cornerRadius = 10
        
        currentMeasurementLabel.clipsToBounds = true
        
        currentMeasurementLabel.layer.cornerRadius = 10
        
        //statusConnectionLabel.clipsToBounds = true
        
        //statusConnectionLabel.layer.cornerRadius = 10
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
        // Portrait
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
    
    func insertPoint(){

        if VectorPhysiologicalVariables.systolicPressure.count > 0 && VectorPhysiologicalVariables.diastolicPressure.count > 0 && VectorPhysiologicalVariables.averagePressure.count > 0 && VectorPhysiologicalVariables.heartRate.count > 0{
            
            let style = CPTMutableTextStyle()
            style.color = CPTColor.black()
            style.fontName = "HelveticaNeue-Light"
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                style.fontSize = 12.0
            case .iPhone:
                style.fontSize = 10.0
            }
            
            
            var text =  VectorPhysiologicalVariables.measuringTime.last
            
            let hourMS = text?.components(separatedBy: ":")
            let currentHour = Int(hourMS![0])
            let currentMinute = Int(hourMS![1])
            let currentSecond = hourMS![2]
            
            let configureOrNotConfigureHour = currentSecond.components(separatedBy: ".")
            
            // Hour
            if configureOrNotConfigureHour.count > 1{
            if configureOrNotConfigureHour[1] == "c"{
                
                text = "\(currentHour!):\(currentMinute!):\(configureOrNotConfigureHour[0])"
                
            }else{
                
                    ////////// Calcula la hora en que se encendio el monitor
                
                    let horaConexion = configurationHour
                    let tiempoDispositivoEncendido = hourOnDevice
                
                    let startDeviceHour = configurationHourInstance.horaInicioDispositivo(horaConexion!,tiempoDispositivoEncendido: (tiempoDispositivoEncendido?.components(separatedBy: ".")[0])!)
                
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
            
            if VectorPhysiologicalVariables.measuringTime.count >= 2{
                
                
                let measuringHourLast =  VectorPhysiologicalVariables.measuringTime.last?.components(separatedBy: ".")[0]
                
                let hourLast = measuringHourLast?.components(separatedBy: ":")[0]
                let minutesLast = measuringHourLast?.components(separatedBy: ":")[1]
                let secondsLast = measuringHourLast?.components(separatedBy: ":")[2]
            
                let measuringHourPenultimate =  VectorPhysiologicalVariables.measuringTime[VectorPhysiologicalVariables.measuringTime.count - 2].components(separatedBy: ".")[0]
                let hourPenultimate = measuringHourPenultimate.components(separatedBy: ":")[0]
                let minutesPenultimate = measuringHourPenultimate.components(separatedBy: ":")[1]
                let secondsPenultimate = measuringHourPenultimate.components(separatedBy: ":")[2]
        
            if configureOrNotConfigureHour.count > 1{
            
                if configureOrNotConfigureHour[1] == "n" || (Int(hourLast!)! < Int(hourPenultimate)!) || ((Int(minutesLast!)! == Int(minutesPenultimate)!) && (Int(minutesLast!)! == Int(minutesPenultimate)!) && (Int(secondsLast!)! < Int(secondsPenultimate)!) || (Int(hourLast!)! == Int(hourPenultimate)!) && (Int(minutesLast!)! < Int(minutesPenultimate)!)){
                
                    reloadGraphData = true
                
                }else{
                    
                    reloadGraphData = false
                
                }
            }
            }else{
            
                if configureOrNotConfigureHour.count > 1{
                    
                    if configureOrNotConfigureHour[1] == "n" {
                        
                        reloadGraphData = true
                        
                    }else{
                        
                        reloadGraphData = false
                        
                    }
                }
                
            
            }
            if reloadGraphData == false{
                
                let measuringHour =  VectorPhysiologicalVariables.measuringTime.last?.components(separatedBy: ".")[0]
                var hour = measuringHour?.components(separatedBy: ":")[0]
                var minutes = measuringHour?.components(separatedBy: ":")[1]
                var seconds = measuringHour?.components(separatedBy: ":")[2]
                
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
                let xLabel:CPTAxisLabel?
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    xLabel = CPTAxisLabel.init(text: String(measuringHour!), textStyle: style)
                case .iPhone:
                    
                    xLabel = CPTAxisLabel.init(text: String(measuringHour!), textStyle: style)
                    xLabel?.rotation = 3.14/3.0;
                    
                }
                
                xLabel!.tickLocation = NSNumber(value: Double(VectorPhysiologicalVariables.measuringTime.count)/10.0)
                if (VectorPhysiologicalVariables.measuringTime.count - 1)%2 == 0{
                    locations.insert(NSNumber(value: Double(VectorPhysiologicalVariables.measuringTime.count)/10.0))
                }
                xLabel!.offset = 0
                labels.insert(xLabel!)
                xAxis.majorTickLocations = locations
                xAxis.axisLabels = labels
                
                
                // xAxis heart rate graph
                let axisSetHeartRate = heartRateGraph.axisSet as! CPTXYAxisSet
                let xAxisHeartRate = axisSetHeartRate.xAxis!
                let xLabelHeartRate = CPTAxisLabel.init(text: String(measuringHour!), textStyle: style)
            
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    print("ipad")
                case .iPhone:
                    xLabelHeartRate.rotation = CGFloat(NSNumber(value: 3.14 / 3.0));
                }
                
                xLabelHeartRate.tickLocation = NSNumber(value:Double(VectorPhysiologicalVariables.measuringTime.count)/10.0)
                if (VectorPhysiologicalVariables.measuringTime.count - 1)%2 == 0{
                    locationsHeartRate.insert(NSNumber(value: Double(VectorPhysiologicalVariables.measuringTime.count)/10.0))
                }
                xLabelHeartRate.offset = 0
                labelsHeartRate.insert(xLabelHeartRate)
                xAxisHeartRate.majorTickLocations = locationsHeartRate
                xAxisHeartRate.axisLabels = labelsHeartRate
                
                pressuresGraph.plot(withIdentifier: 0 as NSCopying?)?.insertData(at: UInt(VectorPhysiologicalVariables.systolicPressure.count-1), numberOfRecords: 1)
                pressuresGraph.plot(withIdentifier: 1 as NSCopying?)?.insertData(at: UInt(VectorPhysiologicalVariables.diastolicPressure.count-1), numberOfRecords: 1)
                pressuresGraph.plot(withIdentifier: 2 as NSCopying?)?.insertData(at: UInt(VectorPhysiologicalVariables.averagePressure.count-1), numberOfRecords: 1)
                heartRateGraph.plot(withIdentifier: 3 as NSCopying?)?.insertData(at: UInt(VectorPhysiologicalVariables.heartRate.count-1), numberOfRecords: 1)
                
                uploadToServerDataBaseSQL(systolicPressure: VectorPhysiologicalVariables.systolicPressure.last!,diastolicPressure: VectorPhysiologicalVariables.diastolicPressure.last!,mediumPressure: VectorPhysiologicalVariables.averagePressure.last!,heartRate: VectorPhysiologicalVariables.heartRate.last!,hour:(VectorPhysiologicalVariables.measuringTime.last?.components(separatedBy: ".")[0])!)
            }else{
                
                let pressureSystolicLastElement = VectorPhysiologicalVariables.systolicPressure[VectorPhysiologicalVariables.heartRate.count - 1]
                let pressureDiastolicLastElement = VectorPhysiologicalVariables.diastolicPressure[VectorPhysiologicalVariables.diastolicPressure.count - 1]
                let averagePressureLastElement = VectorPhysiologicalVariables.averagePressure[VectorPhysiologicalVariables.averagePressure.count - 1]
                let heartRateLastElement = VectorPhysiologicalVariables.heartRate[VectorPhysiologicalVariables.heartRate.count - 1]
                let measuringTimeLastElement = VectorPhysiologicalVariables.measuringTime[VectorPhysiologicalVariables.measuringTime.count - 1]
                
                VectorPhysiologicalVariables.systolicPressure.remove(at: VectorPhysiologicalVariables.systolicPressure.count - 1)
                VectorPhysiologicalVariables.diastolicPressure.remove(at: VectorPhysiologicalVariables.diastolicPressure.count - 1)
                VectorPhysiologicalVariables.averagePressure.remove(at: VectorPhysiologicalVariables.averagePressure.count - 1)
                
                VectorPhysiologicalVariables.heartRate.remove(at: VectorPhysiologicalVariables.heartRate.count - 1)
                VectorPhysiologicalVariables.measuringTime.remove(at: VectorPhysiologicalVariables.measuringTime.count - 1)
                
                
                VectorPhysiologicalVariables.systolicPressure.insert(pressureSystolicLastElement, at: 0)
                VectorPhysiologicalVariables.diastolicPressure.insert(pressureDiastolicLastElement, at: 0)
                VectorPhysiologicalVariables.averagePressure.insert(averagePressureLastElement, at: 0)
                VectorPhysiologicalVariables.heartRate.insert(heartRateLastElement, at: 0)
                VectorPhysiologicalVariables.measuringTime.insert(measuringTimeLastElement, at: 0)
                
                uploadToServerDataBaseSQL(systolicPressure: VectorPhysiologicalVariables.systolicPressure[0],diastolicPressure: VectorPhysiologicalVariables.diastolicPressure[0],mediumPressure: VectorPhysiologicalVariables.averagePressure[0],heartRate: VectorPhysiologicalVariables.heartRate[0],hour:(VectorPhysiologicalVariables.measuringTime[0].components(separatedBy: ".")[0]))
                
                for i in 0..<VectorPhysiologicalVariables.measuringTime.count{
                    let measuringHour:String?
                    if VectorPhysiologicalVariables.measuringTime[i].components(separatedBy: ".").count >= 1{
                        measuringHour =  VectorPhysiologicalVariables.measuringTime[i].components(separatedBy: ".")[0]
                    }else{
                        measuringHour =  VectorPhysiologicalVariables.measuringTime[i]
                    }

                var xLabelHour = measuringHour!.components(separatedBy: ":")
                var hour = xLabelHour[0]
                let minute = xLabelHour[1]
                var seconds = xLabelHour[2]
                
                if Int(seconds)!<10 && seconds.characters.count == 1{
                    seconds = "0" + seconds
                }
                    
                if Int(minute)!<10 && minute.characters.count == 1{
                    hour = hour + ":" + "0" + minute + ":" + seconds
                }else{
                    hour = measuringHour!
                }
   
                // xAxis pressure graph
                let axisSet = pressuresGraph.axisSet as! CPTXYAxisSet
                
                let xAxis = axisSet.xAxis!
                    
                    let xLabel:CPTAxisLabel?
                    switch UserSelectedConfiguration.typeOfDevice!{
                    case .iPad:
                        xLabel = CPTAxisLabel.init(text: String(hour), textStyle: style)
                    case .iPhone:
                        xLabel = CPTAxisLabel.init(text: String(hour), textStyle: style)
                        xLabel?.rotation = 3.14/3.0;
                    }
                
                xLabel!.tickLocation = NSNumber(value: Double(i + 1)/10.0)
                if (VectorPhysiologicalVariables.measuringTime.count - 1)%2 == 0{
                    locations.insert(NSNumber(value: Double(VectorPhysiologicalVariables.measuringTime.count)/10.0))
                }
                xLabel!.offset = 0
                labels.insert(xLabel!)
                xAxis.majorTickLocations = locations
                xAxis.axisLabels = labels
                
                
                // xAxis heart rate graph
                let axisSetHeartRate = heartRateGraph.axisSet as! CPTXYAxisSet
                let xAxisHeartRate = axisSetHeartRate.xAxis!
                let xLabelHeartRate:CPTAxisLabel?
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    xLabelHeartRate = CPTAxisLabel.init(text: String(hour), textStyle: style)
                case .iPhone:
                    
                    xLabelHeartRate = CPTAxisLabel.init(text: String(hour), textStyle: style)
                    
                    xLabelHeartRate?.rotation = CGFloat(NSNumber(value: 3.14/3.0));
                    
                }
                
                xLabelHeartRate!.tickLocation = NSNumber(value: Double(i + 1)/10.0)
                if (VectorPhysiologicalVariables.measuringTime.count - 1)%2 == 0{
                    locationsHeartRate.insert(NSNumber(value: Double(VectorPhysiologicalVariables.measuringTime.count)/10.0))
                }
                xLabelHeartRate!.offset = 0
                labelsHeartRate.insert(xLabelHeartRate!)
                xAxisHeartRate.majorTickLocations = locationsHeartRate
                xAxisHeartRate.axisLabels = labelsHeartRate
                }
                
                pressuresGraph.reloadData()
                heartRateGraph.reloadData()
            }
            

            // Label update with latest measures
            labelPressure.text = " \(NSLocalizedString("Last messure", comment: "")) \n\n \(NSLocalizedString("Systolic", comment: "")):  \(VectorPhysiologicalVariables.systolicPressure.last!) mmHg\n \(NSLocalizedString("Average", comment: "")):  \(VectorPhysiologicalVariables.averagePressure.last!) mmHg\n \(NSLocalizedString("Diastolic", comment: "")): \(VectorPhysiologicalVariables.diastolicPressure.last!) mmHg"
            labelHeartRate.text = " \(NSLocalizedString("Last messure", comment: "")) \n\n \(NSLocalizedString("Heart Rate", comment: "")): \(VectorPhysiologicalVariables.heartRate.last!) BPM"
        
            //Change the x and y range.
        
            autoSetXYRangePressureGraphAndHeartRateGraph()
        /*
            if (defaults.array(forKey: "VectorToUpLoadServer")?.count)! > 0{
                // Check internet connection to upload lost data
                let conexion = Reachability.isConnectedToNetwork()
                
                if conexion == true{
                    for i in defaults.array(forKey: "VectorToUpLoadServer")!{
                        upLoadLostDataToServer(lostData: i as! String)
                    }
                }
            }*/
        }
    }
    
    /**
     Insert data into data base SQL (Systolic pressure, diastolic pressure, medium pressure heart rate, hour and date)
    */
    func uploadToServerDataBaseSQL(systolicPressure: Double,diastolicPressure: Double,mediumPressure: Double,heartRate: Double, hour:String){
        
        // todays date.
        let date = NSDate()
        
        //let postString = "a=\(systolicPressure)&b=\(diastolicPressure)&c=\(mediumPressure)&d=\(heartRate)&e=\(hour)&f=\(date.year)-\(date.month)-\(date.day)"
        let postString = "a=\(systolicPressure)&b=\(diastolicPressure)&c=\(mediumPressure)&d=\(heartRate)&e=\(hour)&f=\("2016")-\("10")-\("28")"
        requestSetDataBaseSQL.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: requestSetDataBaseSQL as URLRequest) {
            data, response, error in
            
            if error != nil {
                
                if (defaultsDB.array(forKey: "VectorToUpLoadServer")?.count)! > 0{
                    VectorPhysiologicalVariables.vectorToUploadServer = defaultsDB.array(forKey: "VectorToUpLoadServer")! as [AnyObject]
                }
                VectorPhysiologicalVariables.vectorToUploadServer.append(postString as AnyObject)
                defaultsDB.set(VectorPhysiologicalVariables.vectorToUploadServer, forKey: "VectorToUpLoadServer")

                return
            }

            print("response = \(response)")

        }
        task.resume()
    }
    
    func upLoadLostDataToServer(lostData:String){
        
        let postString = lostData
        requestSetDataBaseSQL.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: requestSetDataBaseSQL as URLRequest) {
            data, response, error in
            
            if error != nil {
                
                return
            }
            
            print("response = \(response)")
            
            defaultsDB.removeObject(forKey: "VectorToUpLoadServer")
        }
        task.resume()
        
    }
    
    
    func displayGeneralInformationPopPup(location:CGPoint, plotIdentifier: NSInteger, indexPoint:Int){
        
        // Display popup
        let storyboard = UIStoryboard(name: "AditionalInformationPopPup", bundle: nil)
        let additionalInformationPopup:GBCAditionalInformationPopupViewController?
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            additionalInformationPopup = storyboard.instantiateViewController(withIdentifier: "aditionalInformationPopupIpad") as? GBCAditionalInformationPopupViewController
        case .iPhone:
            additionalInformationPopup = storyboard.instantiateViewController(withIdentifier: "aditionalInformationPopupIphone") as? GBCAditionalInformationPopupViewController
        }
        
        additionalInformationPopup!.title = NSLocalizedString("General information", comment: "")
        additionalInformationPopup!.modalPresentationStyle = UIModalPresentationStyle.popover
        
        //let plotSelected = PhysiologicalVariables(rawValue: plotIdentifier)?.displayString()
        
        additionalInformationPopup!.valueSystolicPressureString = String(VectorPhysiologicalVariables.systolicPressure[indexPoint]) + " mmHg"
        
        additionalInformationPopup!.valueAveragePressureString = String(VectorPhysiologicalVariables.averagePressure[indexPoint]) + " mmHg"
        
        additionalInformationPopup!.valueDiastolicPressureString = String(VectorPhysiologicalVariables.diastolicPressure[indexPoint]) + " mmHg"
        
        additionalInformationPopup!.valueHeartRateString = String(VectorPhysiologicalVariables.heartRate[indexPoint]) + " BPM"
        
        if VectorPhysiologicalVariables.measuringTime[indexPoint].components(separatedBy: ".").count >= 1{
            additionalInformationPopup!.measuringTimeString = VectorPhysiologicalVariables.measuringTime[indexPoint].components(separatedBy: ".")[0]
        }else{
            additionalInformationPopup!.measuringTimeString = VectorPhysiologicalVariables.measuringTime[indexPoint]
        }
        
        let presentationController = additionalInformationPopup!.popoverPresentationController!
        presentationController.permittedArrowDirections = UIPopoverArrowDirection.any
        additionalInformationPopup!.preferredContentSize = CGSize(width: 320, height: 200)
        presentationController.sourceView = self.view
        let rect = CGRect(x: location.x, y: location.y, width: 0, height: 0)
        presentationController.sourceRect = rect
        // Set this object as the delegate
        presentationController.delegate = self
        present(additionalInformationPopup!, animated: true, completion: nil)
    }
    
    func connectionChanged(notification: NSNotification) {
        
        // Connection status changed. Indicate on GUI.
        let userInfo = notification.userInfo as! [String: Bool]
        
        //dispatch_async(DispatchQueue.maindispatch_get_main_queue(), {
        DispatchQueue.main.async {
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    self.imageStatusConnection.image = UIImage(named: "Bluetooth_Connected")
                    //self.statusConnectionLabel.text = NSLocalizedString("Connected", comment: "")
                    
                } else {
                    self.imageStatusConnection.image = UIImage(named: "Bluetooth_Disconnected")
                    //self.statusConnectionLabel.text = NSLocalizedString("Disconnected", comment: "")
                    
                }
            }
        }
        /*
        DispatchQueue.main.asynchronously(execute: {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    self.imageStatusConnection.image = UIImage(named: "Bluetooth_Connected")
                    //self.statusConnectionLabel.text = NSLocalizedString("Connected", comment: "")
                
                } else {
                    self.imageStatusConnection.image = UIImage(named: "Bluetooth_Disconnected")
                    //self.statusConnectionLabel.text = NSLocalizedString("Disconnected", comment: "")
                  
                }
            }
        });*/
    }
    
    func deviceRotated(){
        
        graphicsEnabledHeight = Double(view.frame.height) - 4*Double((navigationController?.navigationBar.frame.height)!)
        
        graphicsEnabledWidth = Double(view.frame.width)
        
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation))
        {
            // Portrait
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                constraintSeparation.constant = 170
                
                // Labe1: pressure value
                labelPressure.frame = CGRect(x: 500, y: 360, width: 190, height: 120)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: 500, y: 800, width: 190, height: 80)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 50, y: 140, width: 650, height: 400)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 50, y: 550, width: 650, height: 400)
                
            case .iPhone:
                
                // Labe1: pressure value
                labelPressure.frame = CGRect(x: Int(graphicsEnabledWidth!) - 140, y: Int(graphicsEnabledHeight!/2)-20, width: 130, height: 80)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: Int(graphicsEnabledWidth!) - 140, y: Int(graphicsEnabledHeight!)+25, width: 130, height: 50)
                
                pressuresGraph.legendDisplacement = CGPoint(x: CGFloat(graphicsEnabledWidth!/1.8), y: -20.0)
                
                heartRateGraph.legendDisplacement = CGPoint(x: CGFloat(graphicsEnabledWidth!/1.8), y: -20.0)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 10, y: 100, width: Int(graphicsEnabledWidth!) - 20, height: Int(graphicsEnabledHeight!/2)+10)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 10, y: Int(graphicsEnabledHeight!/2) + 115, width: Int(graphicsEnabledWidth!) - 20, height: Int(graphicsEnabledHeight!/2)+10)
            }
            
        }else{
            
            // Landscape
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                constraintSeparation.constant = 200
                
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
                labelPressure.frame = CGRect(x: Int(graphicsEnabledWidth!/2)-130, y: Int(graphicsEnabledHeight!)-40, width: 130, height: 80)
                
                // Label2: heart rate value
                labelHeartRate.frame = CGRect(x: Int(graphicsEnabledWidth!)-140, y: Int(graphicsEnabledHeight!)-40, width: 130, height: 50)
                
                pressuresGraph.legendDisplacement = CGPoint(x: CGFloat(graphicsEnabledWidth!/4), y: -20.0)
                
                heartRateGraph.legendDisplacement = CGPoint(x: CGFloat(graphicsEnabledWidth!/4), y: -20.0)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 20, y: 70, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: Int(graphicsEnabledWidth!/2) + 10, y: 70, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
            }
  
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
            
            plotSpacePressureGraph.xRange = CPTPlotRange(location: NSNumber(value: startXRange), length: 1)
            plotSpaceHeartRateGraph.xRange = CPTPlotRange(location: NSNumber(value: startXRange), length: 1)
            
        }else{
            plotSpacePressureGraph.xRange = CPTPlotRange(location: 0, length: 1)
            plotSpaceHeartRateGraph.xRange = CPTPlotRange(location: 0, length: 1)
        }
    }
    
    /**
     
     */
    func scatterPlot(plot: CPTScatterPlot, plotSymbolWasSelectedAtRecordIndex index: Int, withEvent event: UIEvent) {
        
        let touch = event.allTouches?.first?.preciseLocation(in: self.view)
        displayGeneralInformationPopPup(location: touch!, plotIdentifier: plot.identifier as! NSInteger, indexPoint: index)
        
    }
    
    func displayAlertThereIsNoDataController(){
        if internetConnectionError == true{
            let alert = UIAlertController(title: NSLocalizedString("Connection fail", comment: ""), message: NSLocalizedString("Check your internet connection", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default) { _ in })
            self.present(alert, animated: true){}
        }else{
            let alert = UIAlertController(title: NSLocalizedString("Connection fail", comment: ""), message: NSLocalizedString("There is not data", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default) { _ in })
            self.present(alert, animated: true){}
        }

    }
    
    func displaySavedHistoryGraphs(){
        
        let popoverContent = (self.storyboard?.instantiateViewController(withIdentifier: "savedHistoryGraphs"))
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:

            navigationController?.pushViewController(popoverContent!, animated: true)
        case .iPhone:
            
            navigationController?.pushViewController(popoverContent!, animated: true)
        }
        
    }
    
    func startAnimation(){
        let popoverContent = (self.storyboard?.instantiateViewController(withIdentifier: "animationViewController"))! as! CBCAnimationViewController
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            
            let nav = UINavigationController(rootViewController: popoverContent)
            nav.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = nav.popoverPresentationController
            
            popoverContent.preferredContentSize = CGSize(width: 500, height: 500)
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: self.view.frame.width/2, y: self.view.frame.height/6, width: 0, height: 0)
            
            self.present(nav, animated: true, completion: nil)
            
        case .iPhone:
            let popoverContentIPhone = (self.storyboard?.instantiateViewController(withIdentifier: "animationViewController"))! as! CBCAnimationViewController

            navigationController?.pushViewController(popoverContentIPhone, animated: true)
        }
    }
    
    func displayErrorMessageMainView(){
        activeCurrentMeasurementFlag = false
        let alertController:UIAlertController?
        //typeError = 1
        
        switch typeError!{
        case 1:
            // Desconexion de manguera
            alertController = UIAlertController(title: "", message: NSLocalizedString("Disconnect hose", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        case 2:
            alertController = UIAlertController(title: "", message: NSLocalizedString("Circuit leaks", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        case 3:
            alertController = UIAlertController(title: "", message: NSLocalizedString("Incorrect pressure", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        case 4:
            alertController = UIAlertController(title: "", message: NSLocalizedString("Monitor measure canceled", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        case 5:
            alertController = UIAlertController(title: "", message: NSLocalizedString("heart rate not caculated", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        case 6:
            alertController = UIAlertController(title: "", message: NSLocalizedString("Incorrect pressure", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        case 7:
            alertController = UIAlertController(title: "", message: NSLocalizedString("Incorrect measure", comment: ""), preferredStyle:UIAlertControllerStyle.alert)
        default:
            alertController = UIAlertController(title: "", message: "Default", preferredStyle:UIAlertControllerStyle.alert)
        }
        
        alertController!.addAction(UIAlertAction(title:  NSLocalizedString("Done", comment: ""), style: .default, handler: {
            action in
            
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                self.dismiss(animated: true, completion: nil)
            case .iPhone:
                _ = self.navigationController?.popViewController(animated: true)
            }
            
        }))
        self.present(alertController!, animated: true, completion: nil)
        
    }
    
    func getDataFromDataBaseSQLDayMonthYear(){
        
        requestGetDayMonthYearDataBaseSQL.httpMethod = "POST"
        
        let postString = ""
        
        requestGetDayMonthYearDataBaseSQL.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: requestGetDayMonthYearDataBaseSQL as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            self.serverResponse = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            PhysiologicalVariablesStoredInDatabaseSQL.dayMonthYearDataBaseSQL = self.serverResponse
            
        }
        
        task.resume()
        
    }

    // MARK: - Buttons
    
    @IBAction func userManagerButton(sender: AnyObject) {
        
        let storyBoardUserManager = UIStoryboard(name: "UserConfiguration", bundle: nil)
        let userManagerSplitViewController = storyBoardUserManager.instantiateViewController(withIdentifier: "splitRootViewController")
        //navigationController?.pushViewController(userManagerSplitViewController, animated: true)
        self.present(userManagerSplitViewController, animated: true, completion: nil)
    }
    
    @IBAction func configurationButton(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let documentationTableViewController = storyboard.instantiateViewController(withIdentifier: "sliderConfiguration")
        documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = documentationTableViewController.popoverPresentationController!
        documentationTableViewController.preferredContentSize = CGSize(width: 380, height: 450)
        
        popover.permittedArrowDirections = .any
        
        // Depending on the source, set the popover properties accordingly.
        if let barButtonItem = sender as? UIBarButtonItem{
            popover.barButtonItem = barButtonItem
        } else if let view = sender as? UIView{
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
        popover.delegate = self
        self.present(documentationTableViewController, animated: true, completion: nil)
    }

    @IBAction func generalInformation(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let documentationTableViewController = storyboard.instantiateViewController(withIdentifier: "generalInformation")
        documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = documentationTableViewController.popoverPresentationController!
        documentationTableViewController.preferredContentSize = CGSize(width: 350, height: 150)
        
        popover.permittedArrowDirections = .any
        
        // Depending on the source, set the popover properties accordingly.
        if let barButtonItem = sender as? UIBarButtonItem{
            popover.barButtonItem = barButtonItem
        } else if let view = sender as? UIView{
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
        
        //NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentTimeToPeripheral", object: nil, userInfo: nil)
        popover.delegate = self
        self.present(documentationTableViewController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func currentMeasurementButton(sender: AnyObject) {
        
        currentMeasurementLabel.setTitle(NSLocalizedString("Get a measure", comment: ""), for: .normal)
        
        activeCurrentMeasurementFlag = true
        
        measureRequestedFlag = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendCurrentMeasurementToPeripheral"), object: nil)
        //NotificationCenter.defaultCenter.postNotificationName("sendCurrentMeasurementToPeripheral", object: nil, userInfo: nil)
        
    }
    
    @IBAction func autoSetGraph(sender: AnyObject) {
        //Change the x and y range.
        autoSetXYRangePressureGraphAndHeartRateGraph()
    }
    
    @IBAction func displayCalendar(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            
            let documentationTableViewController = storyboard.instantiateViewController(withIdentifier: "calendarViewControllerIPad")
            documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = documentationTableViewController.popoverPresentationController!
            documentationTableViewController.preferredContentSize = CGSize(width: 400, height: 350)
            
            popover.permittedArrowDirections = .any
            
            // Depending on the source, set the popover properties accordingly.
            if let barButtonItem = sender as? UIBarButtonItem{
                popover.barButtonItem = barButtonItem
            } else if let view = sender as? UIView{
                popover.sourceView = view
                popover.sourceRect = view.bounds
                
            }
            
            popover.delegate = self
            //NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentTimeToPeripheral", object: nil, userInfo: nil)
            
            self.present(documentationTableViewController, animated: true, completion: nil)
            
        case .iPhone:
            
            let documentationTableViewController = storyboard.instantiateViewController(withIdentifier: "calendarViewControllerIPhone")
            
            //NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentTimeToPeripheral", object: nil, userInfo: nil)
            navigationController?.pushViewController(documentationTableViewController, animated: true)
        }
    }
}
// MARK: - Extension
/**
    Extension popover presentation controller
 */
extension ViewControllerPatientVersion{
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        let barButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewController.dismissPopover(_:)))
        navController.topViewController!.navigationItem.rightBarButtonItem = barButtonItem
        return navController
    }
    /**
     Method called when the popover is dissmised programatically, after the user presses a button (iPhone)
     */
    func dismissPopover(sender:AnyObject){
        self.dismiss(animated: true, completion: nil)
        
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


