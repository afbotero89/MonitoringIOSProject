//
//  BluetoothManager.swift
//  BLEBackground
//
//  Created by camacholaverde on 4/13/16.
//  Copyright © 2016 gibicgroup. All rights reserved.
//

import UIKit
import CoreBluetooth
import AVFoundation

var contador = 0

enum CharacteristicsNames:String {
    case ReadFromBLEBeeKey = "ReadFromBLEBee"
    case SendToBLEBeeKey = "SendToBLEBee"
}

let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

//MARK: - ServiceDescriptor

struct ServiceDescriptor {
    //MARK: Properties
    
    ///
    let name:String
    
    ///
    let UUIDString:String
    
    ///
    let characteristics:[String:CBUUID]
    
    //MARK: Methods
    
    /**
    */
    func UUID()->CBUUID{
        return CBUUID(string: self.UUIDString);
    }
    
    /**
    */
    func characteristicsUUID() -> [CBUUID]{
        return [CBUUID](characteristics.values);
    }
    
    /**
     Returns the characteristic name, given the characteristic UUID
    */
    func characteristicNameForCharacteristicUUID(_ UUID:CBUUID)->String?{
        for (key, value) in characteristics{
            if value == UUID{
                return key
            }
        }
        return nil
    }
}

//MARK: - BluetoothManager

class BluetoothManager: NSObject{
    
    //MARK: Properties
    
    /// Device UUID. Given that we might have several devices with the same services, a match between the iOS device and the BLE device must be performed. This configuration must be done as a setup of the application, and store the UUID of the device in the NSUserDefaults.
    //let monitorDeviceUUIDString:String = "CFE88BC2-233E-B2D0-50C0-BB68FE22998A" //TODO: selection of device from user input. Store in NSUserDefaults.
    let monitorDeviceUUIDString:String = "BBB2DC14-92CD-4A3A-9B94-5641AFB1CA06"
    
    //let monitorDeviceUUIDString:String = "85F3CA4D-DC52-4598-9964-500BC17B1D86"
    
    //let monitorDeviceUUIDString:String = "BB8DC5A4-5AA4-6656-00FD-188D16815EB2"
    
    /// BLEBee service (v1.0.0) string UUID:
    //static let monitorserviceUUIDString:String = "EF080D8C-C3BE-41FF-BD3F-05A5F4795D7F"
    static let monitorserviceUUIDString:String = "EF080D8C-C3BE-41FF-BD3F-05A5F4795D7F"
    
    static let monitorServiceName:String = "Pressure Sensor 1"
    
    /// Read characteristic string UUID for the BLEBee Service
    //static let rxBLEBeeSeviceCharacteristicUUIDString:String = "A1E8F5B1-696B-4E4C-87C6-69DFE0B0093B"
    static let rxBLEBeeServiceCharacteristicUUIDString:String = "A1E8F5B1-696B-4E4C-87C6-69DFE0B0093B"
    /// Write characteristic string UUID for the BLEBee service
    static let txBLEBeeServiceCharacteristicUUIDString:String = "1494440E-9A58-4CC0-81E4-DDEA7F74F623"
    
    /// The CBCentral manager to handle the bluetooth devices and connections.
    var centralManager:CBCentralManager!
    
    /// The connected bluetooth peripheral
    var monitorPeripheral:CBPeripheral?
    
    /// Stores the writable characteristic of the Monitor peripheral device.
    var monitorWritableCharacteristic:CBCharacteristic?
    
    /// Hold an array of `ServiceDescriptor`s  in order to identify the services that will be serched
    let servicesDescriptors:[ServiceDescriptor] = BluetoothManager.loadServicesDescriptors();
    
    var timer:Timer?
    
    var tiempoEncendidoDispositivoRecibido = false
    
    ///
    var player: AVAudioPlayer?

    var contadorDatosAC = 0
    
    /// Request to remote data base sql: Type post to GIBIC server
    let uploadMeassuresToRemoteServer = GBCUploadMeassuresAndSignalsToRemoteServer()
    
    //MARK: Methods
    
    override init() {
        super.init()
        // Initialize the central manager.
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(BluetoothManager.sendMeasurementTime),
                                                         
                                                         name: NSNotification.Name(rawValue: "sendMeasurementTimeToPeripheral"),
                                                         
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(BluetoothManager.sendCurrentTime),
                                                         
                                                         name: NSNotification.Name(rawValue: "sendCurrentTimeToPeripheral"),
                                                         
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self,
                                                         
                                                         selector: #selector(BluetoothManager.activeCurrentMeasurement),
                                                         
                                                         name: NSNotification.Name(rawValue: "sendCurrentMeasurementToPeripheral"),
                                                         
                                                         object: nil)
        
        
        NotificationCenter.default.addObserver(self,
                                               
                                               selector: #selector(BluetoothManager.sendUserDocumentToMonitor),
                                               
                                               name: NSNotification.Name(rawValue: "sendUserDocumentToMonitorNotification"),
                                               
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               
                                               selector: #selector(BluetoothManager.cancelMeasurement),
                                               
                                               name: NSNotification.Name(rawValue: "cancelMeasurementNotification"),
                                               
                                               object: nil)
        
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(BluetoothManager.timerPrueba), userInfo: nil, repeats: true)
    }
    func playSound() {
        let url = Bundle.main.url(forResource: "60Hz", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    func stopSound(){
        
        player?.stop()
        
    }
    /**
     Loads the descriptors for the sought services.
    */
    static func loadServicesDescriptors()->[ServiceDescriptor]{
        
        // Initialize the characteristics dictionary for the BLEBee service
        let characteristics:[String:CBUUID] = [CharacteristicsNames.ReadFromBLEBeeKey.rawValue: CBUUID(string:self.rxBLEBeeServiceCharacteristicUUIDString), CharacteristicsNames.SendToBLEBeeKey.rawValue: CBUUID(string:txBLEBeeServiceCharacteristicUUIDString)]
        
        let bleBeeService = ServiceDescriptor(name: monitorServiceName, UUIDString: monitorserviceUUIDString, characteristics: characteristics)
        return [bleBeeService]
    }
    
    /**
     Given a service, return the corresponding service descriptor.
    */
    func serviceDescriptorForService(_ service:CBService)->ServiceDescriptor?{
        let descriptors  = self.servicesDescriptors.filter({$0.UUIDString == service.uuid.uuidString});
        if descriptors.count>0{
            return descriptors.last!
        }
        return nil
    }
    
    /**
     Reads the data received from peripheral. If a more sophisticated method is requiered, such as one including buffers of data, take a look at RedCodeMobile project.
    */
    func readDataFromPeripheral(_ data:Data){
        
        var counterVariablesToGraph = 0
        
        // Get data from buffer
        
        var buffer = [UInt8](repeating: 0, count: data.count)
        (data as NSData).getBytes(&buffer, length: data.count)
        var characterValue:Character?

        for i in buffer{
            
            characterValue = Character(UnicodeScalar(i))
            
            if characterValue == "k"{
                //playSound()
            }
            if characterValue == "A"{
                //stopSound()
            }
            
            VectorPhysiologicalVariables.currentMeasures.append(characterValue!)
            VectorPhysiologicalVariables.fullSignal.append(characterValue!)
            
        }
        
        var currentMeasurement = VectorPhysiologicalVariables.currentMeasures.components(separatedBy: ",")
        
        print(currentMeasurement)
        
        var error = false
        
        for i in currentMeasurement{

            if i == "e1"{
                typeError = 1
                error = true
                
                switch appVersion!{
                case .adminVersion:
                    if userSelectViewController == .realTimeViewController{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotification"), object: nil, userInfo: nil)
                    }else{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessage"), object: nil, userInfo: nil)
                    }
                case .patientVersion:
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotificationPatientVersion"), object: nil, userInfo: nil)
                }
                

            }else if i == "e2"{
                typeError = 2
                error = true
                
                switch appVersion!{
                case .adminVersion:
                    if userSelectViewController == .realTimeViewController{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotification"), object: nil, userInfo: nil)
                    }else{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessage"), object: nil, userInfo: nil)
                    }
                case .patientVersion:
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotificationPatientVersion"), object: nil, userInfo: nil)
                }
            }else if i == "e3"{
                typeError = 3
                error = true
                
                switch appVersion!{
                case .adminVersion:
                    if userSelectViewController == .realTimeViewController{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotification"), object: nil, userInfo: nil)
                    }else{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessage"), object: nil, userInfo: nil)
                    }
                case .patientVersion:
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotificationPatientVersion"), object: nil, userInfo: nil)
                }
            }else if i == "e4"{
                typeError = 4
                error = true
                switch appVersion!{
                case .adminVersion:
                    if userSelectViewController == .realTimeViewController{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotification"), object: nil, userInfo: nil)
                    }else{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessage"), object: nil, userInfo: nil)
                    }
                case .patientVersion:
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotificationPatientVersion"), object: nil, userInfo: nil)
                }
            }else if i == "e5"{
                typeError = 5
                error = true
                switch appVersion!{
                case .adminVersion:
                    if userSelectViewController == .realTimeViewController{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotification"), object: nil, userInfo: nil)
                    }else{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessage"), object: nil, userInfo: nil)
                    }
                case .patientVersion:
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotificationPatientVersion"), object: nil, userInfo: nil)
                }
                
            }else if i == "e6"{
                typeError = 6
                error = true
                switch appVersion!{
                case .adminVersion:
                    if userSelectViewController == .realTimeViewController{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotification"), object: nil, userInfo: nil)
                    }else{
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessage"), object: nil, userInfo: nil)
                    }
                case .patientVersion:
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotificationPatientVersion"), object: nil, userInfo: nil)
                }
            }
        }
        
        for i in currentMeasurement{
            
            var hour = i.components(separatedBy: "-")
            let measureHour = hour[0].components(separatedBy: ":")

            if measureHour.count == 3 && tiempoEncendidoDispositivoRecibido == false{
                
                tiempoEncendidoDispositivoRecibido = true
                hourOnDevice = hour[0]
                
            }
            if i.components(separatedBy: "-").count >= 2{
                activeCurrentHourFlag = false
            }
            
            if (i == "255" && measureRequestedFlag == true){
                measureRequestedFlag = false
                
                //NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentMeasurementToPeripheral", object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "startAnimation"), object: nil, userInfo: nil)
            }
            
            if (i == "255") && activeCurrentHourFlag == true{
                let date = Foundation.Date()
                let fmt = DateFormatter()
                fmt.dateFormat = "HH:mm:ss"
                configurationHour = fmt.string(from: date)
                
                let str:String = fmt.string(from: date) + "254,"
                
                let data = str.data(using: String.Encoding.utf8)

                monitorPeripheral!.writeValue(data!, for: self.monitorWritableCharacteristic!, type: .withResponse)
                
            }

            if (i == "255") && activeMeasurementTimeFlag == true{
                
                activeMeasurementTimeFlag = false
                
                let str:String?
                if UserSelectedConfiguration.userSelectMeasurementTime < 10{
                    //str = "00:01:00254,"
                    str = "00:0\(UserSelectedConfiguration.userSelectMeasurementTime!):00254,"
                }else{
                    str = "00:\(UserSelectedConfiguration.userSelectMeasurementTime!):00254,"
                }
                
                let data = str!.data(using: String.Encoding.utf8)
                activeCurrentHourFlag = false
                monitorPeripheral!.writeValue(data!, for: self.monitorWritableCharacteristic!, type: .withResponse)
                VectorPhysiologicalVariables.currentMeasures.removeAll()
            }
    
        }
        
        //Graphic data
        for j in currentMeasurement{
            
            if (j == "254") {
                
                    for i in 0...(currentMeasurement.count - 1){
                        
                        if currentMeasurement[i] == ";" {
                            stopSound()
                            // Systolic pressure
                            VectorPhysiologicalVariables.systolicPressure.append(Double(currentMeasurement[i+3])!)
                            
                            // Diastolic pressure
                            VectorPhysiologicalVariables.diastolicPressure.append(Double(currentMeasurement[i+4])!)
                            
                            // Mean pressure
                            VectorPhysiologicalVariables.averagePressure.append(Double(currentMeasurement[i+5])!)
                            
                            // Battery level
                            VectorPhysiologicalVariables.batteryLevel.append(Double(currentMeasurement[i+6])!)
                            
                            // Heart rate
                            VectorPhysiologicalVariables.heartRate.append(Double(currentMeasurement[i+7])!)
                            
                            // Measurement time
                            VectorPhysiologicalVariables.measuringTime.append(String(validatingUTF8: currentMeasurement[i+8])!)
                            
                            counterVariablesToGraph = 6
                        }

                    }
                
                
                if activeCurrentMeasurementFlag == true && error == false{
                    
                    activeCurrentMeasurementFlag = false
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "displayCurrentMeasurementPopoverNotification"), object: nil, userInfo: nil)
                }
                
                
                
                if counterVariablesToGraph == 6{
                    
                    let fullACSignal = VectorPhysiologicalVariables.fullSignal.components(separatedBy: ",")
                    
                    for i in fullACSignal{
                        
                        // Example component AC signal: A1234
                        
                        if i.components(separatedBy: "A").count == 2 && i.components(separatedBy: "A")[1] != ""{
                            VectorPhysiologicalVariables.ACSignal = VectorPhysiologicalVariables.ACSignal + "," + i.components(separatedBy: "A")[1]
                            
                        }
                        
                        // Example component AC signal: D1234
                        
                        if i.components(separatedBy: "D").count == 2 && i.components(separatedBy: "D")[1] != ""{
                            VectorPhysiologicalVariables.DCSignal = VectorPhysiologicalVariables.DCSignal + "," + i.components(separatedBy: "D")[1]
                            
                        }
                        
                    }
                    
                    VectorPhysiologicalVariables.ACSignal = VectorPhysiologicalVariables.ACSignal + VectorPhysiologicalVariables.DCSignal
                    
                    if Double(VectorPhysiologicalVariables.diastolicPressure.last!) > Double(VectorPhysiologicalVariables.averagePressure.last!){
                        let comodin = VectorPhysiologicalVariables.diastolicPressure.last
                        VectorPhysiologicalVariables.diastolicPressure[VectorPhysiologicalVariables.diastolicPressure.count - 1] = VectorPhysiologicalVariables.averagePressure[VectorPhysiologicalVariables.averagePressure.count - 1]
                        VectorPhysiologicalVariables.averagePressure[VectorPhysiologicalVariables.averagePressure.count - 1] = comodin!
                    }
                    
                    
                    if Double(VectorPhysiologicalVariables.systolicPressure.last!) > 100 && Double(VectorPhysiologicalVariables.heartRate.last!) > 40 && Double(VectorPhysiologicalVariables.heartRate.last!) < 150{
                        
                        VectorPhysiologicalVariables.vectorNumberOfSamples.append(Double(VectorPhysiologicalVariables.systolicPressure.count)/10.0)
                        
                        switch appVersion!{
                        case .adminVersion:
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "insertNewPlot"), object: nil, userInfo: nil)
                        case .patientVersion:
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "displayMeasurePatientViewController"), object: nil, userInfo: nil)
                        }

                    }else{
                        
                        
                        if(Double(VectorPhysiologicalVariables.systolicPressure.last!) <= 100){
                            
                            VectorPhysiologicalVariables.ACSignal = VectorPhysiologicalVariables.ACSignal + "-Diastolica baja"
                            
                        }
                        
                        if(Double(VectorPhysiologicalVariables.heartRate.last!) <= 40){
                            
                            VectorPhysiologicalVariables.ACSignal = VectorPhysiologicalVariables.ACSignal + "-Frecuencia cardiaca baja"
                            
                        }
                        
                        if(Double(VectorPhysiologicalVariables.heartRate.last!) > 150){
                            
                            VectorPhysiologicalVariables.ACSignal = VectorPhysiologicalVariables.ACSignal + "-Frecuencia cardiaca alta"
                            
                        }
                        
                        typeError = 7
                        
                        error = true
                        
                        if userSelectViewController == .realTimeViewController{
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessageMainViewNotification"), object: nil, userInfo: nil)
                        }else{
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "displayErrorMessage"), object: nil, userInfo: nil)
                        }
                        // todays date.
                        //let date = NSDate()
                        //uploadMeassuresToRemoteServer.uploadToServerDataBaseSQL(VectorPhysiologicalVariables.systolicPressure.last!, diastolicPressure: VectorPhysiologicalVariables.diastolicPressure.last!, mediumPressure: VectorPhysiologicalVariables.averagePressure.last!, heartRate: VectorPhysiologicalVariables.heartRate.last!, hour: (VectorPhysiologicalVariables.measuringTime.last?.componentsSeparatedByString(".")[0])!, ACSignal: VectorPhysiologicalVariables.ACSignal, DCSignal: "DCSignal", date: "\(date.day)/\(date.month)/\(date.year)")
                        
                        VectorPhysiologicalVariables.ACSignal = "AC"
                        
                        // The data is stored in database but is not plotted
                        VectorPhysiologicalVariables.systolicPressure.removeLast()
                        VectorPhysiologicalVariables.diastolicPressure.removeLast()
                        VectorPhysiologicalVariables.averagePressure.removeLast()
                        VectorPhysiologicalVariables.heartRate.removeLast()
                        VectorPhysiologicalVariables.measuringTime.removeLast()
                        VectorPhysiologicalVariables.batteryLevel.removeLast()
                    
                    }
                    VectorPhysiologicalVariables.currentMeasures.removeAll()
                    
                    let str = "255,"
                    
                    let data = str.data(using: String.Encoding.utf8)
                    
                    monitorPeripheral!.writeValue(data!, for: self.monitorWritableCharacteristic!, type: .withResponse)
                    
                    contadorDatosAC = 0
                
                }
                
                VectorPhysiologicalVariables.currentMeasures.removeAll()
                
            }
        }
    }
}

//MARK: - Bluetooth Manager Delegate Protocol conformance
extension BluetoothManager:CBCentralManagerDelegate{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central manager did update state")
        
        switch central.state{
        case .poweredOn:
            print("poweredOn")
            
            // As soon as the device is on, try stablish connection with previously connected devices, if any, or scan for
            
            let servicesUUIDs:[CBUUID] = self.servicesDescriptors.map({$0.UUID()})
            print("services of interest:\(servicesUUIDs)")
            let connectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: servicesUUIDs)
            
            if connectedPeripherals.count > 0{
                for peripheralDevice in connectedPeripherals{
                    self.centralManager.connect(peripheralDevice, options: nil);
                    
                }
            }
            else {
                print("Scanning for periopherals")
                //centralManager.scanForPeripheralsWithServices(servicesUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
                // Send notification that Bluetooth is disconnected and start scanning
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
        case .poweredOff:
            print("power off")
        case .resetting:
            print("reseting")
        default:
            print(central.state)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Attempt to connect to the discovered device.
        //centralManager.stopScan()
        
        //TODO:Verify if a more rigurous selection of the device is requiered. What if several devices have the same services?
        // It is important to have a reference to the peripheral that will be connected. Otherwise, the connection does not succeed (seems to be a bug?)
        print(peripheral.name)
        
        if peripheral.name != nil{
            PressureMonitors.monitorsNearby.insert(peripheral.name!)
            print("monitores cerca")
            print(PressureMonitors.monitorsNearby)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadMasterMonitorsNearby"), object: nil, userInfo: nil)
        }
        
        //if peripheral.identifier.UUIDString == self.monitorDeviceUUIDString{
        if peripheral.name == BluetoothManager.monitorServiceName{
            print("Will attempt to connect. The peripheral UUID \(peripheral.identifier)")
            self.monitorPeripheral = peripheral
            centralManager.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnNotificationKey: NSNumber(value: true as Bool)])
            // Send actual hour
            //sendCurrentTime()
            
        }
        print("Found peripheral \(peripheral)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("did connnect to peripheral named \(peripheral.name!)")
        
        // Set ourselfs as the delegate for the connected peripheral.
        self.monitorPeripheral?.delegate = self
        
        //Start looking for the services of interest
        print("Will start searching for services")
        self.monitorPeripheral?.discoverServices(self.servicesDescriptors.map({$0.UUID()}))
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        if error != nil{
            print("The connection to peripheral", peripheral.name, "failed with error:", error, separator: " ", terminator: "\n")
        }
        // Attempt a new connection to the device?
        if self.monitorPeripheral == peripheral{
            self.centralManager.connect(peripheral, options: nil);
        }
        
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // Send notification that Bluetooth is connected and all required characteristics are discovered
        self.sendBTServiceNotificationWithIsBluetoothConnected(false)
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
}


//MARK: - Bluetooth Peripheral Delegate
extension BluetoothManager:CBPeripheralDelegate{
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil{
            print("An error occured discovering services for peripheral")
        }
        else{
            print("Services discovered")
            //For the given service, look up for the characteristics of interest
            for service in (monitorPeripheral?.services)!{
                let serviceDescriptor = servicesDescriptors.filter({$0.UUID().uuidString == service.uuid.uuidString}).first
                monitorPeripheral?.discoverCharacteristics(serviceDescriptor?.characteristicsUUID(), for: service);
                print("Scanning characteristics for service \(serviceDescriptor?.name)");
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil{
            print("an error ocurred during characteristics discovering process for the service",
                  servicesDescriptors.filter({$0.UUID().uuidString == service.uuid.uuidString}).first,
                  "The error description:",
                  error, separator: " ", terminator: "\n")
            return
        }
        
        // Get notified of changes in the service characteristics
        for characteristic in service.characteristics!{
            // Print the and service for this characteristic
            if let serviceDescriptor = self.serviceDescriptorForService(service), let characteristicName = serviceDescriptor.characteristicNameForCharacteristicUUID(characteristic.uuid) {
                print("Found Characteristic", characteristicName , "of Service", serviceDescriptor.name, separator: " ", terminator: "\n")
                //if serviceDescriptor.name == BluetoothManager.monitorServiceName{
                    switch characteristic.uuid.uuidString {
                    case (serviceDescriptor.characteristics[CharacteristicsNames.ReadFromBLEBeeKey.rawValue]?.uuidString)!:
                        print("Found ReadFromBLEBee characteristic")
                        // If the characteristic is readable, get notify when it chages
                        if (characteristic.properties.rawValue & CBCharacteristicProperties.read.rawValue) != 0 {
                            monitorPeripheral?.setNotifyValue(true, for: characteristic)
                            print("Will get notifications in changes of characteristic", characteristicName, "with uuid", characteristic.uuid,"of service", serviceDescriptor.name, separator: " ", terminator: "\n")
                        }
                    case (serviceDescriptor.characteristics[CharacteristicsNames.SendToBLEBeeKey.rawValue]?.uuidString)!:
                        print("Found writable characteristic")
                        self.monitorWritableCharacteristic = characteristic
                        monitorPeripheral?.setNotifyValue(true, for: characteristic)
            
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "sendCurrentTimeToPeripheral"), object: nil, userInfo: nil)
                        
                    default:
                        break
                    }
                    // Send notification that Bluetooth is connected and all required characteristics are discovered
                    self.sendBTServiceNotificationWithIsBluetoothConnected(true)
                //}
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        readDataFromPeripheral(characteristic.value!)
        
    }
    func sendBTServiceNotificationWithIsBluetoothConnected(_ isBluetoothConnected: Bool) {
        let connectionDetails = ["isConnected": isBluetoothConnected]
        NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
    }
    
    /** 
     Current device time
    */
    func sendCurrentTime(){
        
        let str = "t254,"
        
        let data = str.data(using: String.Encoding.utf8)
        
        if monitorPeripheral != nil && self.monitorWritableCharacteristic != nil{
            
            activeCurrentHourFlag = true
            for _ in 0...2{
                monitorPeripheral!.writeValue(data!, for: self.monitorWritableCharacteristic!, type: .withResponse)
            }
            
        }else{
            print("no peticion de tiempo actual")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "displayDisconnectBluetoothAlertMessage"), object: nil, userInfo: nil)
        }
    }
    
    /**
     Measurement time set by the user
    */
    func sendMeasurementTime(){

        let str = "h254,"
        
        let data = str.data(using: String.Encoding.utf8)
    
        if monitorPeripheral != nil && self.monitorWritableCharacteristic != nil{
            
            activeMeasurementTimeFlag = true
            monitorPeripheral!.writeValue(data!, for: self.monitorWritableCharacteristic!, type: .withResponse)
        }else{
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "displayDisconnectBluetoothAlertMessage"), object: nil, userInfo: nil)
        }
    
    }
    
    
    /**
     Start new measure
    */
    func activeCurrentMeasurement(){
        
        let str = "i254,"
        
        let data = str.data(using: String.Encoding.utf8)
        if monitorPeripheral != nil && self.monitorWritableCharacteristic != nil{
        
            monitorPeripheral!.writeValue(data!, for: self.monitorWritableCharacteristic!, type: .withResponse)
        }else{
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "displayDisconnectBluetoothAlertMessage"), object: nil, userInfo: nil)
        }
    }
    
    func cancelMeasurement(){
        
        let data:String =  "s254,"
        
        let data1 = data.data(using: String.Encoding.utf8)
        
        monitorPeripheral!.writeValue(data1!, for: self.monitorWritableCharacteristic!, type: .withResponse)

        print("Cancela medida")
        
        /*
         let str = "c254,"
         
         let data = str.dataUsingEncoding(NSUTF8StringEncoding)
         
         if monitorPeripheral != nil{
         monitorPeripheral!.writeValue(data!, forCharacteristic: self.monitorWritableCharacteristic!, type: .WithResponse)
         }else{
         print("no cancela medida actual")
         NSNotificationCenter.defaultCenter().postNotificationName("displayDisconnectBluetoothAlertMessage", object: nil, userInfo: nil)
         }*/
        
    }
    
    /**
     Send user document to monitor
     */
    
    func sendUserDocumentToMonitor(){
        
        let userDocument = "002036935698d254,"
        
        //let str1:String =  "\(userDocument)d254,"
        
        let data1 = userDocument.data(using: String.Encoding.utf8)
        
        monitorPeripheral!.writeValue(data1!, for: self.monitorWritableCharacteristic!, type: .withResponse)
        
        print("envia documento")
        
    }

    func timerPrueba(){
        contador = contador + 1
        
        if contador == 10{
           /*
            contador = 0
            
            VectorPhysiologicalVariables.systolicPressure.append(120)
            VectorPhysiologicalVariables.diastolicPressure.append(80)
            VectorPhysiologicalVariables.averagePressure.append(100)
            VectorPhysiologicalVariables.heartRate.append(70)
            VectorPhysiologicalVariables.measuringTime.append("00:00:00")
            VectorPhysiologicalVariables.vectorNumberOfSamples.append(Double(VectorPhysiologicalVariables.systolicPressure.count)/10.0)
            */
            //NSNotificationCenter.defaultCenter().postNotificationName("displayMeasurePatientViewController", object: nil, userInfo: nil)
            
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "insertNewPlot"), object: nil, userInfo: nil)
 
            //NSNotificationCenter.defaultCenter().postNotificationName("displayCurrentMeasurementPopoverNotification", object: nil, userInfo: nil)
            //NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessage", object: nil, userInfo: nil)
        }
        
        if (activeMeasurementTimeFlag == true && self.monitorWritableCharacteristic != nil){
            let str = "h254,"
            let data = str.data(using: String.Encoding.utf8)
            monitorPeripheral!.writeValue(data!, for: self.monitorWritableCharacteristic!, type: .withResponse)
        }
        
        if (activeCurrentHourFlag == true && self.monitorWritableCharacteristic != nil){
            activeCurrentHourFlag = true
            let str = "t254,"
            let data = str.data(using: String.Encoding.utf8)
            monitorPeripheral!.writeValue(data!, for: self.monitorWritableCharacteristic!, type: .withResponse)
        }
    }
}
