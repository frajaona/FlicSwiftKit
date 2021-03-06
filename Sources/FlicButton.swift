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


public protocol OnButtonClickListener {
    var listenerHashValue: String { get }
    func onClick(_ button: FlicButton)
    func onDoubleClick(_ button: FlicButton)
    func onLongClick(_ button: FlicButton)
}

public protocol OnButtonEventListener {
    var listenerHashValue: String { get }
    func onButtonEvent(_ button: FlicButton, pressed: Bool)
}

public class FlicButton: Equatable {
    
    public var name: String?
    
    public let bluetoothAddress: String
    
    let rawBluetoothAddress: [UInt8]
    
    private let session: FlicSession
    
    private var clickListeners = [String: OnButtonClickListener]()
    private var eventListeners = [String: OnButtonEventListener]()
    
    public var connectionStatus = ConnectionStatus.Disconnected {
        didSet {
            if connectionStatus != ConnectionStatus.Disconnected {
                disconnectReason = nil
            }
        }
    }
    
    public var status: String {
        get {
            var text = ""
            switch connectionStatus {
            case ConnectionStatus.Disconnected:
                text = "Disconnected"
            case ConnectionStatus.Connected:
                text = "Connected"
            case ConnectionStatus.Ready:
                text = "Ready"
            case ConnectionStatus.WontConnect:
                text = "Private"
            default:
                break
            }
            return text
        }
    }
    
    public var disconnectReason: DisconnectReason?
    
    private var privateMode: Bool
    
    private var alreadyVerified: Bool
    
    private var pressed = false
    
    public var isPressed: Bool {
        return pressed
    }
    
    public var isPrivate: Bool {
        return privateMode
    }
    
    public var connectable: Bool {
        return alreadyVerified
    }
    
    init(info: ScanButtonInfo, flicSession: FlicSession) {
        name = info.name
        bluetoothAddress = info.bluetoothAddress
        rawBluetoothAddress = info.rawBluetoothAddress
        privateMode = info.privateMode
        alreadyVerified = info.alreadyVerified
        session = flicSession
    }
    
    init(flicSession: FlicSession, rawAddress: [UInt8], connectable: Bool, priv: Bool) {
        session = flicSession
        rawBluetoothAddress = rawAddress
        bluetoothAddress = BluetoothUtils.convertToString(rawAddress)
        alreadyVerified = connectable
        privateMode = priv
    }
    
    public func addOnClickListener(_ listener: OnButtonClickListener) {
        if clickListeners[listener.listenerHashValue] == nil {
            clickListeners[listener.listenerHashValue] = listener
        }
    }
    
    public func removeOnClickListener(_ listener: OnButtonClickListener) {
        clickListeners[listener.listenerHashValue] = nil
    }
    
    public func addOnEventListener(_ listener: OnButtonEventListener) {
        if eventListeners[listener.listenerHashValue] == nil {
            eventListeners[listener.listenerHashValue] = listener
        }
    }
    
    public func removeOnEventListener(_ listener: OnButtonEventListener) {
        eventListeners[listener.listenerHashValue] = nil
    }
    
    func handleEvent(_ event: ButtonEvent) {
        switch event.clickType {
        case ClickType.ButtonDown:
            pressed = true
            notifyEvent()
            
        case ClickType.ButtonUp:
            pressed = false
            notifyEvent()
            
        case ClickType.ButtonSingleClick:
            notifyClick()
            
        case ClickType.ButtonDoubleClick:
            notifyDoubleClick()
            
        case ClickType.ButtonHold:
            notifyLongClick()
            
        default:
            break
        }
    }
    
    func update(_ info: ScanButtonInfo) {
        privateMode = info.privateMode
        alreadyVerified = info.alreadyVerified
    }
    
    func notifyClick() {
        for (_, listener) in clickListeners {
            listener.onClick(self)
        }
    }
    
    func notifyDoubleClick() {
        for (_, listener) in clickListeners {
            listener.onDoubleClick(self)
        }
    }
    
    func notifyLongClick() {
        for (_, listener) in clickListeners {
            listener.onLongClick(self)
        }
    }
    
    func notifyEvent() {
        for (_, listener) in eventListeners {
            listener.onButtonEvent(self, pressed: pressed)
        }
    }
}

public func ==(lhs: FlicButton, rhs: FlicButton) -> Bool {
    return lhs.bluetoothAddress == rhs.bluetoothAddress
        && lhs.rawBluetoothAddress == rhs.rawBluetoothAddress
}
