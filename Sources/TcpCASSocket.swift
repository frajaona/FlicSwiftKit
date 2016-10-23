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

struct TcpCASSocket<T: Message>: Socket {
    
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
