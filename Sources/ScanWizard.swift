//
//  ScanWizard.swift
//  FlicController
//
//  Created by Fred Rajaona on 20/07/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

public protocol ScanWizardObserver {
    var observerHashValue: String { get }
    func onScanWizardChange()
}

public class ScanWizard {
    
    public enum State {
        case idle
        case scanning
        case privateButtonWaitingUser
        case connecting
        case pairing
        case completed
    }
    
    enum Event {
        case start
        case privateButtonFound
        case publicButtonFound
        case buttonConnected
        case completed
    }
    
    private static let ScanId = UInt32(100)
    
    private let session: FlicSession
    
    private var observers = [String: ScanWizardObserver]()
    
    public var state = State.idle
    
    public var lastResult = ScanWizardResult.WizardSuccess
    private var currentButtonInfo: ScanButtonInfo?
    
    init(session: FlicSession) {
        self.session = session
    }
    
    public func start() {
        let startCommand = getScanWizardCommand(FlicCommand.CommandType.createScanWizard)
        session.tcpSocket?.sendMessage(startCommand.message)
        runStateMachine(.start)
    }
    
    public func cancel() {
        let startCommand = getScanWizardCommand(FlicCommand.CommandType.cancelScanWizard)
        session.tcpSocket?.sendMessage(startCommand.message)
    }
    
    public func registerObserver(_ observer: ScanWizardObserver) {
        if observers[observer.observerHashValue] == nil {
            observers[observer.observerHashValue] = observer
        }
        observer.onScanWizardChange()
    }
    
    public func unregisterObserver(_ observer: ScanWizardObserver) {
        observers[observer.observerHashValue] = nil
    }
    
    public func close() {
        observers.removeAll()
    }
    
    func notifyObservers() {
        for (_, observer) in observers {
            observer.onScanWizardChange()
        }
    }
    
    func handleEvent(_ event: FlicEvent) {
        switch event.eventType {
        case .scanWizardFoundPrivateButton:
            runStateMachine(.privateButtonFound)
        case .scanWizardFoundPublicButton:
            if let data = event.payload {
                currentButtonInfo = ScanButtonInfo(fromData: data as Data, isAdvertisement: false)
                runStateMachine(.publicButtonFound)
            }
        case .scanWizardButtonConnected:
            runStateMachine(.buttonConnected)
        case .scanWizardCompleted:
            if let data = event.payload {
                lastResult = getScanWizardResult(data as Data)
                print("ScanWizard handle event ScanWizardCompleted -> result = \(lastResult)")
                runStateMachine(.completed)
            }
        default:
            print("unhandled event \(event)")
        }
    }
    
    private func runStateMachine(_ event: Event) {
        switch state {
        case .idle:
            switch event {
            case .start:
                state = .scanning
                notifyObservers()
            default:
                print("not handled event=\(event) for state=\(state)")
            }
        case .scanning:
            switch event {
            case .privateButtonFound:
                state = .privateButtonWaitingUser
                notifyObservers()
            case .publicButtonFound:
                state = .connecting
                notifyObservers()
            case .completed:
                state = .completed
                notifyObservers()
            default:
                print("not handled event=\(event) for state=\(state)")
            }
        case .privateButtonWaitingUser:
            switch event {
            case .publicButtonFound:
                state = .connecting
                notifyObservers()
            case .completed:
                state = .completed
                notifyObservers()
            default:
                print("not handled event=\(event) for state=\(state)")
            }
        case .connecting:
            switch event {
            case .buttonConnected:
                state = .pairing
                notifyObservers()
            case .completed:
                state = .completed
                notifyObservers()
            default:
                print("not handled event=\(event) for state=\(state)")
            }
        case .pairing:
            switch event {
            case .completed:
                state = .completed
                notifyObservers()
            default:
                print("not handled event=\(event) for state=\(state)")
            }
            
        case .completed:
            print("Scan Wizard cannot handle event when state is completed: \(event)")
        }
        if state == .idle {
            currentButtonInfo = nil
        }
    }
    
    private func getScanWizardCommand(_ commandType: FlicCommand.CommandType) -> FlicCommand {
        let data = NSMutableData()
        var id = ScanWizard.ScanId
        data.append(&id, length: 4)
        return FlicCommand(commandType: commandType, data: data as Data)
    }
    
    private func getScanWizardResult(_ data: Data) -> ScanWizardResult {
        var byte8 = UInt8(0)
        (data as NSData).getBytes(&byte8, range: NSMakeRange(4, 1))
        return ScanWizardResult(rawValue: byte8)
    }
    
}
