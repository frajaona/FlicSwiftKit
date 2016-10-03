//
//  ButtonEvent.swift
//  FlicController
//
//  Created by Fred Rajaona on 15/08/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

struct ButtonEvent {
    
    let connectionId: UInt32
    let clickType: ClickType
    let wasQueued: Bool
    let timeDiff: UInt32
    
    init(fromData data: Data) {
        var id = UInt32(0)
        (data as NSData).getBytes(&id, range: NSMakeRange(0, 4))
        connectionId = id
        var byte8 = UInt8(0)
        (data as NSData).getBytes(&byte8, range: NSMakeRange(4, 1))
        clickType = ClickType(rawValue: byte8)
        (data as NSData).getBytes(&byte8, range: NSMakeRange(5, 1))
        wasQueued = byte8 > 0
        (data as NSData).getBytes(&id, range: NSMakeRange(6, 4))
        timeDiff = id
    }
    
}
