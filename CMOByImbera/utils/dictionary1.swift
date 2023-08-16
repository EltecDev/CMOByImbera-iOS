//
//  dictionary1.swift
//  CMOByImbera
//
//  Created by Victor Manuel Garcia on 15/11/22.
//

import Foundation
import CoreBluetooth

class dictionary1:NSObject{
    
    static let sharedInstance = dictionary1()
    var foundDevicesShared : NSMutableDictionary!
    override init() {
        super.init()
    }
    func setDevice(device: CBPeripheral){
        self.foundDevicesShared.setObject(device, forKey: device.identifier as NSCopying)
        
    }
    
}
