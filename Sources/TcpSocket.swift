//
//  TcpSocket.swift
//  FlicController
//
//  Created by Fred Rajaona on 17/07/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

import CocoaAsyncSocket

struct TcpSocket<T: Message>: Socket {
    
    private let delegate: GCDAsyncSocketDelegate
    
    private let socket: GCDAsyncSocket
    
    private let port: UInt16
    
    private let enableBroadcast: Bool
    
    init(destPort: UInt16, shouldBroadcast: Bool, socketDelegate: GCDAsyncSocketDelegate) {
        delegate = socketDelegate
        port = destPort
        enableBroadcast = shouldBroadcast
        socket = GCDAsyncSocket(delegate: delegate, delegateQueue: DispatchQueue.main)
    }
    
    func openConnection() -> Bool {
        
        do {
            try socket.connect(toHost: "localhost", onPort: port)
        } catch let error as NSError {
            print("Cannot connect to host: \(error.description)")
            closeConnection()
            return false
        }
        
        return true
    }
    
    func sendMessage<T : Message>(_ message: T, address: String) {
        let strData = message.getData()
        print("\n\nsending(\(strData.count)): \(strData.description)\n\n")
        socket.write(message.getData() as Data!, withTimeout: -1, tag: 0)
    }
    
    func sendMessage<T : Message>(_ message: T) {
        let strData = message.getData()
        print("\n\nsending(\(strData.count)): \(strData.description)\n\n")
        socket.write(message.getData() as Data!, withTimeout: -1, tag: 0)
    }
    
    func readMessage() {
        socket.readData(withTimeout: -1, tag: 0)
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func isConnected() -> Bool {
        return socket.isConnected
    }
}
