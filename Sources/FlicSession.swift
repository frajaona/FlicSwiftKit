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

protocol FlicSessionDelegate {
    func flicSession(_ session: FlicSession, didReceiveEvent event: FlicEvent)
}

class FlicSession: Session {
    
    fileprivate var tcpSocket: FlicSocket
    
    var delegate: FlicSessionDelegate?
    
    var broadcastAddress: String? {
        didSet {
            if (isConnected()) {
                print("Cannot change broadcast address while connected")
                broadcastAddress = oldValue
            }
        }
    }
    
    init(socket: FlicSocket) {
        tcpSocket = socket
        tcpSocket.eventHandler = handleEvent
    }
    
    func start() {
        if !isConnected() {
            tcpSocket.openConnection()
        } else {
            print("Explorer already started")
        }
    }
    
    func stop() {
        tcpSocket.closeConnection()
    }
    
    func isConnected() -> Bool {
        return tcpSocket.isConnected()
    }
    
    func sendMessage<T: Message>(_ message: T, address: String = "none") {
        if address == "none" {
            tcpSocket.tcpSocket?.sendMessage(message)
        } else {
            tcpSocket.tcpSocket?.sendMessage(message, address: address)
        }
    }
    
    fileprivate func handleEvent(_ event: FlicEvent) {
        print("Handle event: \(event)")
        delegate?.flicSession(self, didReceiveEvent: event)
    }
    
}
