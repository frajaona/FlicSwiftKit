//
//  ConnectionEvent.swift
//  FlicController
//
//  Created by Fred Rajaona on 07/08/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation


struct CreateConnectionChannelResponse: CustomStringConvertible {
    
    let connectionId: UInt32
    let connectionError: CreateConnectionChannelError
    let connectionStatus: ConnectionStatus
    
    init(fromData data: Data) {
        var id = UInt32(0)
        (data as NSData).getBytes(&id, range: NSMakeRange(0, 4))
        connectionId = id
        var byte8 = UInt8(0)
        (data as NSData).getBytes(&byte8, range: NSMakeRange(4, 1))
        connectionError = CreateConnectionChannelError(rawValue: byte8)
        (data as NSData).getBytes(&byte8, range: NSMakeRange(5, 1))
        connectionStatus = ConnectionStatus(rawValue: byte8)
    }
    
    var description: String {
        return "CreateConnectionChannelResponse: \n\tconnectionId = \(connectionId)\n\tconnectionStatus = \(connectionStatus)\n\tconnectionError = \(connectionError) "
    }
}

struct ConnectionStatusChanged {
    
    let connectionId: UInt32
    let connectionStatus: ConnectionStatus
    let disconnectReason: DisconnectReason
    
    init(fromData data: Data) {
        var id = UInt32(0)
        (data as NSData).getBytes(&id, range: NSMakeRange(0, 4))
        connectionId = id
        var byte8 = UInt8(0)
        (data as NSData).getBytes(&byte8, range: NSMakeRange(4, 1))
        connectionStatus = ConnectionStatus(rawValue: byte8)
        (data as NSData).getBytes(&byte8, range: NSMakeRange(5, 1))
        disconnectReason = DisconnectReason(rawValue: byte8)
    }
}

struct ConnectionChannelRemoved {
    
    let connectionId: UInt32
    let removedReason: RemovedReason
    
    init(fromData data: Data) {
        var id = UInt32(0)
        (data as NSData).getBytes(&id, range: NSMakeRange(0, 4))
        connectionId = id
        var byte8 = UInt8(0)
        (data as NSData).getBytes(&byte8, range: NSMakeRange(4, 1))
        removedReason = RemovedReason(rawValue: byte8)
    }
}

