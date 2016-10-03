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
