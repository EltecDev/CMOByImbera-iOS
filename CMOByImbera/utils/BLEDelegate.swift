//
//  BLEDelegate.swift
//
//
//  Created by mauro on 10/08/15.
//  Copyright (c) 2015 mauro. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol BLEDelegate {
    
    //Step 1: Recezione del pacchetto BLE device
    func newDeviceScanned(_ deviceName : String, localName : String, uuid: UUID, rssi : Int, advertisementData : [AnyHashable: Any]!)
    
    
    //Step 2: Stato della connessione
    func connectionState(_ deviceName : String, state : Bool)
    
    
    //Step 3: Ricezione dati
    func receivedStringValue(_ deviceName: String, dataStr : Data )
    
}
