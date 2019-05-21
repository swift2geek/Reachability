//
//  ReachabilityServiceImp.swift
//  Freehand
//
//  Created by Vladimir on 11/10/2018.
//  Copyright © 2018 Valter.tech. All rights reserved.
//

import Foundation

class ReachabilityServiceImp {
    
    lazy var reachability = SCNetworkReachabilityCreateWithName(nil, "google.ru")
    
    var currentFlags: SCNetworkReachabilityFlags?
    
    var isListening = false
    
    var callbackHandler: ((ReachabilityStatus) -> Void)?
    
    func checkReachability(flags: SCNetworkReachabilityFlags) {
        guard currentFlags != flags else { return }
        currentFlags = flags
        switch flags.rawValue {
        case 262147:
            callbackHandler?(.cellular)
        case 2:
            callbackHandler?(.wifi)
        case 0:
            callbackHandler?(.none)
        default:
            break
        }
    }
    
    deinit {
        stopListening()
    }
    
}

extension ReachabilityServiceImp: ReachabilityService {
    
    func startListening(callbackHandler: @escaping (ReachabilityStatus) -> Void) {
        guard !isListening else { return }
        
        guard let reachability = reachability else { return }
        
        self.callbackHandler = callbackHandler
        
        var context = SCNetworkReachabilityContext()
        context.info = UnsafeMutableRawPointer(Unmanaged<ReachabilityServiceImp>.passUnretained(self).toOpaque())
        
        let callback: SCNetworkReachabilityCallBack? = { (reachability: SCNetworkReachability,
                                                          flags: SCNetworkReachabilityFlags,
                                                          info: UnsafeMutableRawPointer?) in
            guard let info = info else { return }
            let service = Unmanaged<ReachabilityServiceImp>.fromOpaque(info).takeUnretainedValue()
            DispatchQueue.main.async { service.checkReachability(flags: flags) }
        }
        
        SCNetworkReachabilitySetCallback(reachability, callback, &context)
        SCNetworkReachabilitySetDispatchQueue(reachability, DispatchQueue.main)
        
        DispatchQueue.main.async { [weak self] in
            self?.currentFlags = nil
            var flags = SCNetworkReachabilityFlags()
            SCNetworkReachabilityGetFlags(reachability, &flags)
            self?.checkReachability(flags: flags)
        }
        
        isListening = true
    }
    
    func stopListening() {
        guard isListening else { return }
        guard let reachability = reachability else { return }
        callbackHandler = nil
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
        isListening = false
    }
    
}
