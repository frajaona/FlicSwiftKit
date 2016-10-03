//
//  ButtonInfo.swift
//  FlicController
//
//  Created by Fred Rajaona on 20/07/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

struct ScanButtonInfo {
    
    let bluetoothAddress: String
    let rawBluetoothAddress: [UInt8]
    let name: String
    let rssi: Int
    let privateMode: Bool
    let alreadyVerified: Bool
    let isAdvertisement: Bool
    
    init(fromData data: Data, isAdvertisement: Bool) {
        var bdAddr = [UInt8](repeating: 0, count: 6)
        (data as NSData).getBytes(&bdAddr, range: NSMakeRange(4, 6))
        bluetoothAddress = BluetoothUtils.convertToString(bdAddr)
        rawBluetoothAddress = bdAddr
        
        var byte8 = UInt8(0)
        (data as NSData).getBytes(&byte8, range: NSMakeRange(10, 1))
        let nameSize = Int(byte8)
        var name = [UInt8](repeating: 0, count: nameSize)
        (data as NSData).getBytes(&name, range: NSMakeRange(11, nameSize))
        
        self.name = String(bytes: name, encoding: String.Encoding.utf8)!
        
        self.isAdvertisement = isAdvertisement
        
        if isAdvertisement {
            var signedByte8 = Int8(0)
            (data as NSData).getBytes(&signedByte8, range: NSMakeRange(27, 1))
            rssi = Int(signedByte8)
            
            (data as NSData).getBytes(&byte8, range: NSMakeRange(28, 1))
            privateMode = byte8 > 0
            
            (data as NSData).getBytes(&byte8, range: NSMakeRange(29, 1))
            alreadyVerified = byte8 > 0
        } else {
            rssi = -127
            privateMode = false
            alreadyVerified = false
        }
    }
    
    static func isRssiValid(_ rssi: Int) -> Bool {
        return rssi > -127 && rssi <= 20
    }
    
}
