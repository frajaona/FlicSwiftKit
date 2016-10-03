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

public protocol ConnectionManagerObserver {
    var observerHashValue: String { get }
    func onConnectionManagerChange()
}

public class ConnectionManager {
    
    private let connectionId = UInt32(0)
    
    private let session: FlicSession
    
    private var observers = [String: ConnectionManagerObserver]()
    
    public var error: String?
    
    private var connections = [UInt32: FlicButton]()
    
    public var buttons: [FlicButton] {
        return Array(connections.values)
    }
    
    init(session: FlicSession) {
        self.session = session
    }
    
    public func registerObserver(_ observer: ConnectionManagerObserver) {
        if observers[observer.observerHashValue] == nil {
            observers[observer.observerHashValue] = observer
        }
        observer.onConnectionManagerChange()
    }
    
    public func unregisterObserver(_ observer: ConnectionManagerObserver) {
        observers[observer.observerHashValue] = nil
    }
    
    func connectButton(_ rawButtonAddress: [UInt8]) {
        let address = BluetoothUtils.convertToString(rawButtonAddress)
        var found = false
        for (id, connectedButton) in connections {
            if address == connectedButton.bluetoothAddress {
                print("button [\(address)] is already connected with connectionId [\(id)] ")
                found = true
                break;
            }
        }
        if !found {
            let button = FlicButton(flicSession: session, rawAddress: rawButtonAddress, connectable: true, priv: false)
            let id = doCreateConnectionChannel(rawButtonAddress)
            connections[id] = button
        }
    }
    
    func notifyObservers() {
        for (_, observer) in observers {
            observer.onConnectionManagerChange()
        }
    }
    
    func handleEvent(_ event: FlicEvent) {
        switch event.eventType {
        case .createConnectionChannelResponse:
            if let data = event.payload {
                let response = CreateConnectionChannelResponse(fromData: data as Data)
                print("ConnectionManager handleEvent \(response)")
                if let button = connections[response.connectionId] {
                    if response.connectionError == CreateConnectionChannelError.NoError {
                        button.connectionStatus = response.connectionStatus
                    } else {
                        // Error max pending connection reached
                        button.connectionStatus = ConnectionStatus.WontConnect
                    }
                    notifyObservers()
                }
            }
        case .connectionStatusChanged:
            if let data = event.payload {
                let connectionEvent = ConnectionStatusChanged(fromData: data as Data)
                if let button = connections[connectionEvent.connectionId] {
                    button.connectionStatus = connectionEvent.connectionStatus
                    if button.connectionStatus == .Disconnected {
                        button.disconnectReason = connectionEvent.disconnectReason
                    }
                    notifyObservers()
                }
            }
        case .connectionChannelRemoved:
            if let data = event.payload {
                let connectionChannelRemoved = ConnectionChannelRemoved(fromData: data as Data)
                if let button = connections[connectionChannelRemoved.connectionId] {
                    button.connectionStatus = ConnectionStatus.Disconnected
                    button.disconnectReason = nil
                    connections[connectionChannelRemoved.connectionId] = nil
                    notifyObservers()
                }
            }
        default:
            print("connectionManager: unhandled event \(event)")
        }
    }
    
    func handleButtonEvent(_ event: FlicEvent) {
        switch event.eventType {
        case .buttonUpOrDown, .buttonSingleOrDoubleClickOrHold:
            if let data = event.payload {
                let buttonEvent = ButtonEvent(fromData: data as Data)
                if let button = connections[buttonEvent.connectionId] {
                    button.handleEvent(buttonEvent)
                }
            }
        default:
            break
        }
    }
    
    private func doCreateConnectionChannel(_ rawBluetoothAddress: [UInt8]) -> UInt32 {
        let data = NSMutableData()
        // Should be set according to some rules ...
        var connectionId = getNextAvailableConnectionId()
        data.append(&connectionId, length: 4)
        data.append(rawBluetoothAddress, length: rawBluetoothAddress.count)
        var latencyMode = LatencyMode.Normal.rawValue
        data.append(&latencyMode, length: 1)
        var autoDisconnectTime = UInt16(60)
        data.append(&autoDisconnectTime, length: 2)
        let command = FlicCommand(commandType: FlicCommand.CommandType.createConnectionChannel, data: data as Data)
        session.tcpSocket?.sendMessage(command.message)
        return connectionId
    }
    
    public func doRemoveAllConnections(_ rawBluetoothAddress: [UInt8]) {
        let data = NSMutableData()
        data.append(rawBluetoothAddress, length: rawBluetoothAddress.count)
        let command = FlicCommand(commandType: FlicCommand.CommandType.forceDisconnect, data: data as Data)
        session.tcpSocket?.sendMessage(command.message)
    }
    
    private func getNextAvailableConnectionId() -> UInt32 {
        var found = false
        var id = UInt32(0)
        while !found {
            if connections[id] == nil {
                found = true
            } else {
                id += 1
            }
        }
        return id
    }
}
