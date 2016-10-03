//
//  FlicControllerInfo.swift
//  FlicController
//
//  Created by Fred Rajaona on 20/07/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

struct FlicControllerInfo {
    
    fileprivate let bluetoothControllerState: BluetoothControllerState
    fileprivate let bluetoothAddress: String
    fileprivate let bluetoothAddressType: BdAddrType
    fileprivate let maxPendingConnection: Int
    fileprivate let maxConcurrentlyConnectedButton: Int
    fileprivate let currentPendingConnectionCount: Int
    fileprivate let canConnect: Bool
    let verifiedButtons: [[UInt8]]
    
    init(fromData bytes: Data) {
        var byte8 = UInt8(0)
        (bytes as NSData).getBytes(&byte8, length: 1)
        
        bluetoothControllerState = BluetoothControllerState(rawValue: byte8)
        
        var bdAddr = [UInt8](repeating: 0, count: 6)
        (bytes as NSData).getBytes(&bdAddr, range: NSMakeRange(1, 6))
        bluetoothAddress = BluetoothUtils.convertToString(bdAddr)
        
        (bytes as NSData).getBytes(&byte8, range: NSMakeRange(7, 1))
        bluetoothAddressType = BdAddrType(rawValue: byte8)
        
        (bytes as NSData).getBytes(&byte8, range: NSMakeRange(8, 1))
        maxPendingConnection = Int(byte8)
        
        var byte16 = UInt16(0)
        (bytes as NSData).getBytes(&byte16, range: NSMakeRange(9, 2))
        maxConcurrentlyConnectedButton = Int(byte16)
        
        (bytes as NSData).getBytes(&byte8, range: NSMakeRange(11, 1))
        currentPendingConnectionCount = Int(byte8)
        
        (bytes as NSData).getBytes(&byte8, range: NSMakeRange(12, 1))
        canConnect = byte8 == 0
        
        (bytes as NSData).getBytes(&byte16, range: NSMakeRange(13, 2))
        var buttons = [[UInt8]]()
        var start = 15
        for _ in 0..<Int(byte16) {
            (bytes as NSData).getBytes(&bdAddr, range: NSMakeRange(start, 6))
            start += 6
            let addr = bdAddr
            buttons.append(addr)
        }
        verifiedButtons = buttons
    }
}

extension FlicControllerInfo: CustomStringConvertible {
    var description: String {
        return "\n\tbluetoothControllerState = \(self.bluetoothControllerState.rawValue),\n\tbluetoothAddress = \(self.bluetoothAddress),\n\tbluetoothAddressType = \(self.bluetoothAddressType.rawValue),\n\tverified buttons = \(self.verifiedButtons)"
    }
}
