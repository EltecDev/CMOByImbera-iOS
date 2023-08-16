//
//  BLEControl.swift
//  BLE Intro
//
//  Created by mauro on 10/08/15.
//  Copyright (c) 2015 mauro. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit


class BLEControl : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    let service : CBUUID = CBUUID(string: "FF75992E-F2AE-4E06-B9EE-91F706958713")
    let characteristic : CBUUID = CBUUID(string: "C3FB9A85-6D5A-40DB-B377-D91FEDCC477B")
    var centralManager : CBCentralManager! // objeto que permite escanear y administrar dispositivos bluethooth
    var delegate : BLEDelegate!
    var foundDevices : NSMutableDictionary!
    var foundDevices2 : NSMutableDictionary!
    var dispositivoCorrente : CBPeripheral?
    var currentInvia : CBCharacteristic?
    var currentRicevi : CBCharacteristic?
    var currentMessage: String = ""
    var uds = UserDefaults.standard
    init(delegate : BLEDelegate){
        super.init()
        self.delegate = delegate
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global()) // se convierte en delegado para recibir eventos y resultados
        foundDevices = NSMutableDictionary()
    }
    
    func disconnectCurrentlyConnectedDevice(){
        if(dispositivoCorrente != nil){
            centralManager.cancelPeripheralConnection(dispositivoCorrente!)
        }
    }
    
    func bleScan(_ start: Bool){
  
        if(start){
            //foundDevices.removeAllObjects()
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        } else {
            centralManager.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let deviceName = peripheral.name;
        if(deviceName != nil){
        let localName : String? = advertisementData[CBAdvertisementDataLocalNameKey] as? String
            if(localName != nil){
                foundDevices.setObject(peripheral, forKey: peripheral.identifier as NSCopying)
                delegate.newDeviceScanned(deviceName!, localName : localName!, uuid: peripheral.identifier, rssi: RSSI.intValue, advertisementData: advertisementData)
            }
        }else{
            print("no se encontraron dispositivos ")
        }
    }
    

    func connectToDevice(_ uuid : UUID!) -> Bool{
        
        let device : CBPeripheral? = foundDevices.object(forKey: uuid!) as? CBPeripheral
        
        if(device == nil){
            
            print("device properties nil")
            return false
            
        }else{
            bleScan(false)
            centralManager.connect(device!, options: nil)
            delegate.connectionState((device?.name!)!, state: true)
            return true
        }
        
    }
    
    func connectToDevice2(_ uuid : UUID!) -> Bool{
        foundDevices = dictionary1.sharedInstance.foundDevicesShared
        let device : CBPeripheral? = foundDevices.object(forKey: uuid!) as? CBPeripheral
        
        if(device == nil){
            
            print("device properties nil")
            return false
            
        }else{
            bleScan(false)
            centralManager.connect(device!, options: nil)
            delegate.connectionState((device?.name!)!, state: true)
            return true
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        dispositivoCorrente = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        delegate.connectionState(peripheral.name!, state: true)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate.connectionState(peripheral.name!, state: false)
    }
    // metodo que se llama cuando se encuentra un dispositivo
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        dispositivoCorrente = peripheral
        currentInvia = nil
        currentRicevi = nil
        delegate.connectionState(peripheral.name!, state: false)
        print("Dispositivo encontrado: \(peripheral.name ?? "Desconocido"), UUID: \(peripheral.identifier.uuidString)")
    }
    // metodo que se llama cuando el estado del bluetooth se cambia
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        
        switch (central.state){
        case .unsupported:
            print("BLE non è supportato")
        case .unauthorized:
            print("BLE non è autorizzato")
        case .unknown:
            print("BLE non riconosciuto")
        case .resetting:
            print("BLE si sta resettando")
        case .poweredOff:
            print("BLE power off")
        case .poweredOn:
            print("BLE power on")
            print("Avvio scansione")
            central.scanForPeripherals(withServices: nil , options: nil) // el bluetooth esta activado se inicia el scaneo
            
        default:
            break
          
        }
    }
    
    func peripheral(  _ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        dispositivoCorrente = peripheral
        let services = dispositivoCorrente?.services
        if ((services?.isEmpty) != nil){
            
            print("servicios del dispositivo: ")
            print(peripheral.services as Any)
            print(services?.count as Any)
            for service in services!{
                    let cbService = service
                print(cbService.uuid.uuidString)
                    if cbService.uuid.uuidString.contains("FFE0"){
                        
                            print("servicio encontrado")
                            peripheral.discoverCharacteristics(nil, for: cbService)
                        
                            break
                        
                    }else{
                        print("servicio no encontrado")
                    }
                }
        }else{
           // print("nulo")
            print("servicios del dispositivo: ")
            print(dispositivoCorrente?.services as Any)
            print(services?.count as Any)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        dispositivoCorrente = peripheral
        if ((dispositivoCorrente?.identifier.uuidString.elementsEqual("FFE0")) != nil) {
            print("service is correct ")
    
            let characteristics = service.characteristics
            for characteristic in characteristics! {
                let cbCharacteristic  = characteristic
                print("uuid's characteristic")
                print(characteristic.uuid.uuidString)
                if characteristic.uuid.uuidString.elementsEqual("FFE1"){
                    currentInvia = cbCharacteristic
                    currentRicevi = cbCharacteristic
                    print("get characteristic")
                    
                    dispositivoCorrente!.setNotifyValue(true, for: currentRicevi!)
                    dispositivoCorrente!.readValue(for: currentRicevi!)
                    break
                }
            }
            print("caracteristica lista para escribir y leer : " + (self.currentInvia?.uuid.uuidString)!)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("did update value for function")

     //   print(hex)
       /* let arr2 = characteristic.value!.withUnsafeBytes {
            Array(UnsafeBufferPointer<UInt32>(start: $0, count: characteristic.value!.count/MemoryLayout<UInt8>.stride))
        }
        print(arr2)*/
        //verificar que la caracteristica sea valida o no nula
                print("correct characteristic")
                if ((characteristic.value?.isEmpty) != nil){
                      //  let stringValue =  String(data: characteristic.value!, encoding: String.Encoding.ascii)
                        //print("Value Recieved ascii: \((stringValue! as String))")
                        //var hex = characteristic.value!.hexEncodedString()
                        //print(stringValue?.substring(with: 3..<14) as Any)
                        //print("value received hexa, separator -: " + hex)
                        delegate.receivedStringValue((dispositivoCorrente?.name)!, dataStr: characteristic.value!)
                }
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(error as Any)
    }
    
    func sendData(_ dato1: String){
//        sendData es una función de intermedio para llamar a la función que realmente escribe que es "write string",
//        Esta función sirve para hacer el procesamiento de los datos que se enviaran, es decir formato de plantilla, verificación de bytes o de datos correctos etc
        print("send data")
        print(dato1)
        if (!dato1.isEmpty){
            writeString("\(dato1)")
        }else{
            print("is empty")
        }
        
    }
    func writeData(_ data:Data){
        //       let data = Data(bytes: string, count: contData)
        //        print(data)
        if ((currentInvia) != nil){
            print("write data")
            
            dispositivoCorrente?.writeValue(Data(data), for: currentInvia!, type: CBCharacteristicWriteType.withResponse)
            
        }
    }
    
    func writeString(_ string:String){
        //let data = Data(bytes: string, count: string.count)
        //print(data)
        let data = string.bytes
        if ((currentInvia) != nil){
            print("write data")
            
            dispositivoCorrente?.writeValue(Data(data), for: currentInvia!, type: CBCharacteristicWriteType.withResponse)
            
        }
        
    }
}
 
extension StringProtocol {
//    obtener bytes[uint8] y data de un string
    var data1: Data { .init(utf8) }
    var bytes1: [UInt8] { .init(utf8) }
    
//    conversiones de tipos de datos provenientes de  un string
    func dropping<S: StringProtocol>(prefix: S) -> SubSequence { hasPrefix(prefix) ? dropFirst(prefix.count) : self[...] }
    var hexaToDecimal: Int { Int(dropping(prefix: "0x"), radix: 16) ?? 0 }
    var hexaToBinary: String { .init(hexaToDecimal, radix: 2) }
    var decimalToHexa: String { .init(Int(self) ?? 0, radix: 16) }
    var decimalToBinary: String { .init(Int(self) ?? 0, radix: 2) }
    var binaryToDecimal: Int { Int(dropping(prefix: "0b"), radix: 2) ?? 0 }
    var binaryToHexa: String { .init(binaryToDecimal, radix: 16) }
    
//    parte una cadena en un array de string elements en un numero definido (2 en 2, 3 en 3 etc)
    public func chunked(into size: Int) -> [SubSequence] {
        var chunks: [SubSequence] = []
        
        var i = startIndex
        
        while let nextIndex = index(i, offsetBy: size, limitedBy: endIndex) {
            chunks.append(self[i ..< nextIndex])
            i = nextIndex
        }
        
        let finalChunk = self[i ..< endIndex]
        
        if finalChunk.isEmpty == false {
            chunks.append(finalChunk)
        }
        
        return chunks
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined(separator: " ")
     
    }
}

extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
    func hexStringNoSpace() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension String {
    
    func index(from: Int) -> Index {
         return self.index(startIndex, offsetBy: from)
     }

     func substring(from: Int) -> String {
         let fromIndex = index(from: from)
         return String(self[fromIndex...])
     }

     func substring(to: Int) -> String {
         let toIndex = index(from: to)
         return String(self[..<toIndex])
     }

     func substring(with r: Range<Int>) -> String {
         let startIndex = index(from: r.lowerBound)
         let endIndex = index(from: r.upperBound)
         return String(self[startIndex..<endIndex])
     }
    
}
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

