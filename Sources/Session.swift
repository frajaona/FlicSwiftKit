//
//  Session.swift
//  FlicController
//
//  Created by Fred Rajaona on 17/07/2016.
//  Copyright © 2016 Fred Rajaona. All rights reserved.
//

import Foundation

protocol Session {
    func start()
    func stop()
    func isConnected() -> Bool
}