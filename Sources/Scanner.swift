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


public protocol ScannerListener {
    var listenerHashValue: String { get }
    func onScannedButtonsChanged(_ scannedButtons: [String: FlicButton])
}

public class Scanner {
    
    private let session: FlicSession
    private let scanId: UInt32
    private var scannedButtons = [String: FlicButton]()
    private var scanning = false
    
    public var isScanning: Bool {
        return scanning
    }
    
    private var listeners = [String: ScannerListener]()
    
    init(flicSession: FlicSession, id: UInt32) {
        session = flicSession
        scanId = id
    }
    
    public func start() {
        if !scanning {
            scanning = true
            let startCommand = getCommand(FlicCommand.CommandType.createScanner)
            session.tcpSocket?.sendMessage(startCommand.message)
        }
    }
    
    public func stop() {
        if scanning {
            scanning = false
            let stopCommand = getCommand(FlicCommand.CommandType.removeScanner)
            session.tcpSocket?.sendMessage(stopCommand.message)
            scannedButtons.removeAll()
        }
    }
    
    public func registerListener(_ listener: ScannerListener) {
        if listeners[listener.listenerHashValue] == nil {
            listeners[listener.listenerHashValue] = listener
        }
        listener.onScannedButtonsChanged(scannedButtons)
    }
    
    public func unregisterListener(_ listener: ScannerListener) {
        listeners[listener.listenerHashValue] = nil
    }
    
    func notifyListeners() {
        for (_, listener) in listeners {
            listener.onScannedButtonsChanged(scannedButtons)
        }
    }

    
    func handleEvent(_ event: FlicEvent) {
        switch event.eventType {
        case .advertisementPacket:
            if let data = event.payload {
                let buttonInfo = ScanButtonInfo(fromData: data as Data, isAdvertisement: true)
                if let button = scannedButtons[buttonInfo.name] {
                    button.update(buttonInfo)
                } else {
                    scannedButtons[buttonInfo.name] = FlicButton(info: buttonInfo, flicSession: session)
                }
            }
        default:
            break
        }
    }
    
    private func getCommand(_ commandType: FlicCommand.CommandType) -> FlicCommand {
        let data = NSMutableData()
        var id = scanId
        data.append(&id, length: 4)
        return FlicCommand(commandType: commandType, data: data as Data)
    }
}
