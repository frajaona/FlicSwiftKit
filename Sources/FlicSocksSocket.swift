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
import socks

class FlicSocksSocket: FlicSocket {
    var tcpSocket: Socket? {
        return rawSocket
    }
    
    fileprivate var rawSocket: TcpSocksSocket?
    
    fileprivate var pendingEvent: FlicEvent?
    
    var eventHandler: ((FlicEvent) -> ())?
    
    func openConnection() {
        let socket = TcpSocksSocket(destPort: FlicSocksSocket.TcpPort, socketDelegate: self)
        
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

extension FlicSocksSocket: TcpSocksSocketDelegate {
    
    func onConnected(to socket: TcpSocksSocket) {
        print("socked did connect")
        rawSocket?.sendMessage(FlicCommand(commandType: FlicCommand.CommandType.getInfo, data: nil).message)
    }
    
    func onRead(data: NSData, from socket: TcpSocksSocket) {
        var events = parseData(data as NSData, currentPendingEvent: pendingEvent)
        while let event = events.complete {
            eventHandler?(event)
            // Received data can contain several events so loop while there is still some bytes available
            if let remainingData = events.remainingData {
                events = parseData(remainingData as NSData, currentPendingEvent: events.pending)
            } else {
                break
            }
        }
        pendingEvent = events.pending

    }
    
    func onSent(by socket: TcpSocksSocket) {
        print("socked did send data")
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
