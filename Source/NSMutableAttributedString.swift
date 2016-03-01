//
//  NSMutableAttributedString.swift
//  BFLabel
//
//  Created by byyyf on 2/12/16.
//  Copyright © 2016 byyyf. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    func addAttributes(attributes: [String : AnyObject]) {
        addAttributes(attributes, range: NSMakeRange(0, length))
    }
}