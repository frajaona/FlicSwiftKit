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
#if SWIFT_PACKAGE
import SocksCore
#else
import socks
#endif

protocol TcpSocksSocketDelegate {
    func onConnected(to socket: TcpSocksSocket)
    func onRead(data: NSData, from socket: TcpSocksSocket)
    func onSent(by socket: TcpSocksSocket)
}

class TcpSocksSocket: Socket {
    
    private let port: UInt16
    private let socket: TCPInternetSocket?
    private var connected = false
    
    private let socketQueue: DispatchQueue
    private let readQueue: DispatchQueue
    
    private let delegate: TcpSocksSocketDelegate
    
    init(destPort: UInt16, socketDelegate: TcpSocksSocketDelegate) {
        port = destPort
        delegate = socketDelegate
        socketQueue = DispatchQueue(label: "SocketQueue")
        readQueue = DispatchQueue(label: "SocketReadQueue")
        let address = InternetAddress.localhost(port: destPort)
        do {
            socket = try TCPInternetSocket(address: address)
        } catch let error {
            print("failed creating socket: \(error)")
            socket = nil
        }
    }
    
    func openConnection() -> Bool {
        return socketQueue.sync {
            do {
                try socket?.connect()
                connected = true
                startReceivingMessage()
                delegate.onConnected(to: self)
            } catch let error {
                print("Cannot connect to host: \(error)")
                connected = false
            }
            return connected
        }
    }
    
    func closeConnection() {
        socketQueue.sync {
            do {
                try socket?.close()
            } catch let error {
                print("Cannot close socket: \(error)")
            }
        }
        connected = false
    }
    
    func isConnected() -> Bool {
        return socketQueue.sync { connected }
    }
    
    func sendMessage<T: Message>(_ message: T, address: String) {
        sendMessage(message)
    }
    
    func sendMessage<T: Message>(_ message: T) {
        let data = message.getData()
        let bytes = data.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
        }
        socketQueue.async {
            [unowned self] in
            if self.connected {
                do {
                    try self.socket?.send(data: bytes)
                    DispatchQueue.main.async {
                        [unowned self] in
                        self.delegate.onSent(by: self)
                    }
                } catch let error {
                    print("failed sending message: \(error)")
                }
            }
        }
        
    }
    
    private func startReceivingMessage() {
        readQueue.async {
            [unowned self] in
            while self.isConnected() {
                do {
                    if var bytes = try self.socket?.recvAll() {
                        let data = NSData(bytes: &bytes, length: bytes.count)
                        DispatchQueue.main.async {
                            [unowned self] in
                            self.delegate.onRead(data: data, from: self)
                        }
                    }
                } catch let error {
                    print("failed reading bytes: \(error)")
                }
            }
        }
    }
    
}
