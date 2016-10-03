//
//  FlicController.swift
//  FlicController
//
//  Created by Fred Rajaona on 17/07/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

public protocol FlicControllerObserver {
    var observerHashValue: String { get }
    func onFlicControllerChange()
}

public class FlicController {
    
    private static let ScanId = UInt32(100)
    
    public static let sharedInstance = FlicController()
    
    fileprivate var session = FlicSession()
    
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
            session.tcpSocket?.sendMessage(FlicCommand(commandType: FlicCommand.CommandType.getInfo, data: nil).message)
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
            session.tcpSocket?.sendMessage(FlicCommand(commandType: FlicCommand.CommandType.getInfo, data: nil).message)
            
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
