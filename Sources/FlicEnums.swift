//
//  FlicEnums.swift
//  FlicController
//
//  Created by Fred Rajaona on 18/07/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

struct CreateConnectionChannelError: OptionSet {
    
    let rawValue: UInt8
    init(rawValue: UInt8) { self.rawValue = rawValue }
    
    static let NoError = CreateConnectionChannelError(rawValue: 0)
    static let MaxPendingConnectionsReached = CreateConnectionChannelError(rawValue: 1)
}

public struct ConnectionStatus: OptionSet {
    
    public let rawValue: UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    
    public static let Disconnected = ConnectionStatus(rawValue: 0)
    public static let Connected = ConnectionStatus(rawValue: 1)
    public static let Ready = ConnectionStatus(rawValue: 2)
    public static let WontConnect = ConnectionStatus(rawValue: 100)
}

public struct DisconnectReason: OptionSet {
    
    public let rawValue: UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    
    public static let Unspecified = DisconnectReason(rawValue: 0)
    public static let ConnectionEstablishmentFailed = DisconnectReason(rawValue: 1)
    public static let TimedOut = DisconnectReason(rawValue: 2)
    public static let BondingKeysMismatch = DisconnectReason(rawValue: 3)
}

struct RemovedReason: OptionSet {
    
    let rawValue: UInt8
    init(rawValue: UInt8) { self.rawValue = rawValue }
    
    static let RemovedByThisClient = RemovedReason(rawValue: 0)
    static let ForceDisconnectedByThisClient = RemovedReason(rawValue: 1)
    static let ForceDisconnectedByOtherClient = RemovedReason(rawValue: 2)
    static let ButtonIsPrivate = RemovedReason(rawValue: 3)
    static let VerifyTimeout = RemovedReason(rawValue: 4)
    static let InternetBackendError = RemovedReason(rawValue: 5)
    static let InvalidData = RemovedReason(rawValue: 6)
}

struct ClickType: OptionSet {
    
    let rawValue: UInt8
    init(rawValue: UInt8) { self.rawValue = rawValue }
    
    static let ButtonDown = ClickType(rawValue: 0)
    static let ButtonUp = ClickType(rawValue: 1)
    static let ButtonClick = ClickType(rawValue: 2)
    static let ButtonSingleClick = ClickType(rawValue: 3)
    static let ButtonDoubleClick = ClickType(rawValue: 4)
    static let ButtonHold = ClickType(rawValue: 5)
}

struct BdAddrType: OptionSet {
    
    let rawValue: UInt8
    init(rawValue: UInt8) { self.rawValue = rawValue }
    
    static let PublicBdAddrType = BdAddrType(rawValue: 0)
    static let RandomBdAddrType = BdAddrType(rawValue: 1)
}

public struct LatencyMode: OptionSet {
    
    public let rawValue: UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    
    public static let Normal = LatencyMode(rawValue: 0)
    public static let Low = LatencyMode(rawValue: 1)
    public static let High = LatencyMode(rawValue: 2)
}

struct BluetoothControllerState: OptionSet {
    
    let rawValue: UInt8
    init(rawValue: UInt8) { self.rawValue = rawValue }
    
    static let Detached = BluetoothControllerState(rawValue: 0)
    static let Resetting = BluetoothControllerState(rawValue: 1)
    static let Attached = BluetoothControllerState(rawValue: 2)
}

public struct ScanWizardResult: OptionSet {
    
    public let rawValue: UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    
    public static let WizardSuccess = ScanWizardResult(rawValue: 0)
    public static let WizardCancelledByUser = ScanWizardResult(rawValue: 1)
    public static let WizardFailedTimeout = ScanWizardResult(rawValue: 2)
    public static let WizardButtonIsPrivate = ScanWizardResult(rawValue: 3)
    public static let WizardBluetoothUnavailable = ScanWizardResult(rawValue: 4)
    public static let WizardInternetBackendError = ScanWizardResult(rawValue: 5)
    public static let WizardInvalidData = ScanWizardResult(rawValue: 6)
}

