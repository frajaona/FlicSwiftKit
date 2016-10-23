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

public protocol FlicControllerObserver {
    var observerHashValue: String { get }
    func onFlicControllerChange()
}

public class FlicController {
    
    private static let ScanId = UInt32(100)
    
    public static let sharedInstance = FlicController()
    
#if os(OSX)
    fileprivate var session = FlicSession(socket: FlicSocksSocket())
#else
    fileprivate var session = FlicSession(socket: FlicCASSocket())
#endif
    
    fileprivate var info: FlicControllerInfo?
    
    fileprivate var observers = [String: FlicControllerObserver]()
    
    public var connected: Bool {
        return info != nil
    }
    
    fileprivate var scanWizard: ScanWizard
    
    public let connectionManager: ConnectionManager
    
    public let scanner: Scanner
    
    init() {
        scanWizard = ScanWizard(session: session)
        connectionManager = ConnectionManager(session: session)
        scanner = Scanner(flicSession: session, id: UInt32(FlicController.ScanId))
        session.delegate = self
    }
    
    public func registerObserver(_ observer: FlicControllerObserver) {
        if observers[observer.observerHashValue] == nil {
            observers[observer.observerHashValue] = observer
        }
        observer.onFlicControllerChange()
    }
    
    public func unregisterObserver(_ observer: FlicControllerObserver) {
        observers[observer.observerHashValue] = nil
    }
    
    public func getNewScanWizard() -> ScanWizard {
        if scanWizard.state == .completed {
            scanWizard.close()
            scanWizard = ScanWizard(session: session)
        }
        return scanWizard
    }

    fileprivate func notifyObservers() {
        for (_, observer) in observers {
            observer.onFlicControllerChange()
        }
    }
    
    public func loadInfos() {
        if session.isConnected() {
            notifyObservers()
        } else {
            session.start()
        }
    }
    
    public func reloadInfos() {
        if session.isConnected() {
            session.sendMessage(FlicCommand(commandType: FlicCommand.CommandType.getInfo, data: nil).message)
        }
    }
}

extension FlicController: FlicSessionDelegate {
    func flicSession(_ session: FlicSession, didReceiveEvent event: FlicEvent) {
        switch event.eventType {
        case .getInfoResponse:
            if let payload = event.payload {
                info = FlicControllerInfo(fromData: payload as Data)
                print("info: \(info!)")
                for button in info!.verifiedButtons {
                    connectionManager.connectButton(button)
                }
                notifyObservers()
            }
            
        case .newVerifiedButton:
            // Send a GetInfo to update the verified button list and connect to the new button
            session.sendMessage(FlicCommand(commandType: FlicCommand.CommandType.getInfo, data: nil).message)
            
        case .scanWizardFoundPrivateButton, .scanWizardFoundPublicButton, .scanWizardButtonConnected, .scanWizardCompleted:
            scanWizard.handleEvent(event)
            
        case .advertisementPacket:
            scanner.handleEvent(event)
            
        case .createConnectionChannelResponse, .connectionStatusChanged, .connectionChannelRemoved:
            connectionManager.handleEvent(event)
            
        case .buttonUpOrDown, .buttonClickOrHold, .buttonSingleOrDoubleClick, .buttonSingleOrDoubleClickOrHold:
            connectionManager.handleButtonEvent(event)
            
            
        default:
            break
        }
    }
}
