//
//  BluetoothManager.swift
//  BLEBackground
//
//  Created by camacholaverde on 4/13/16.
//  Copyright © 2016 gibicgroup. All rights reserved.
//

import UIKit
import CoreBluetooth

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
    func characteristicNameForCharacteristicUUID(UUID:CBUUID)->String?{
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
    //let monitorDeviceUUIDString:String = "1DBE05DE-619B-896D-25DC-36B7E942BC90"
    
    let monitorDeviceUUIDString:String = "EA8A63C5-4B86-CDE2-200C-8EE9918FD2AA"
    
    //let monitorDeviceUUIDString:String = "BB8DC5A4-5AA4-6656-00FD-188D16815EB2"
    
    /// BLEBee service (v1.0.0) string UUID:
    //static let monitorserviceUUIDString:String = "EF080D8C-C3BE-41FF-BD3F-05A5F4795D7F"
    static let monitorserviceUUIDString:String = "EF080D8C-C3BE-41FF-BD3F-05A5F4795D7F"
    
    static let monitorServiceName:String = "Pressure Monitor"
    
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
    
    var timer:NSTimer?
    
    var tiempoEncendidoDispositivoRecibido = false
    //MARK: Methods
    
    override init() {
        super.init()
        // Initialize the central manager.
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(BluetoothManager.sendMeasurementTime),
                                                         
                                                         name: "sendMeasurementTimeToPeripheral",
                                                         
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(BluetoothManager.sendCurrentTime),
                                                         
                                                         name: "sendCurrentTimeToPeripheral",
                                                         
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(BluetoothManager.activeCurrentMeasurement),
                                                         
                                                         name: "sendCurrentMeasurementToPeripheral",
                                                         
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         
                                                         selector: #selector(BluetoothManager.cancelCurrentMeasurement),
                                                         
                                                         name: "cancelCurrentMeasurementToPeripheral",
                                                         
                                                         object: nil)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(BluetoothManager.timerPrueba), userInfo: nil, repeats: true)
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
    func serviceDescriptorForService(service:CBService)->ServiceDescriptor?{
        let descriptors  = self.servicesDescriptors.filter({$0.UUIDString == service.UUID.UUIDString});
        if descriptors.count>0{
            return descriptors.last!
        }
        return nil
    }
    
    /**
     Reads the data received from peripheral. If a more sophisticated method is requiered, such as one including buffers of data, take a look at RedCodeMobile project.
    */
    func readDataFromPeripheral(data:NSData){
        
        // Get data from buffer
        var buffer = [UInt8](count:data.length, repeatedValue:0)
        data.getBytes(&buffer, length: data.length)
        var characterValue:Character?
        
        for i in buffer{
            characterValue = Character(UnicodeScalar(i))
            VectorPhysiologicalVariables.currentMeasures.append(characterValue!)
        }
        
        var currentMeasurement = VectorPhysiologicalVariables.currentMeasures.componentsSeparatedByString(",")
        
        print(currentMeasurement)
        
        var error = false
        
        for i in currentMeasurement{
            if i == "e1"{
                typeError = 1
                error = true
                if userSelectViewController == .realTimeViewController{
                    NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessageMainViewNotification", object: nil, userInfo: nil)
                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessage", object: nil, userInfo: nil)
                }
            }else if i == "e2"{
                typeError = 2
                error = true
                if userSelectViewController == .realTimeViewController{
                    NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessageMainViewNotification", object: nil, userInfo: nil)
                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessage", object: nil, userInfo: nil)
                }
            }else if i == "e3"{
                typeError = 3
                error = true
                if userSelectViewController == .realTimeViewController{
                    NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessageMainViewNotification", object: nil, userInfo: nil)
                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessage", object: nil, userInfo: nil)
                }
            }else if i == "e4"{
                typeError = 4
                error = true
                if userSelectViewController == .realTimeViewController{
                    NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessageMainViewNotification", object: nil, userInfo: nil)
                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessage", object: nil, userInfo: nil)
                }
            }else if i == "e5"{
                typeError = 5
                error = true
                if userSelectViewController == .realTimeViewController{
                    NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessageMainViewNotification", object: nil, userInfo: nil)
                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessage", object: nil, userInfo: nil)
                }
                
            }else if i == "e6"{
                typeError = 6
                error = true
                if userSelectViewController == .realTimeViewController{
                    NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessageMainViewNotification", object: nil, userInfo: nil)
                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessage", object: nil, userInfo: nil)
                }
            }
        }
        
        for i in currentMeasurement{
            
            var hour = i.componentsSeparatedByString("-")
            let measureHour = hour[0].componentsSeparatedByString(":")

            if measureHour.count == 3 && tiempoEncendidoDispositivoRecibido == false{
                
                tiempoEncendidoDispositivoRecibido = true
                hourOnDevice = hour[0]
                
            }
            if i.componentsSeparatedByString("-").count >= 2{
                activeCurrentHourFlag = false
            }
            
            if (i == "255" && measureRequestedFlag == true){
                measureRequestedFlag = false
                
                //NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentMeasurementToPeripheral", object: nil, userInfo: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("startAnimation", object: nil, userInfo: nil)
            }
            
            if (i == "255") && activeCurrentHourFlag == true{
                let date = NSDate()
                let fmt = NSDateFormatter()
                fmt.dateFormat = "HH:mm:ss"
                configurationHour = fmt.stringFromDate(date)
                
                let str:String = fmt.stringFromDate(date) + "254,"
                
                let data = str.dataUsingEncoding(NSUTF8StringEncoding)

                monitorPeripheral!.writeValue(data!, forCharacteristic: self.monitorWritableCharacteristic!, type: .WithResponse)
                
            }

            
            if (i == "255") && activeMeasurementTimeFlag == true{
                
                activeMeasurementTimeFlag = false
                let str:String?
                if UserSelectedConfiguration.userSelectMeasurementTime < 10{
                    str = "00:0\(UserSelectedConfiguration.userSelectMeasurementTime):00254,"
                }else{
                    str = "00:\(UserSelectedConfiguration.userSelectMeasurementTime):00254,"
                }
                
                let data = str!.dataUsingEncoding(NSUTF8StringEncoding)
                activeCurrentHourFlag = false
                monitorPeripheral!.writeValue(data!, forCharacteristic: self.monitorWritableCharacteristic!, type: .WithResponse)
                VectorPhysiologicalVariables.currentMeasures.removeAll()
            }
    
        }
        
        //Graphic data
        for j in currentMeasurement{
            
            if j == "254\n\rs" || j == "254\n\r" || j == "254" {
             //if j == "254" {
                var counterVariablesToGraph = 0
                
                for i in 0...(currentMeasurement.count - 1){
                    // Systolic pressure
                    if currentMeasurement[i] == "s" {
                        if Double(currentMeasurement[i+1]) == nil{
                            
                        }else{
                            counterVariablesToGraph = counterVariablesToGraph + 1
                            
                        }
                    // Diastolic pressure
                    }else if(currentMeasurement[i] == "d"){
                        if Double(currentMeasurement[i+1]) == nil{
                            
                        }else{
                            counterVariablesToGraph = counterVariablesToGraph + 1
                            
                        }
                    // Mean pressure
                    }else if(currentMeasurement[i] == "m"){
                        if Double(currentMeasurement[i+1]) == nil{
                            
                        }else{
                            counterVariablesToGraph = counterVariablesToGraph + 1
                            
                        }
                    // Battery level
                    }else if(currentMeasurement[i] == "b"){
                        if Double(currentMeasurement[i+1]) == nil{
                            
                        }else{
                            counterVariablesToGraph = counterVariablesToGraph + 1
                            
                        }
                    // Heart rate
                    }else if(currentMeasurement[i] == "f"){
                        if Double(currentMeasurement[i+1]) == nil{
                        
                        }else{
                            counterVariablesToGraph = counterVariablesToGraph + 1
                           
                        }
                    // Measurement time
                    }else if(currentMeasurement[i] == "h"){
                        counterVariablesToGraph = counterVariablesToGraph + 1
                        
                    }
                    
                }
                if counterVariablesToGraph == 6{
                    
                    
                    for i in 0...(currentMeasurement.count - 1){
                        // Systolic pressure
                        if currentMeasurement[i] == "s" {
                            if Double(currentMeasurement[i+1]) == nil{
                                
                            }else{
                                VectorPhysiologicalVariables.systolicPressure.append(Double(currentMeasurement[i+1])!)
                            }
                            // Diastolic pressure
                        }else if(currentMeasurement[i] == "d"){
                            if Double(currentMeasurement[i+1]) == nil{
                                
                            }else{
                                VectorPhysiologicalVariables.diastolicPressure.append(Double(currentMeasurement[i+1])!)
                            }
                            // Mean pressure
                        }else if(currentMeasurement[i] == "m"){
                            if Double(currentMeasurement[i+1]) == nil{
                                
                            }else{
                                VectorPhysiologicalVariables.averagePressure.append(Double(currentMeasurement[i+1])!)
                            }
                            // Battery level
                        }else if(currentMeasurement[i] == "b"){
                            if Double(currentMeasurement[i+1]) == nil{
                                
                            }else{
                                VectorPhysiologicalVariables.batteryLevel.append(Double(currentMeasurement[i+1])!)
                            }
                            // Heart rate
                        }else if(currentMeasurement[i] == "f"){
                            if Double(currentMeasurement[i+1]) == nil{
                                
                            }else{
                                VectorPhysiologicalVariables.heartRate.append(Double(currentMeasurement[i+1])!)
                            }
                            // Measurement time
                        }else if(currentMeasurement[i] == "h"){
                            VectorPhysiologicalVariables.measuringTime.append(String(UTF8String: currentMeasurement[i+1])!)
                            
                        }
                        
                    }
                }
                
                if activeCurrentMeasurementFlag == true && error == false{
                    
                    activeCurrentMeasurementFlag = false
                    NSNotificationCenter.defaultCenter().postNotificationName("displayCurrentMeasurementPopoverNotification", object: nil, userInfo: nil)
                }
                
                if counterVariablesToGraph == 6{
                    if VectorPhysiologicalVariables.diastolicPressure.last > VectorPhysiologicalVariables.averagePressure.last{
                        let comodin = VectorPhysiologicalVariables.diastolicPressure.last
                        VectorPhysiologicalVariables.diastolicPressure[VectorPhysiologicalVariables.diastolicPressure.count - 1] = VectorPhysiologicalVariables.averagePressure[VectorPhysiologicalVariables.averagePressure.count - 1]
                        VectorPhysiologicalVariables.averagePressure[VectorPhysiologicalVariables.averagePressure.count - 1] = comodin!
                    }
                    VectorPhysiologicalVariables.vectorNumberOfSamples.append(Double(VectorPhysiologicalVariables.systolicPressure.count)/10.0)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("insertNewPlot", object: nil, userInfo: nil)
                    
                    VectorPhysiologicalVariables.currentMeasures.removeAll()
                    
                    let str = "255,"
                    
                    let data = str.dataUsingEncoding(NSUTF8StringEncoding)
                    
                    monitorPeripheral!.writeValue(data!, forCharacteristic: self.monitorWritableCharacteristic!, type: .WithResponse)
                
                }
                
                VectorPhysiologicalVariables.currentMeasures.removeAll()
 
            }
        }

    }
}

//MARK: - Bluetooth Manager Delegate Protocol conformance
extension BluetoothManager:CBCentralManagerDelegate{
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("Central manager did update state")
        
        switch central.state{
        case .PoweredOn:
            print("poweredOn")
            
            // As soon as the device is on, try stablish connection with previously connected devices, if any, or scan for
            
            let servicesUUIDs:[CBUUID] = self.servicesDescriptors.map({$0.UUID()})
            print("services of interest:\(servicesUUIDs)")
            let connectedPeripherals = centralManager.retrieveConnectedPeripheralsWithServices(servicesUUIDs)
            
            if connectedPeripherals.count > 0{
                for peripheralDevice in connectedPeripherals{
                    self.centralManager.connectPeripheral(peripheralDevice, options: nil);
                    
                }
            }
            else {
                print("Scanning for periopherals")
                //centralManager.scanForPeripheralsWithServices(servicesUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
                // Send notification that Bluetooth is disconnected and start scanning
                centralManager.scanForPeripheralsWithServices(nil, options: nil)
            }
        case .PoweredOff:
            print("power off")
        case .Resetting:
            print("reseting")
        default:
            print(central.state)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        // Attempt to connect to the discovered device.
        //centralManager.stopScan()
        
        //TODO:Verify if a more rigurous selection of the device is requiered. What if several devices have the same services?
        // It is important to have a reference to the peripheral that will be connected. Otherwise, the connection does not succeed (seems to be a bug?)
        print(peripheral.name)
        //if peripheral.identifier.UUIDString == self.monitorDeviceUUIDString{
        if peripheral.name == BluetoothManager.monitorServiceName{
            print("Will attempt to connect. The peripheral UUID \(peripheral.identifier)")
            self.monitorPeripheral = peripheral
            centralManager.connectPeripheral(peripheral, options: [CBConnectPeripheralOptionNotifyOnNotificationKey: NSNumber(bool:true)])
            // Send actual hour
            //sendCurrentTime()
            
        }
        print("Found peripheral \(peripheral)")
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        print("did connnect to peripheral named \(peripheral.name!)")
        
        // Set ourselfs as the delegate for the connected peripheral.
        self.monitorPeripheral?.delegate = self
        
        //Start looking for the services of interest
        print("Will start searching for services")
        self.monitorPeripheral?.discoverServices(self.servicesDescriptors.map({$0.UUID()}))
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        if error != nil{
            print("The connection to peripheral", peripheral.name, "failed with error:", error?.description, separator: " ", terminator: "\n")
        }
        // Attempt a new connection to the device?
        if self.monitorPeripheral == peripheral{
            self.centralManager.connectPeripheral(peripheral, options: nil);
        }
        
    }
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        // Send notification that Bluetooth is connected and all required characteristics are discovered
        self.sendBTServiceNotificationWithIsBluetoothConnected(false)
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
}


//MARK: - Bluetooth Peripheral Delegate
extension BluetoothManager:CBPeripheralDelegate{
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if error != nil{
            print("An error occured discovering services for peripheral")
        }
        else{
            print("Services discovered")
            //For the given service, look up for the characteristics of interest
            for service in (monitorPeripheral?.services)!{
                let serviceDescriptor = servicesDescriptors.filter({$0.UUID().UUIDString == service.UUID.UUIDString}).first
                monitorPeripheral?.discoverCharacteristics(serviceDescriptor?.characteristicsUUID(), forService: service);
                print("Scanning characteristics for service \(serviceDescriptor?.name)");
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        if error != nil{
            print("an error ocurred during characteristics discovering process for the service",
                  servicesDescriptors.filter({$0.UUID().UUIDString == service.UUID.UUIDString}).first,
                  "The error description:",
                  error?.description, separator: " ", terminator: "\n")
            return
        }
        
        // Get notified of changes in the service characteristics
        for characteristic in service.characteristics!{
            // Print the and service for this characteristic
            if let serviceDescriptor = self.serviceDescriptorForService(service), let characteristicName = serviceDescriptor.characteristicNameForCharacteristicUUID(characteristic.UUID) {
                print("Found Characteristic", characteristicName , "of Service", serviceDescriptor.name, separator: " ", terminator: "\n")
                //if serviceDescriptor.name == BluetoothManager.monitorServiceName{
                    switch characteristic.UUID.UUIDString {
                    case (serviceDescriptor.characteristics[CharacteristicsNames.ReadFromBLEBeeKey.rawValue]?.UUIDString)!:
                        print("Found ReadFromBLEBee characteristic")
                        // If the characteristic is readable, get notify when it chages
                        if (characteristic.properties.rawValue & CBCharacteristicProperties.Read.rawValue) != 0 {
                            monitorPeripheral?.setNotifyValue(true, forCharacteristic: characteristic)
                            print("Will get notifications in changes of characteristic", characteristicName, "with uuid", characteristic.UUID,"of service", serviceDescriptor.name, separator: " ", terminator: "\n")
                        }
                    case (serviceDescriptor.characteristics[CharacteristicsNames.SendToBLEBeeKey.rawValue]?.UUIDString)!:
                        print("Found writable characteristic")
                        self.monitorWritableCharacteristic = characteristic
                        monitorPeripheral?.setNotifyValue(true, forCharacteristic: characteristic)
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("sendCurrentTimeToPeripheral", object: nil, userInfo: nil)
                    default:
                        break
                    }
                    // Send notification that Bluetooth is connected and all required characteristics are discovered
                    self.sendBTServiceNotificationWithIsBluetoothConnected(true)
                //}
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        readDataFromPeripheral(characteristic.value!)
        
    }
    func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
        let connectionDetails = ["isConnected": isBluetoothConnected]
        NSNotificationCenter.defaultCenter().postNotificationName(BLEServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
    }
    
    /** 
     Current device time
    */
    func sendCurrentTime(){
        
        let str = "t254,"
        
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)
        
        if monitorPeripheral != nil && self.monitorWritableCharacteristic != nil{
            
            activeCurrentHourFlag = true
            for i in 0...2{
                print(i)
                monitorPeripheral!.writeValue(data!, forCharacteristic: self.monitorWritableCharacteristic!, type: .WithResponse)
            }
            
        }else{
            print("no peticion de tiempo actual")
            NSNotificationCenter.defaultCenter().postNotificationName("displayDisconnectBluetoothAlertMessage", object: nil, userInfo: nil)
        }
    }
    
    /**
     Measurement time set by the user
    */
    func sendMeasurementTime(){
        
        let str = "h254,"
        
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)
    
        if monitorPeripheral != nil && self.monitorWritableCharacteristic != nil{
            
            activeMeasurementTimeFlag = true
            monitorPeripheral!.writeValue(data!, forCharacteristic: self.monitorWritableCharacteristic!, type: .WithResponse)
        }else{
            
            NSNotificationCenter.defaultCenter().postNotificationName("displayDisconnectBluetoothAlertMessage", object: nil, userInfo: nil)
        }
    
    }
    
    /**
     Start new measure
    */
    func activeCurrentMeasurement(){
        
        let str = "i254,"
        
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)
        if monitorPeripheral != nil && self.monitorWritableCharacteristic != nil{
        
            monitorPeripheral!.writeValue(data!, forCharacteristic: self.monitorWritableCharacteristic!, type: .WithResponse)
        }else{
            
            NSNotificationCenter.defaultCenter().postNotificationName("displayDisconnectBluetoothAlertMessage", object: nil, userInfo: nil)
        }
    }
    /**
     Cancel current measure
    */
    func cancelCurrentMeasurement(){
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
    func timerPrueba(){
        contador = contador + 1
        
        if contador == 30{
            contador = 0
            print(contador)
            //NSNotificationCenter.defaultCenter().postNotificationName("displayCurrentMeasurementPopoverNotification", object: nil, userInfo: nil)
            //NSNotificationCenter.defaultCenter().postNotificationName("displayErrorMessage", object: nil, userInfo: nil)
        }
        /*
        if activeCurrentMeasurementFlag == true && self.monitorWritableCharacteristic != nil{
            let str = "i254,"
            let data = str.dataUsingEncoding(NSUTF8StringEncoding)
            monitorPeripheral!.writeValue(data!, forCharacteristic: self.monitorWritableCharacteristic!, type: .WithResponse)
        }*/
        
        if (activeMeasurementTimeFlag == true && self.monitorWritableCharacteristic != nil){
            let str = "h254,"
            let data = str.dataUsingEncoding(NSUTF8StringEncoding)
            monitorPeripheral!.writeValue(data!, forCharacteristic: self.monitorWritableCharacteristic!, type: .WithResponse)
        }
        
        if (activeCurrentHourFlag == true && self.monitorWritableCharacteristic != nil){
            activeCurrentHourFlag = true
            let str = "t254,"
            let data = str.dataUsingEncoding(NSUTF8StringEncoding)
            monitorPeripheral!.writeValue(data!, forCharacteristic: self.monitorWritableCharacteristic!, type: .WithResponse)
        }
    }
}
