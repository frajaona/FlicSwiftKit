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

struct ScanButtonInfo {
    
    let bluetoothAddress: String
    let rawBluetoothAddress: [UInt8]
    let name: String
    let rssi: Int
    let privateMode: Bool
    let alreadyVerified: Bool
    let isAdvertisement: Bool
    
    init(fromData data: Data, isAdvertisement: Bool) {
        var bdAddr = [UInt8](repeating: 0, count: 6)
        (data as NSData).getBytes(&bdAddr, range: NSMakeRange(4, 6))
        bluetoothAddress = BluetoothUtils.convertToString(bdAddr)
        rawBluetoothAddress = bdAddr
        
        var byte8 = UInt8(0)
        (data as NSData).getBytes(&byte8, range: NSMakeRange(10, 1))
        let nameSize = Int(byte8)
        var name = [UInt8](repeating: 0, count: nameSize)
        (data as NSData).getBytes(&name, range: NSMakeRange(11, nameSize))
        
        self.name = String(bytes: name, encoding: String.Encoding.utf8)!
        
        self.isAdvertisement = isAdvertisement
        
        if isAdvertisement {
            var signedByte8 = Int8(0)
            (data as NSData).getBytes(&signedByte8, range: NSMakeRange(27, 1))
            rssi = Int(signedByte8)
            
            (data as NSData).getBytes(&byte8, range: NSMakeRange(28, 1))
            privateMode = byte8 > 0
            
            (data as NSData).getBytes(&byte8, range: NSMakeRange(29, 1))
            alreadyVerified = byte8 > 0
        } else {
            rssi = -127
            privateMode = false
            alreadyVerified = false
        }
    }
    
    static func isRssiValid(_ rssi: Int) -> Bool {
        return rssi > -127 && rssi <= 20
    }
    
}
