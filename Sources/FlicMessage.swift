//
//  FlicMessage.swift
//  FlicController
//
//  Created by Fred Rajaona on 17/07/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

struct FlicMessage: Message {
    
    let type: UInt8
    var payload: NSData?
    var waitingBytes: Int
    
    var length: UInt16 {
        var result = UInt16(1)
        if let d = payload {
            result += UInt16(d.length)
        }
        return result
    }
    
    init(commandType: UInt8, data: NSData?) {
        type = commandType
        payload = data
        waitingBytes = 0
    }
    
    init(fromData data: NSData) {
        var byte16 = UInt16(0)
        (data as NSData).getBytes(&byte16, length: 2)
        let length = byte16
        
        var byte8 = UInt8(0)
        (data as NSData).getBytes(&byte8, range: NSMakeRange(2, 1))
        type = byte8
        let left = data.length - 3
        if length > 1 {
            let subDataLength = (left < Int(length) - 1) ? left : Int(length) - 1
            payload = data.subdata(with: NSMakeRange(3, subDataLength)) as NSData?
            waitingBytes = Int(length) - 1 - left
        } else {
            payload = nil
            waitingBytes = 0
        }
    }
    
    mutating func addData(_ data: NSData) {
        let newPayload = NSMutableData(data: payload! as Data)
        if waitingBytes <= data.length {
            // There is enough new data to complete the message. Only grab what we need
            newPayload.append(data.subdata(with: NSMakeRange(0, waitingBytes)))
        } else {
            // Add all data we've got and wait for more
            newPayload.append(data as Data)
        }
        payload = newPayload
        waitingBytes = waitingBytes - data.length
    }
    
    func getData() -> Data {
        let data = NSMutableData()
        
        var byte16 = length.littleEndian
        data.append(&byte16, length: 2)
        
        var byte8 = type
        data.append(&byte8, length: 1)
        
        if let p = payload {
            data.append(p as Data)
        }
        
        return data as Data
    }
}


struct FlicCommand {
    
    enum CommandType: UInt8 {
        case getInfo = 0
        case createScanner
        case removeScanner
        case createConnectionChannel
        case removeConnectionChannel
        case forceDisconnect
        
        case createScanWizard = 9
        case cancelScanWizard
    }
    
    let commandType: CommandType
    let message: FlicMessage
    
    init(commandType: CommandType, data: Data?) {
        self.commandType = commandType
        message = FlicMessage(commandType: commandType.rawValue, data: data as NSData?)
    }
    
}


struct FlicEvent: CustomStringConvertible {
    
    enum EventType: UInt8 {
        case advertisementPacket = 0
        case createConnectionChannelResponse
        case connectionStatusChanged
        case connectionChannelRemoved
        
        case buttonUpOrDown
        case buttonClickOrHold
        case buttonSingleOrDoubleClick
        case buttonSingleOrDoubleClickOrHold
        
        case newVerifiedButton = 8
        
        case getInfoResponse = 9
        
        case scanWizardFoundPrivateButton = 15
        case scanWizardFoundPublicButton
        case scanWizardButtonConnected
        case scanWizardCompleted
        case unknown = 254
    }
    
    var description: String {
        return "FlicEvent -> \(eventType) | \(message.payload)"
    }
    
    let eventType: EventType
    var message: FlicMessage
    
    var needMoreData: Bool {
        return message.waitingBytes > 0
    }
    
    var uselessDataLength: Int {
        if message.waitingBytes < 0 {
            return -message.waitingBytes
        }
        return 0
    }
    
    var payload: NSData? {
        return message.payload
    }
    
    init(fromData data: NSData) {
        message = FlicMessage(fromData: data)
        eventType = EventType.init(rawValue: message.type) ?? EventType.unknown
    }
    
    mutating func addData(_ data: NSData) {
        message.addData(data)
    }
    
    func getData() -> NSData {
        return NSData()
    }
}
