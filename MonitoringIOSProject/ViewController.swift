//
//  ViewController.swift
//  MonitoringIOSProject
//
//  Created by FING156561 on 27/4/16.
//  Copyright © 2016 FING156561. All rights reserved.
//

import UIKit
import SystemConfiguration
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

var activeCurrentMeasurementFlag = false

var measureRequestedFlag = false

var activeCurrentHourFlag = false

var activeMeasurementTimeFlag = false

var measurementTimeConfirmed = false

var userSelectViewController : UserSelectViewPrincipalViewController?

/// There are 6 types of error: Disconnect hose, Circuit leaks, Incorrect pressure, Monitor measure canceled, heart rate not caculated, Incorrect pressure
var typeError:Int?

var configurationHour:String?

var hourOnDevice:String?


class ViewController: GBCPlotsViewController, UIPopoverPresentationControllerDelegate  {
    
    @IBOutlet weak var segmentControlMonitor: UISegmentedControl!
    
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
    
    /// Request to remote data base sql: Type post to GIBIC server
    let uploadMeassuresToRemoteServer = GBCUploadMeassuresAndSignalsToRemoteServer()
    
    /// Bluetooth manager
    var bluetoothManager:BluetoothManager!
    
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
    
    let queriesUserAdmin = GBCDataBaseQueriesUserAdmin()
    
    @IBOutlet weak var userConnectedToMonitor: UILabel!
    
    @IBOutlet weak var patientImage: UIImageView!
    
    @IBOutlet weak var userIDConnectedToMonitor: UILabel!
    
    @IBOutlet weak var telAndBirthDate: UILabel!
    
    @IBOutlet weak var systolicLabel: UILabel!
    
    @IBOutlet weak var systolicLabelLeft: UILabel!
    
    @IBOutlet weak var averageLabelRight: UILabel!
    
    @IBOutlet weak var averageLabelLeft: UILabel!
    
    @IBOutlet weak var diastolicLabelLeft: UILabel!

    @IBOutlet weak var diastolicLabelRight: UILabel!
    
    @IBOutlet weak var heartRateLabelRight: UILabel!
    
    @IBOutlet weak var heartRateLabelLeft: UILabel!
    
    @IBOutlet weak var sistolicIcon: UIImageView!
    
    @IBOutlet weak var diastolicImage: UIImageView!
    
    @IBOutlet weak var averageIcon: UIImageView!
    
    @IBOutlet weak var heartRateIcon: UIImageView!
    
    @IBOutlet weak var sistolicTitle: UILabel!
    
    @IBOutlet weak var diastolicTitle: UILabel!
    
    @IBOutlet weak var averageTitle: UILabel!
    
    @IBOutlet weak var heartRateTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title =  NSLocalizedString("Monitoring", comment: "")
        
        PressureMonitors.IDuserMonitorSelected = PressureMonitors.monitorID1
        PressureMonitors.nameUserMonitorSelected = PressureMonitors.monitorName1
        //statusConnectionLabel.text = NSLocalizedString("Scanning bluetooth", comment: "") + "..."
        
        currentMeasurementLabel.setTitle(NSLocalizedString("Get a measure", comment: ""), for: UIControlState())
        
        addAttributesToViewController()
        
        // Initialize the bluetooth manager.
        self.bluetoothManager = BluetoothManager()
        
        // Initialize notifications
        notifications()
        
        // Configure plots, identifiers, line style, point symbol, title plot
        configurePlots()
        
        setLegendGraph()
        
        addAttributesToContainerGraph()
        
        uploadMeassuresToRemoteServer.getDataFromDataBaseSQLDayMonthYear()
        
        addMaskLabelsPhysiologicalVariables()

        userConnectedToMonitor.text = "  Andrés Felipe Botero Ospina"
        userIDConnectedToMonitor.text = "  ID: 1036935699             Medellin, Antioquia"
        telAndBirthDate.text = "Tel: 3216437884               28 años"
        //patientImage.image = UIImage(named: "patient1")
        
        
        print("valores NSUserDefault!!!!!!!")
        var stringKeys:String?
        for (key, value) in defaultsDB.dictionaryRepresentation(){
            
            stringKeys = String(key)
            
            print(stringKeys! + "+" + String(describing: value))
            
        }
        /*
        defaultsDB.removeObject(forKey: "Pressure Monitor 1")
        defaultsDB.removeObject(forKey: "Pressure Monitor 3")
        defaultsDB.removeObject(forKey: "Pressure Monitor 1-27/6/2017")
        defaultsDB.removeObject(forKey: "medidas")
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        userSelectViewController = UserSelectViewPrincipalViewController.realTimeViewController
        
        //queriesUserAdmin.getInfoPatient_getRequest()
        
        setBatteryLevel()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        deviceRotated()
        
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
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(ViewController.disconnectBluetoothMessage),
                                                         
                                                         name: NSNotification.Name(rawValue: "displayDisconnectBluetoothAlertMessage"),
                                                         
                                                         object: nil)
        
        // Watch Bluetooth connection
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func addMaskLabelsPhysiologicalVariables(){
        // Corner radius labels only right or left //
        
        // Sistolic label, right
        let rectShapeSistolicLabelRight = CAShapeLayer()
        rectShapeSistolicLabelRight.bounds = systolicLabel.frame
        rectShapeSistolicLabelRight.position = systolicLabel.center
        rectShapeSistolicLabelRight.path = UIBezierPath(roundedRect: self.systolicLabel.bounds, byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        
        systolicLabel.layer.mask = rectShapeSistolicLabelRight
        
        // Sistolic label, left
        let rectShapeSistolicLabelLeft = CAShapeLayer()
        rectShapeSistolicLabelLeft.bounds = systolicLabelLeft.frame
        rectShapeSistolicLabelLeft.position = systolicLabelLeft.center
        rectShapeSistolicLabelLeft.path = UIBezierPath(roundedRect: self.systolicLabelLeft.bounds, byRoundingCorners: [.bottomLeft, .topLeft], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        
        systolicLabelLeft.layer.mask = rectShapeSistolicLabelLeft
        
        // Average label, right
        
        let rectShapeAverageLabelRight = CAShapeLayer()
        rectShapeAverageLabelRight.bounds = averageLabelRight.frame
        rectShapeAverageLabelRight.position = averageLabelRight.center
        rectShapeAverageLabelRight.path = UIBezierPath(roundedRect: self.averageLabelRight.bounds, byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        
        averageLabelRight.layer.mask = rectShapeAverageLabelRight
        
        // Average label, left
        let rectShapeAverageLabelLeft = CAShapeLayer()
        rectShapeAverageLabelLeft.bounds = averageLabelLeft.frame
        rectShapeAverageLabelLeft.position = averageLabelLeft.center
        rectShapeAverageLabelLeft.path = UIBezierPath(roundedRect: self.averageLabelLeft.bounds, byRoundingCorners: [.bottomLeft, .topLeft], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        
        averageLabelLeft.layer.mask = rectShapeAverageLabelLeft
        
        
        // Diastolic label, right
        
        let rectShapeDiastolicLabelRight = CAShapeLayer()
        rectShapeDiastolicLabelRight.bounds = diastolicLabelRight.frame
        rectShapeDiastolicLabelRight.position = diastolicLabelRight.center
        rectShapeDiastolicLabelRight.path = UIBezierPath(roundedRect: self.diastolicLabelRight.bounds, byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        
        diastolicLabelRight.layer.mask = rectShapeDiastolicLabelRight
        
        // Diatolic label, left
        let rectShapeDiastolicLabelLeft = CAShapeLayer()
        rectShapeDiastolicLabelLeft.bounds = diastolicLabelLeft.frame
        rectShapeDiastolicLabelLeft.position = diastolicLabelLeft.center
        rectShapeDiastolicLabelLeft.path = UIBezierPath(roundedRect: self.diastolicLabelLeft.bounds, byRoundingCorners: [.bottomLeft, .topLeft], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        
        diastolicLabelLeft.layer.mask = rectShapeDiastolicLabelLeft
        
        // Heart rate label, right
        
        let rectShapeHeartRateLabelRight = CAShapeLayer()
        rectShapeHeartRateLabelRight.bounds = heartRateLabelRight.frame
        rectShapeHeartRateLabelRight.position = heartRateLabelRight.center
        rectShapeHeartRateLabelRight.path = UIBezierPath(roundedRect: self.heartRateLabelRight.bounds, byRoundingCorners: [.bottomRight, .topRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        
        heartRateLabelRight.layer.mask = rectShapeHeartRateLabelRight
        
        // Diatolic label, left
        let rectShapeHeartRateLabelLeft = CAShapeLayer()
        rectShapeHeartRateLabelLeft.bounds = heartRateLabelLeft.frame
        rectShapeHeartRateLabelLeft.position = heartRateLabelLeft.center
        rectShapeHeartRateLabelLeft.path = UIBezierPath(roundedRect: self.heartRateLabelLeft.bounds, byRoundingCorners: [.bottomLeft, .topLeft], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        
        heartRateLabelLeft.layer.mask = rectShapeHeartRateLabelLeft
    }
    
    
    func configurePlots(){
        
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
        lowSymbol.fill = CPTFill(color: CPTColor.white())
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
        
        plotLineStyle.lineColor = CPTColor(componentRed: 128/255, green: 192/255, blue: 255/255, alpha: 1.0)
        systolicPressurePlot.dataLineStyle = plotLineStyle
        lowSymbol.fill = CPTFill(color: CPTColor(componentRed: 128/255, green: 192/255, blue: 255/255, alpha: 1.0))
        systolicPressurePlot.plotSymbol = lowSymbol
        
        plotLineStyle.lineColor = CPTColor(componentRed: 63/255, green: 159/255, blue: 239/255, alpha: 1.0)
        lowSymbol.fill = CPTFill(color: CPTColor(componentRed: 63/255, green: 159/255, blue: 239/255, alpha: 1.0))
        diastolicPressurePlot.dataLineStyle = plotLineStyle
        diastolicPressurePlot.plotSymbol = lowSymbol
        
        plotLineStyle.lineColor = CPTColor(componentRed: 162/255, green: 170/255, blue: 241/255, alpha: 1.0)
        lowSymbol.fill = CPTFill(color: CPTColor(componentRed: 162/255, green: 170/255, blue: 241/255, alpha: 1.0))
        averagePressurePlot.dataLineStyle = plotLineStyle
        averagePressurePlot.plotSymbol = lowSymbol
        
        plotLineStyle.lineColor = CPTColor(componentRed:240/255, green:76/255,blue:71/255,alpha:0.9)
        lowSymbol.fill = CPTFill(color: CPTColor(componentRed:240/255, green:76/255,blue:71/255,alpha:0.9))
        heartRatePressurePlot.dataLineStyle = plotLineStyle
        heartRatePressurePlot.plotSymbol = lowSymbol
        
        systolicPressurePlot.title = NSLocalizedString("Systolic pressure", comment: "")
        diastolicPressurePlot.title = NSLocalizedString("Diastolic pressure", comment: "")
        averagePressurePlot.title =  NSLocalizedString("Average pressure", comment: "")
        heartRatePressurePlot.title = NSLocalizedString("Heart Rate", comment: "")
        
        let attrs = [
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 16)!,
            
            ]
        
        pressuresGraph.title = NSLocalizedString("Pressure graphics", comment: "")
        pressuresGraph.titleTextStyle = CPTTextStyle(attributes: attrs)
        pressuresGraph.backgroundColor = UIColor(red: 11/255, green: 56/255, blue: 97/255, alpha: 0.3).cgColor
        pressuresGraph.plotAreaFrame?.backgroundColor = UIColor(red: 11/255, green: 56/255, blue: 97/255, alpha: 0.3).cgColor
        
        heartRateGraph.title = NSLocalizedString("Heart rate graphic", comment: "")
        heartRateGraph.titleTextStyle = CPTTextStyle(attributes: attrs)
        heartRateGraph.backgroundColor = UIColor(red: 11/255, green: 56/255, blue: 97/255, alpha: 0.3).cgColor
        heartRateGraph.plotAreaFrame?.backgroundColor = UIColor(red: 11/255, green: 56/255, blue: 97/255, alpha: 0.3).cgColor
        
        // Color gradient is added under the scatter plot
        
        let areaColor = CPTColor.white()
        let areaGradient = CPTGradient(beginning: areaColor.withAlphaComponent(0.2), ending: CPTColor.clear())
        areaGradient.angle = -90
        let areaGradientFill = CPTFill.init(gradient: areaGradient)
        //CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
        systolicPressurePlot.areaFill = areaGradientFill
        systolicPressurePlot.areaBaseValue = 0
        
        heartRatePressurePlot.areaFill = areaGradientFill
        heartRatePressurePlot.areaBaseValue = 0
        
        pressuresGraph.add(systolicPressurePlot)
        pressuresGraph.add(diastolicPressurePlot)
        pressuresGraph.add(averagePressurePlot)
        heartRateGraph.add(heartRatePressurePlot)
        
        let plotSpacePressureGraph = pressuresGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpacePressureGraph.yRange = CPTPlotRange(location: 0, length: 200)
        
        let plotSpaceHeartRateGraph = heartRateGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpaceHeartRateGraph.yRange = CPTPlotRange(location: 0, length: 200)
        
    
    }
    
    
    func addAttributesToContainerGraph(){

        // attributes pressure container
        pressureContainerGraph.layer.borderWidth = 0
        pressureContainerGraph.layer.borderColor = UIColor.white.cgColor
        //pressureContainerGraph.layer.cornerRadius = 20
        pressureContainerGraph.hostedGraph = pressuresGraph
        
        
        // attributes heart rate container graph
        heartRateContainerGraph.layer.borderWidth = 0
        heartRateContainerGraph.layer.borderColor = UIColor.white.cgColor
        //heartRateContainerGraph.layer.cornerRadius = 20
        heartRateContainerGraph.hostedGraph = heartRateGraph
        
        
        // Insert subviews
        view.addSubview(pressureContainerGraph)
        view.addSubview(heartRateContainerGraph)
    }
    
    func addAttributesToViewController(){
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 38/255, green: 43/255, blue: 64/255, alpha: 1.0)
        
        currentMeasurementLabel.clipsToBounds = true
        
        currentMeasurementLabel.layer.cornerRadius = 10

    }
    
    func setLegendGraph(){
        // Set legend pressure graph
        let theLegend=CPTLegend(graph: pressuresGraph)
        let theLegendHeartRate=CPTLegend(graph: heartRateGraph)
        
        let legendLineStyle = CPTMutableLineStyle()
        //theLegend.fill = CPTFill(color: CPTColor.white())
        legendLineStyle.lineWidth = 0
        theLegend.borderLineStyle = legendLineStyle
        theLegend.numberOfColumns = 1
        theLegend.numberOfRows = 4
        theLegendHeartRate.fill = CPTFill(color: CPTColor(componentRed: 11/255, green: 56/255, blue: 97/255, alpha: 0.3))
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
            heartRateGraph.legendDisplacement = CGPoint(x: 430.0, y: -25.0)
            attrsLegend = [
                NSForegroundColorAttributeName : UIColor.white,
                NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 16)!,
                
            ]
        case .iPhone:
            theLegend.swatchSize = CGSize(width: 20.0, height: 7.0)
            theLegendHeartRate.swatchSize = CGSize(width: 50.0, height: 30.0)
            attrsLegend = [
                NSForegroundColorAttributeName : UIColor.white,
                NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 12)!,
                
            ]
        }

        theLegend.textStyle = CPTTextStyle(attributes: attrsLegend)
        
        pressuresGraph.legend = theLegend
        pressuresGraph.legend?.backgroundColor = UIColor(red: 11/255, green:  56/255, blue:  97/255, alpha: 0.3).cgColor
        //pressuresGraph.legend?.fill = CPTFill(color: CPTColor(componentRed: 11/255, green: 56/255, blue: 97/255, alpha: 0.3))
        pressuresGraph.legendAnchor = CPTRectAnchor.topLeft
        pressureContainerGraph.isUserInteractionEnabled = true
        
        theLegendHeartRate.textStyle = CPTTextStyle(attributes: attrsLegend)
        
        heartRateGraph.legend = theLegendHeartRate
        heartRateGraph.legendAnchor = CPTRectAnchor.topLeft
        heartRateContainerGraph.isUserInteractionEnabled = true
    }
    
    func insertPoint(){
        
        let date = Foundation.Date()
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm:ss"
        let measuringTimeDevice = fmt.string(from: date)
        
        setBatteryLevel()
        
        if VectorPhysiologicalVariables.systolicPressure.count > 0 && VectorPhysiologicalVariables.diastolicPressure.count > 0 && VectorPhysiologicalVariables.averagePressure.count > 0 && VectorPhysiologicalVariables.heartRate.count > 0{
            
            let style = CPTMutableTextStyle()
            style.color = CPTColor.white()
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
                
                    reloadGraphData = false
                    
                }else{
                    
                    reloadGraphData = false
                
                }
            }
            }else{
            
                if configureOrNotConfigureHour.count > 1{
                    
                    if configureOrNotConfigureHour[1] == "n" {
                    
                        reloadGraphData = false
                        
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
                
                if Int(hour!)! < 10 && hour!.characters.count == 1{
                    hour = "0" + hour!
                }
                if Int(minutes!)! < 10 && minutes!.characters.count == 1{
                    minutes = "0" + minutes!
                }
                if Int(seconds!)! < 10 && seconds!.characters.count == 1{
                    seconds = "0" + seconds!
                }
                
                // xAxis pressure graph
                let axisSet = pressuresGraph.axisSet as! CPTXYAxisSet
                let xAxis = axisSet.xAxis!
                let xLabel:CPTAxisLabel?
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    xLabel = CPTAxisLabel.init(text: measuringTimeDevice, textStyle: style)
                case .iPhone:
                    
                    xLabel = CPTAxisLabel.init(text: measuringTimeDevice, textStyle: style)
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
                let xLabelHeartRate = CPTAxisLabel.init(text: measuringTimeDevice, textStyle: style)
                switch UserSelectedConfiguration.typeOfDevice!{
                case .iPad:
                    print("ipad")
                case .iPhone:
                    xLabelHeartRate.rotation = 3.14/3.0;
                }
                xLabelHeartRate.tickLocation = NSNumber(value: Double(VectorPhysiologicalVariables.measuringTime.count)/10.0)
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
                
                //defaults.removeObject(forKey: PressureMonitors.nameUserMonitorSelected!)
                
                let medidas = String(VectorPhysiologicalVariables.systolicPressure.last!) + "," + String(VectorPhysiologicalVariables.diastolicPressure.last!) + "," + String(VectorPhysiologicalVariables.averagePressure.last!) + "," + String(VectorPhysiologicalVariables.heartRate.last!) + "," + String((VectorPhysiologicalVariables.measuringTime.last?.components(separatedBy: ".")[0])!) + ";"
                
                let date = Foundation.Date()
                
                let date1 = "\(date.day)/\(date.month)/\(date.year)"
                
                let keyDB = PressureMonitors.nameUserMonitorSelected! + "_" + date1
                
                if(defaultsDB.value(forKey: keyDB) == nil){
                    
                    defaultsDB.setValue(medidas, forKey: keyDB)
                    
                }else{
                
                    let beforeValues = defaultsDB.value(forKey: keyDB)
                
                    defaultsDB.setValue(String(describing: beforeValues!) + medidas, forKey: keyDB)
                
                }
                
                var memoryDevice = ""
                var appendData = ""
                
                if defaultsDB.value(forKey: "medidas") != nil{
                    
                    memoryDevice = String(describing: defaultsDB.value(forKey: "medidas")!)
                    
                    appendData = memoryDevice + "," + (String(VectorPhysiologicalVariables.systolicPressure.last!) + String(VectorPhysiologicalVariables.diastolicPressure.last!) + String(VectorPhysiologicalVariables.averagePressure.last!) + String(VectorPhysiologicalVariables.heartRate.last!) + String(measuringTimeDevice)) + ","
                }else{
                    appendData = (String(VectorPhysiologicalVariables.systolicPressure.last!) + String(VectorPhysiologicalVariables.diastolicPressure.last!) + String(VectorPhysiologicalVariables.averagePressure.last!) + String(VectorPhysiologicalVariables.heartRate.last!) + String(measuringTimeDevice)) + ","
                }
                
                appendData = "datos"
                
                defaultsDB.setValue(appendData, forKey: "medidas")
                
                memoryDevice = String(describing: defaultsDB.value(forKey: "medidas")!)
                
                print(memoryDevice)
                
                systolicLabel.text = String(VectorPhysiologicalVariables.systolicPressure.last!) + " mmHg"
                averageLabelRight.text = String(VectorPhysiologicalVariables.averagePressure.last!) + " mmHg"
                diastolicLabelRight.text = String(VectorPhysiologicalVariables.diastolicPressure.last!) + " mmHg"
                heartRateLabelRight.text = String(VectorPhysiologicalVariables.heartRate.last!) + " BPM"
                
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
                
                systolicLabel.text = String(pressureSystolicLastElement) + " mmHg"
                averageLabelRight.text = String(averagePressureLastElement) + " mmHg"
                diastolicLabelRight.text = String(pressureDiastolicLastElement) + " mmHg"
                heartRateLabelRight.text = String(heartRateLastElement) + " BPM"
                
                
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
                    
                if Int(hour)<10 && hour.characters.count == 1{
                    hour = "0" + hour
                }
                
                if Int(seconds)<10 && seconds.characters.count == 1{
                    seconds = "0" + seconds
                }
                    
                if Int(minute)<10 && minute.characters.count == 1{
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
                        xLabel = CPTAxisLabel.init(text: measuringTimeDevice, textStyle: style)
                    case .iPhone:
                        xLabel = CPTAxisLabel.init(text: measuringTimeDevice, textStyle: style)
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
                    xLabelHeartRate = CPTAxisLabel.init(text: measuringTimeDevice, textStyle: style)
                case .iPhone:
                    
                    xLabelHeartRate = CPTAxisLabel.init(text: measuringTimeDevice, textStyle: style)
                    xLabelHeartRate?.rotation = 3.14/3.0;
                    
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
        
            //Change the x and y range.
        
            autoSetXYRangePressureGraphAndHeartRateGraph()
        
            if defaultsDB.array(forKey: "VectorToUpLoadServer")?.count > 0{
                // Check internet connection to upload lost data
                //var reachability = Reachability()
                let conexion = isInternetAvailable()
                print(conexion)
                if conexion == true{
                    for i in defaultsDB.array(forKey: "VectorToUpLoadServer")!{
                        print(i)
                        //upLoadLostDataToServer(i as! String)
                        //uploadMeassuresToRemoteServer.upLoadLostDataToServer(i as! String)
                        
                    }
                }
            }
        }
    }
    
    
    func displayGeneralInformationPopPup(_ location:CGPoint, plotIdentifier: NSInteger, indexPoint:Int){
        
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
    
    func connectionChanged(_ notification: Notification) {
        
        // Connection status changed. Indicate on GUI.
        let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
        
        DispatchQueue.main.async(execute: {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    self.imageStatusConnection.image = UIImage(named: "Bluetooth_Connected")
                    DeviceVariables.bluetoothConnected = true
                    
                
                } else {
                    self.imageStatusConnection.image = UIImage(named: "Bluetooth_Disconnected")
                    DeviceVariables.bluetoothConnected = false
                  
                }
            }
        });
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
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 50, y: 340, width: 650, height: 300)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 50, y: 650, width: 650, height: 300)
                
            case .iPhone:
                systolicLabel.isHidden = true
                
                systolicLabelLeft.isHidden = true
                
                averageLabelRight.isHidden = true
                
                averageLabelLeft.isHidden = true
                
                diastolicLabelLeft.isHidden = true
                
                diastolicLabelRight.isHidden = true
                
                heartRateLabelRight.isHidden = true
                
                heartRateLabelLeft.isHidden = true
                
                sistolicIcon.isHidden = true
                
                diastolicImage.isHidden = true
                
                averageIcon.isHidden = true
                
                heartRateIcon.isHidden = true
                
                sistolicTitle.isHidden = true
                
                diastolicTitle.isHidden = true
                
                averageTitle.isHidden = true
                
                heartRateTitle.isHidden = true
                
                pressuresGraph.legendDisplacement = CGPoint(x: CGFloat(graphicsEnabledWidth!/1.8), y: -20.0)
                
                heartRateGraph.legendDisplacement = CGPoint(x: CGFloat(graphicsEnabledWidth!/1.8), y: -20.0)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 0, y: 250, width: Int(graphicsEnabledWidth!), height: Int(graphicsEnabledHeight!/3))
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 0, y: Int(graphicsEnabledHeight!), width: Int(graphicsEnabledWidth!), height: Int(graphicsEnabledHeight!/3))
            }
            
        }else{
            
            // Landscape
            switch UserSelectedConfiguration.typeOfDevice!{
            case .iPad:
                constraintSeparation.constant = 200
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 230, y: 330, width: 650, height: 180)
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: 230, y: 535, width: 650, height: 180)

            case .iPhone:
                
                systolicLabel.isHidden = true
                
                systolicLabelLeft.isHidden = true
                
                averageLabelRight.isHidden = true
                
                averageLabelLeft.isHidden = true
                
                diastolicLabelLeft.isHidden = true
                
                diastolicLabelRight.isHidden = true
                
                heartRateLabelRight.isHidden = true
                
                heartRateLabelLeft.isHidden = true
                
                sistolicIcon.isHidden = true
                
                diastolicImage.isHidden = true
                
                averageIcon.isHidden = true
                
                heartRateIcon.isHidden = true
                
                sistolicTitle.isHidden = true
                
                diastolicTitle.isHidden = true
                
                averageTitle.isHidden = true
                
                heartRateTitle.isHidden = true
                
                pressuresGraph.legendDisplacement = CGPoint(x: CGFloat(graphicsEnabledWidth!/4), y: -20.0)
                
                heartRateGraph.legendDisplacement = CGPoint(x: CGFloat(graphicsEnabledWidth!/4), y: -20.0)
                
                // Attributes pressure container
                pressureContainerGraph.frame = CGRect(x: 20, y: 80, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
                
                // Attributes heart rate container graph
                heartRateContainerGraph.frame = CGRect(x: Int(graphicsEnabledWidth!/2) + 10, y: 80, width: Int(graphicsEnabledWidth!/2) - 20, height: Int(graphicsEnabledHeight!))
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
    func scatterPlot(_ plot: CPTScatterPlot, plotSymbolWasSelectedAtRecordIndex index: Int, withEvent event: UIEvent) {
        
        let touch = event.allTouches?.first?.preciseLocation(in: self.view)
        displayGeneralInformationPopPup(touch!, plotIdentifier: plot.identifier as! NSInteger, indexPoint: index)
        
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
            popoverContent.preferredContentSize = CGSize(width: 500,height: 500)
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRect(x: self.view.frame.width/2,y: self.view.frame.height/6,width: 0,height: 0)
            
            self.present(nav, animated: true, completion: nil)
            
        case .iPhone:
            let popoverContentIPhone = (self.storyboard?.instantiateViewController(withIdentifier: "animationViewController"))! as! CBCAnimationViewController

            navigationController?.pushViewController(popoverContentIPhone, animated: true)
        }
    }
    
    func displayErrorMessageMainView(){
        activeCurrentMeasurementFlag = false
        let alertController:UIAlertController?

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
            alertController = UIAlertController(title: "", message: "Default principal view", preferredStyle:UIAlertControllerStyle.alert)
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
    
    /**
     Display monitor battery level
    */
    func setBatteryLevel(){
        //batteryLevelTitleLabel.text = NSLocalizedString("Battery Level", comment: "")
        
        if VectorPhysiologicalVariables.batteryLevel.last != nil{
            batteryLevelTextLabel.text = String(VectorPhysiologicalVariables.batteryLevel.last!) + " %"
        }else{
            batteryLevelTextLabel.text = "-----"
        }
        batteryLevelTextLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        
        // Battery level 0%
        if VectorPhysiologicalVariables.batteryLevel.last == 0 {
            batteryLevelImageView.image = UIImage(named: "BatteryLevel0")
            
            // Battery level 1%-10%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 0 && VectorPhysiologicalVariables.batteryLevel.last <= 10){
            batteryLevelImageView.image = UIImage(named: "BatteryLevel1")
            
            // Battery level 11%-20%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 10 && VectorPhysiologicalVariables.batteryLevel.last <= 20){
            batteryLevelImageView.image = UIImage(named: "BatteryLevel2")
            
            // Battery level 21%-30%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 20 && VectorPhysiologicalVariables.batteryLevel.last <= 30){
            batteryLevelImageView.image = UIImage(named: "BatteryLevel3")
            
            // Battery level 31%-40%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 30 && VectorPhysiologicalVariables.batteryLevel.last <= 40){
            batteryLevelImageView.image = UIImage(named: "BatteryLevel4")
            
            // Battery level 41%-50%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 40 && VectorPhysiologicalVariables.batteryLevel.last <= 50){
            batteryLevelImageView.image = UIImage(named: "BatteryLevel5")
            
            // Battery level 51%-60%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 50 && VectorPhysiologicalVariables.batteryLevel.last <= 60){
            batteryLevelImageView.image = UIImage(named: "BatteryLevel6")
            
            // Battery level 61%-70%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 60 && VectorPhysiologicalVariables.batteryLevel.last <= 70){
            batteryLevelImageView.image = UIImage(named: "BatteryLevel7")
            
            // Battery level 71%-80%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 70 && VectorPhysiologicalVariables.batteryLevel.last <= 80){
            batteryLevelImageView.image = UIImage(named: "BatteryLevel8")
            
            // Battery level 81%-90%
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 80 && VectorPhysiologicalVariables.batteryLevel.last <= 90){
            batteryLevelImageView.image = UIImage(named: "BatteryLevel9")
            
            // Battery level 91%-100
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 90 && VectorPhysiologicalVariables.batteryLevel.last <= 100){
            batteryLevelImageView.image = UIImage(named: "BatteryLevel10")
            
            // Battery level default
        }else if(VectorPhysiologicalVariables.batteryLevel.last > 100){
            batteryLevelImageView.image = UIImage(named: "BatteryLevel10")
            batteryLevelTextLabel.text = "100 %"
        }else{
            batteryLevelImageView.image = UIImage(named: "BatteryLevel10")
        }
    
    }

    func disconnectBluetoothMessage(){

    }

    // MARK: - Buttons
    
    @IBAction func userManagerButton(_ sender: AnyObject) {
        
        let storyBoardUserManager = UIStoryboard(name: "UserConfiguration", bundle: nil)
        let userManagerSplitViewController = storyBoardUserManager.instantiateViewController(withIdentifier: "splitRootViewController")
        //navigationController?.pushViewController(userManagerSplitViewController, animated: true)
        self.present(userManagerSplitViewController, animated: true, completion: nil)
    }
    
    @IBAction func configurationButton(_ sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let documentationTableViewController = storyboard.instantiateViewController(withIdentifier: "sliderConfiguration")
        documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = documentationTableViewController.popoverPresentationController!
        documentationTableViewController.preferredContentSize = CGSize(width: 380,height: 450)
        
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

    @IBAction func generalInformation(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let documentationTableViewController = storyboard.instantiateViewController(withIdentifier: "generalInformation")
        documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = documentationTableViewController.popoverPresentationController!
        documentationTableViewController.preferredContentSize = CGSize(width: 350,height: 150)
        
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
    
    @IBAction func currentMeasurementButton(_ sender: AnyObject) {
        
        if DeviceVariables.bluetoothConnected == true{
            
            currentMeasurementLabel.setTitle(NSLocalizedString("Get a measure", comment: ""), for: UIControlState())
        
            activeCurrentMeasurementFlag = true
        
            measureRequestedFlag = true
        
            NotificationCenter.default.post(name: Notification.Name(rawValue: "sendCurrentMeasurementToPeripheral"), object: nil, userInfo: nil)
        }else{
            
            let alert = UIAlertController(title: NSLocalizedString("Connection fail", comment: ""), message: NSLocalizedString("Check your Bluetooth connection", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default) { _ in })
            self.present(alert, animated: true){}
        
        }
    }
    
    @IBAction func autoSetGraph(_ sender: AnyObject) {
        //Change the x and y range.
        autoSetXYRangePressureGraphAndHeartRateGraph()
    }
    
    @IBAction func displayCalendar(_ sender: AnyObject) {
        
        //NotificationCenter.default.post(name: Notification.Name(rawValue: "sendUserDocumentToMonitorNotification"), object: nil, userInfo: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch UserSelectedConfiguration.typeOfDevice!{
        case .iPad:
            
            let documentationTableViewController = storyboard.instantiateViewController(withIdentifier: "calendarViewControllerIPad")
            documentationTableViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = documentationTableViewController.popoverPresentationController!
            documentationTableViewController.preferredContentSize = CGSize(width: 400,height: 350)
            
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
    
    @IBAction func cancelMeasurement(_ sender: AnyObject) {
        if DeviceVariables.bluetoothConnected == true{
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "cancelMeasurementNotification"), object: nil, userInfo: nil)
            
        }else{
            
            let alert = UIAlertController(title: NSLocalizedString("Connection fail", comment: ""), message: NSLocalizedString("Check your Bluetooth connection", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default) { _ in })
            self.present(alert, animated: true){}
            
        }
    }
    
    @IBAction func sendDocument(_ sender: AnyObject) {
        if DeviceVariables.bluetoothConnected == true{
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "sendUserDocumentToMonitorNotification"), object: nil, userInfo: nil)
            
        }else{
            
            let alert = UIAlertController(title: NSLocalizedString("Connection fail", comment: ""), message: NSLocalizedString("Check your Bluetooth connection", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default) { _ in })
            self.present(alert, animated: true){}
            
        }
    }
    @IBAction func cleanMemory(_ sender: Any) {
        
        VectorPhysiologicalVariables.systolicPressure.removeAll()
        VectorPhysiologicalVariables.diastolicPressure.removeAll()
        VectorPhysiologicalVariables.averagePressure.removeAll()
        VectorPhysiologicalVariables.heartRate.removeAll()
        VectorPhysiologicalVariables.measuringTime.removeAll()
        VectorPhysiologicalVariables.vectorNumberOfSamples.removeAll()
        VectorPhysiologicalVariables.measuringTime.removeAll()
        
        //labelsHeartRate.removeAll()
        
        defaultsDB.removeObject(forKey: "medidas")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "cancelPheriperalConnectionNotification"), object: nil, userInfo: nil)
        
        if(PressureMonitors.IDuserMonitorSelected == PressureMonitors.monitorID1){
            PressureMonitors.IDuserMonitorSelected = PressureMonitors.monitorID3
            PressureMonitors.nameUserMonitorSelected = PressureMonitors.monitorName3
        }else{
            PressureMonitors.IDuserMonitorSelected = PressureMonitors.monitorID1
            PressureMonitors.nameUserMonitorSelected = PressureMonitors.monitorName1
        }
        
        pressuresGraph.reloadData()
        heartRateGraph.reloadData()
        labelsHeartRate.removeAll()
        labels.removeAll()
        
    }
    
    @IBAction func segmentControlMonitorSelected(_ sender: Any) {
        
        VectorPhysiologicalVariables.systolicPressure.removeAll()
        VectorPhysiologicalVariables.diastolicPressure.removeAll()
        VectorPhysiologicalVariables.averagePressure.removeAll()
        VectorPhysiologicalVariables.heartRate.removeAll()
        VectorPhysiologicalVariables.measuringTime.removeAll()
        VectorPhysiologicalVariables.vectorNumberOfSamples.removeAll()
        VectorPhysiologicalVariables.measuringTime.removeAll()
        
        defaultsDB.removeObject(forKey: "medidas")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "cancelPheriperalConnectionNotification"), object: nil, userInfo: nil)
        
        var itemSelected = (sender as AnyObject).selectedSegmentIndex
        
        if itemSelected == 0{
            PressureMonitors.IDuserMonitorSelected = PressureMonitors.monitorID1
            PressureMonitors.nameUserMonitorSelected = PressureMonitors.monitorName1
            userConnectedToMonitor.text = "  Andrés Felipe Botero Ospina"
            userIDConnectedToMonitor.text = "  ID: 1036935699             Rionegro, Antioquia"
            telAndBirthDate.text = "Tel: 3216437884               28 años"
            //patientImage.image = UIImage(named: "patient1")
            
        }else if(itemSelected==1){
            PressureMonitors.IDuserMonitorSelected = PressureMonitors.monitorID3
            PressureMonitors.nameUserMonitorSelected = PressureMonitors.monitorName3

            
            userConnectedToMonitor.text = "  Andrés Felipe Castaño Franco"
            userIDConnectedToMonitor.text = "  ID: 1036935699             Medellin, Antioquia"
            telAndBirthDate.text = "Tel: 3173725221               33 años"
            //patientImage.image = UIImage(named: "patient2")
            
        }
        self.bluetoothManager.centralManager.scanForPeripherals(withServices: nil, options: nil)
        pressuresGraph.reloadData()
        heartRateGraph.reloadData()
        labelsHeartRate.removeAll()
        labels.removeAll()
    }
}
// MARK: - Extension
/**
    Extension popover presentation controller
 */
extension ViewController{
    @objc(adaptivePresentationStyleForPresentationController:) func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        let barButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.done, target: self, action: #selector(ViewController.dismissPopover(_:)))
        navController.topViewController!.navigationItem.rightBarButtonItem = barButtonItem
        return navController
    }
    /**
     Method called when the popover is dissmised programatically, after the user presses a button (iPhone)
     */
    func dismissPopover(_ sender:AnyObject){
        self.dismiss(animated: true, completion: nil)
        
        print("dissmiss iPhone")
    }
    
    /**
     Method called after the popover is dissmissed by means of user interactions only (iPad).
     */
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        print("dissmiss iPad")
        
    }
    
    /**
     Check internet connection
    */
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
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


