//
//  ReachabilityService.swift
//  Freehand
//
//  Created by Vladimir on 11/10/2018.
//  Copyright © 2018 Valter.tech. All rights reserved.
//

import Foundation

protocol ReachabilityService {
    
    func startListening(callbackHandler: @escaping (ReachabilityStatus) -> Void)
    func stopListening()
    
}
