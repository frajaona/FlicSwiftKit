//
//  FlicSession.swift
//  FlicController
//
//  Created by Fred Rajaona on 17/07/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

protocol FlicSessionDelegate {
    func flicSession(_ session: FlicSession, didReceiveEvent event: FlicEvent)
}

class FlicSession: Session {
    
    
    fileprivate static let TcpPort: UInt16 = 5551
    
    var tcpSocket: TcpSocket<FlicMessage>?
    
    var delegate: FlicSessionDelegate?
    
    fileprivate var pendingEvent: FlicEvent?
    
    var broadcastAddress: String? {
        didSet {
            if (isConnected()) {
                print("Cannot change broadcast address while connected")
                broadcastAddress = oldValue
            }
        }
    }
    
    func start() {
        if !isConnected() {
            openConnection()
        } else {
            print("Explorer already started")
        }
    }
    
    func stop() {
        closeConnection()
    }
    
    fileprivate func openConnection() {
        let socket = TcpSocket<FlicMessage>(destPort: FlicSession.TcpPort, shouldBroadcast: true, socketDelegate: self)
        
        tcpSocket = socket
        
        if !socket.openConnection() {
            closeConnection()
        } else {
            
        }
    }
    
    fileprivate func closeConnection() {
        tcpSocket?.closeConnection()
        tcpSocket = nil
    }
    
    func isConnected() -> Bool {
        return tcpSocket != nil
    }
    
    fileprivate func handleEvent(_ event: FlicEvent) {
        print("Handle event: \(event)")
        delegate?.flicSession(self, didReceiveEvent: event)
    }
    
    fileprivate func parseData(_ data: NSData, currentPendingEvent: FlicEvent?) -> (complete: FlicEvent?, pending: FlicEvent?, remainingData: Data?) {
        var flicEvent: FlicEvent? = nil
        var pendingEvent = currentPendingEvent
        var remainingData: Data? = nil
        if var event = pendingEvent , event.needMoreData {
            print("\nPending event \(event.eventType) need more data")
            event.addData(data)
            if !event.needMoreData {
                print("\nPending event \(event.eventType) got all these data")
                flicEvent = event
                pendingEvent = nil
            } else {
                pendingEvent = event
            }
        } else {
            let event = FlicEvent(fromData: data)
            print("\nreceive new event \(event.eventType)")
            if !event.needMoreData {
                flicEvent = event
            } else {
                print("\new event \(event.eventType) will need more data")
                pendingEvent = event
            }
        }
        if let event = flicEvent , event.uselessDataLength > 0 {
            remainingData = data.subdata(with: NSMakeRange(data.length - event.uselessDataLength, event.uselessDataLength))
        }
        return (flicEvent, pendingEvent, remainingData)
    }
    
}

extension FlicSession: GCDAsyncSocketDelegate {
    
    @objc func socket(_ sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        tcpSocket?.readMessage()
        print("socked did connect to host=[\(host)] on port=[\(port)]")
        tcpSocket?.sendMessage(FlicCommand(commandType: FlicCommand.CommandType.getInfo, data: nil).message)
    }
    
    @objc func socket(_ sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        print("socked did write data with tag \(tag)")
        tcpSocket?.readMessage()
    }
    
    @objc func socketDidDisconnect(_ sock: GCDAsyncSocket!, withError err: Error!) {
        print("Socket disconnect: \(err.localizedDescription)")
        closeConnection()
    }
    
    @objc func socket(_ sock: GCDAsyncSocket!, didRead data: Data!, withTag tag: Int) {
        print("\nReceive data with tag:[\(tag)], data = \(data)")
        var events = parseData(data as NSData, currentPendingEvent: pendingEvent)
        while let event = events.complete {
            handleEvent(event)
            // Received data can contain several events so loop while there is still some bytes available
            if let remainingData = events.remainingData {
                events = parseData(remainingData as NSData, currentPendingEvent: events.pending)
            } else {
                break
            }
        }
        pendingEvent = events.pending
        tcpSocket?.readMessage()
    }
    
    @objc func socket(_ sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        print("socked did accept new socket")
    }
    
}