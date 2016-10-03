//
//  Socket.swift
//  FlicController
//
//  Created by Fred Rajaona on 17/07/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

protocol Socket {
    
    func openConnection() -> Bool
    func closeConnection()
    func isConnected() -> Bool
    func sendMessage<T: Message>(_ message: T, address: String)
    func sendMessage<T: Message>(_ message: T)
}
