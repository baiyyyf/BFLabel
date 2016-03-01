//
//  ThreadHelper.swift
//  BFLabel
//
//  Created by byyyf on 2/12/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import Foundation

func dispatchInMainQueue(action: () -> Void) {
    if NSThread.isMainThread() {
        action()
    } else {
        dispatch_async(dispatch_get_main_queue()) {
            action()
        }
    }
}