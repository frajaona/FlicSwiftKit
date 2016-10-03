//
//  BluetoothUtils.swift
//  FlicController
//
//  Created by Fred Rajaona on 20/07/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

public class BluetoothUtils {
    
    static func convertToString(_ btAddr: [UInt8]) -> String {
        var strAddr = ""
        for i in (0..<6).reversed() {
            if i < 5 {
                strAddr += ":"
            }
            strAddr += String(format: "%02X", btAddr[i])
        }
        return strAddr
    }
}
