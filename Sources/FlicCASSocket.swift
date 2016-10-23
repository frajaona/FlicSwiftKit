/*
 * Copyright (C) 2016 Fred Rajaona
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import CocoaAsyncSocket

class FlicCASSocket: FlicSocket {
    
    var tcpSocket: Socket? {
        return rawSocket
    }
    
    fileprivate var rawSocket: TcpCASSocket<FlicMessage>?
    
    fileprivate var pendingEvent: FlicEvent?
    
    var eventHandler: ((FlicEvent) -> ())?
    
    func openConnection() {
        let socket = TcpCASSocket<FlicMessage>(destPort: FlicCASSocket.TcpPort, shouldBroadcast: true, socketDelegate: self)
        
        rawSocket = socket
        
        if !socket.openConnection() {
            closeConnection()
        } else {
            
        }
    }
    
    func closeConnection() {
        rawSocket?.closeConnection()
        rawSocket = nil
    }
    
    func isConnected() -> Bool {
        return tcpSocket != nil
    }
    
}

extension FlicCASSocket: GCDAsyncSocketDelegate {
    
    @objc func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        rawSocket?.readMessage()
        print("socked did connect to host=[\(host)] on port=[\(port)]")
        rawSocket?.sendMessage(FlicCommand(commandType: FlicCommand.CommandType.getInfo, data: nil).message)
    }
    
    @objc func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("socked did write data with tag \(tag)")
        rawSocket?.readMessage()
    }
    
    @objc func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Socket disconnect: \(err?.localizedDescription)")
        closeConnection()
    }
    
    @objc func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("\nReceive data with tag:[\(tag)], data = \(data)")
        var events = parseData(data as NSData, currentPendingEvent: pendingEvent)
        while let event = events.complete {
            //handleEvent(event)
            eventHandler?(event)
            // Received data can contain several events so loop while there is still some bytes available
            if let remainingData = events.remainingData {
                events = parseData(remainingData as NSData, currentPendingEvent: events.pending)
            } else {
                break
            }
        }
        pendingEvent = events.pending
        rawSocket?.readMessage()
    }
    
    @objc func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("socked did accept new socket")
    }
    
    func parseData(_ data: NSData, currentPendingEvent: FlicEvent?) -> (complete: FlicEvent?, pending: FlicEvent?, remainingData: Data?) {
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
